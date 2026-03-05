#!/bin/bash

# Tool availability check
for tool in nmap sslscan nikto nuclei whatweb wafw00f; do
  command -v $tool &>/dev/null || { echo "$tool not found, exiting."; exit 1; }
done

if [ -z "$1" ]; then
  echo "Usage: $0 <URL> [<PORT>]"
  exit 1
fi

TARGET=$(echo $1 | sed -e 's|http[s]*://||' -e 's|/.*||')
PORT=${2:-443}

if [ -z "$TARGET" ]; then
  echo "Invalid URL provided. Please check the URL."
  exit 1
fi

DATE=$(date +"%Y-%m-%d")
SANITIZED_TARGET=$(echo "$TARGET" | sed 's/[^a-zA-Z0-9]/_/g')

read -p "Enter the destination for the output file (default: .): " OUTPUT_DIR
OUTPUT_DIR=${OUTPUT_DIR:-"."}

if [ ! -d "$OUTPUT_DIR" ]; then
  echo "Directory does not exist. Creating $OUTPUT_DIR."
  mkdir -p "$OUTPUT_DIR"
fi

OUTPUT_FILE="$OUTPUT_DIR/${SANITIZED_TARGET}_${DATE}_scan_results.txt"
echo "Saving results to $OUTPUT_FILE"

START_TIME=$(date +%s)

wafw00f_scan() {
  echo "### WAF Detection on $TARGET ###" >> "$OUTPUT_FILE"
  echo "=================================" >> "$OUTPUT_FILE"
  wafw00f "$1" >> "$OUTPUT_FILE" 2>&1
  echo -e "\n### WAF Detection Completed ###\n" >> "$OUTPUT_FILE"
}

whatweb_scan() {
  echo "### Starting WhatWeb Scan on $TARGET ###" >> "$OUTPUT_FILE"
  echo "=========================================" >> "$OUTPUT_FILE"
  whatweb -a 3 "$1" >> "$OUTPUT_FILE" 2>&1
  echo -e "\n### WhatWeb Completed ###\n" >> "$OUTPUT_FILE"
}

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
  echo "==========================================" >> "$OUTPUT_FILE"
  sslscan "$TARGET:$PORT" >> "$OUTPUT_FILE" 2>&1
  echo -e "\n### sslscan Completed ###\n" >> "$OUTPUT_FILE"
}

nikto_scan() {
  echo "### Starting Nikto Scan on $TARGET ###" >> "$OUTPUT_FILE"
  echo "=======================================" >> "$OUTPUT_FILE"
  nikto -h "$TARGET" -p "$PORT" >> "$OUTPUT_FILE" 2>&1
  echo -e "\n### Nikto Scan Completed ###\n" >> "$OUTPUT_FILE"
}

nuclei_scan() {
  echo "### Starting Nuclei Scan on $1 ###" >> "$OUTPUT_FILE"
  echo "====================================" >> "$OUTPUT_FILE"
  nuclei -u "$1" -o /tmp/nuclei_temp_output.txt >> "$OUTPUT_FILE" 2>&1
  cat /tmp/nuclei_temp_output.txt >> "$OUTPUT_FILE"
  echo -e "\n### Nuclei Scan Completed ###\n" >> "$OUTPUT_FILE"
  rm -f /tmp/nuclei_temp_output.txt
}

# Run scans - WAF and tech fingerprinting first
echo "Starting WAF Detection..."
wafw00f_scan "$1"
echo "Starting WhatWeb Scan..."
whatweb_scan "$1"
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

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
echo "All scans completed for $TARGET. Results saved to $OUTPUT_FILE."
echo "Total scan time: $((DURATION / 60)) minutes and $((DURATION % 60)) seconds" | tee -a "$OUTPUT_FILE"

exit 0
