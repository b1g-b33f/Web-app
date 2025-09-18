#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <URL> [<PORT>]"
  exit 1
fi

# Extract domain or IP from the URL, remove protocol (http:// or https://)
TARGET=$(echo $1 | sed -e 's|http[s]*://||' -e 's|/.*||')

PORT=${2:-443}

if [ -z "$TARGET" ]; then
  echo "Invalid URL provided. Please check the URL."
  exit 1
fi

DATE=$(date +"%Y-%m-%d")
SANITIZED_TARGET=$(echo "$TARGET" | sed 's/[^a-zA-Z0-9]/_/g')

# Prompt for the output file destination
read -p "Enter the destination for the output file (default: ${SANITIZED_TARGET}_${DATE}_scan_results.txt): " OUTPUT_DIR
OUTPUT_DIR=${OUTPUT_DIR:-"."}

# Ensure the output directory exists
if [ ! -d "$OUTPUT_DIR" ]; then
  echo "The specified directory does not exist. Creating directory $OUTPUT_DIR."
  mkdir -p "$OUTPUT_DIR"
fi

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

dnsrecon_scan_json() {
  echo "### Starting dnsrecon Scan on $TARGET (JSON output only) ###" >> "$OUTPUT_FILE"
  echo "=============================================================" >> "$OUTPUT_FILE"

  DNSRECON_JSON_OUTPUT="$OUTPUT_DIR/${SANITIZED_TARGET}_${DATE}_dnsrecon.json"

  dnsrecon -d "$TARGET" \
    -a \
    -t brt \
    -D /usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-110000.txt \
    --threads 30 \
    -j "$DNSRECON_JSON_OUTPUT" >> "$OUTPUT_FILE" 2>&1

  echo "dnsrecon JSON output saved to $DNSRECON_JSON_OUTPUT" >> "$OUTPUT_FILE"
  echo -e "\n### dnsrecon Scan Completed ###\n" >> "$OUTPUT_FILE"
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

# Only run dnsrecon if the target is a domain
if [[ "$TARGET" =~ [a-zA-Z] ]]; then
  echo "Starting dnsrecon JSON Scan..."
  dnsrecon_scan_json
fi

echo "All scans completed for $TARGET. Results saved to $OUTPUT_FILE."

exit 0
