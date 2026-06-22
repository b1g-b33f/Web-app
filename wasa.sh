#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <URL> <engagement_dir>"
  exit 1
fi

# Extract domain or IP from the URL, remove protocol (http:// or https://)
TARGET=$(echo $1 | sed -e 's|http[s]*://||' -e 's|/.*||')

if [ -z "$TARGET" ]; then
  echo "Invalid URL provided. Please check the URL."
  exit 1
fi

# Derive port from URL scheme
if echo "$1" | grep -q '^https'; then
  PORT=443
else
  PORT=80
fi

OUTPUT_DIR="${2:-.}"
mkdir -p "$OUTPUT_DIR"

DATE=$(date +"%Y-%m-%d")
SANITIZED_TARGET=$(echo "$TARGET" | sed 's/[^a-zA-Z0-9]/_/g')

# Construct the output file path
OUTPUT_FILE="$OUTPUT_DIR/${SANITIZED_TARGET}_${DATE}_scan_results.txt"

echo "Saving results to $OUTPUT_FILE"

nmap_scan() {
  echo "### Starting Nmap Scan on $TARGET ###" >> "$OUTPUT_FILE"
  echo "======================================" >> "$OUTPUT_FILE"
  nmap -Pn -T4 -A -p- "$TARGET" >> "$OUTPUT_FILE" 2>&1
  echo -e "\n### Nmap Scan Completed ###\n" >> "$OUTPUT_FILE"
}

nmap_http_scan() {
  echo "### Starting Nmap HTTP Scripts Scan on $TARGET ###" >> "$OUTPUT_FILE"
  echo "==================================================" >> "$OUTPUT_FILE"
  nmap -p "$PORT" --script "http-title,http-enum,http-methods,http-headers,http-server-header,http-auth,http-robots.txt,http-config-backup,http-security-headers,http-cookie-flags,http-cors,http-vhosts,http-slowloris-check,http-csrf" "$TARGET" >> "$OUTPUT_FILE" 2>&1
  echo -e "\n### Nmap HTTP Scripts Scan Completed ###\n" >> "$OUTPUT_FILE"
}

sslscan_scan() {
  echo "### Starting sslscan on $TARGET:$PORT ###" >> "$OUTPUT_FILE"
  echo "======================================" >> "$OUTPUT_FILE"
  sslscan "$TARGET:$PORT" >> "$OUTPUT_FILE" 2>&1
  echo -e "\n### sslscan Completed ###\n" >> "$OUTPUT_FILE"
}

nikto_scan() {
  echo "### Starting Nikto Scan on $TARGET ###" >> "$OUTPUT_FILE"
  echo "===================================================" >> "$OUTPUT_FILE"
  nikto -h "$TARGET" -p "$PORT" >> "$OUTPUT_FILE" 2>&1
  echo -e "\n### Nikto Scan Completed ###\n" >> "$OUTPUT_FILE"
}

nuclei_scan() {
  echo "### Starting Nuclei Scan on $1 ###" >> "$OUTPUT_FILE"
  echo "========================================" >> "$OUTPUT_FILE"
  nuclei -u "$1" -o /tmp/nuclei_temp_output.txt >> "$OUTPUT_FILE" 2>&1
  cat /tmp/nuclei_temp_output.txt >> "$OUTPUT_FILE"
  echo -e "\n### Nuclei Scan Completed ###\n" >> "$OUTPUT_FILE"
  rm -f /tmp/nuclei_temp_output.txt
}

js_extract() {
  local JS_DIR="$OUTPUT_DIR/js"
  mkdir -p "$JS_DIR"
  local JS_URLS="/tmp/js_urls_$$.txt"
  touch "$JS_URLS"

  echo "### Starting JS Extraction for $1 ###" >> "$OUTPUT_FILE"
  echo "======================================" >> "$OUTPUT_FILE"

  # Collect JS URLs — katana preferred, gau fallback, then basic curl crawl
  if command -v katana &>/dev/null; then
    echo "Using katana for JS discovery..." | tee -a "$OUTPUT_FILE"
    katana -u "$1" -jc -d 3 -silent 2>/dev/null | grep -iE '\.js(\?|$)' >> "$JS_URLS"
  elif command -v gau &>/dev/null; then
    echo "Using gau for JS discovery..." | tee -a "$OUTPUT_FILE"
    gau "$TARGET" 2>/dev/null | grep -iE '\.js(\?|$)' >> "$JS_URLS"
  fi

  # Always supplement with a direct page scrape for <script src="...">
  curl -sk --max-time 15 "$1" \
    | grep -oP '(?<=src=")[^"]*\.js[^"]*' \
    | while read -r path; do
        if echo "$path" | grep -q '^http'; then
          echo "$path"
        else
          echo "${1%/}/${path#/}"
        fi
      done >> "$JS_URLS"

  sort -u "$JS_URLS" -o "$JS_URLS"
  local COUNT
  COUNT=$(wc -l < "$JS_URLS")
  echo "Found $COUNT unique JS files" | tee -a "$OUTPUT_FILE"
  cat "$JS_URLS" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"

  # Download each JS file into engagement_dir/js/
  while IFS= read -r js_url; do
    [ -z "$js_url" ] && continue
    local fname
    fname=$(basename "${js_url%%\?*}")
    echo "Downloading: $js_url" | tee -a "$OUTPUT_FILE"
    curl -sk --max-time 20 -o "$JS_DIR/$fname" "$js_url" 2>/dev/null
  done < "$JS_URLS"

  echo "JS files saved to $JS_DIR" | tee -a "$OUTPUT_FILE"
  echo -e "\n### JS Extraction Completed ###\n" >> "$OUTPUT_FILE"
  rm -f "$JS_URLS"
}


# Run scans
echo "Starting all scans for $TARGET"

echo "Starting Nmap Scan..."
nmap_scan

echo "Starting Nmap HTTP Scripts Scan..."
nmap_http_scan

echo "Starting sslscan..."
sslscan_scan

echo "Starting Nikto Scan..."
nikto_scan

echo "Starting Nuclei Scan..."
nuclei_scan "$1"

echo "Starting JS Extraction..."
js_extract "$1"

echo "All scans completed for $TARGET. Results saved to $OUTPUT_FILE."

exit 0
