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
OUTPUT_DIR=${OUTPUT_DIR:-"."}  # Default to current directory if not provided

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
  echo "" >> "$OUTPUT_FILE"
  echo "### Nmap Scan Completed ###" >> "$OUTPUT_FILE"
  echo "======================================" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
}

nmap_http_scan() {
  echo "### Starting Nmap HTTP Scripts Scan on $TARGET ###" >> "$OUTPUT_FILE"
  echo "==================================================" >> "$OUTPUT_FILE"
  nmap -p "$PORT" --script http-enum,http-methods,http-headers,http-server-header,http-auth,http-robots.txt,http-config-backup "$TARGET" >> "$OUTPUT_FILE" 2>&1
  echo "" >> "$OUTPUT_FILE"
  echo "### Nmap HTTP Scripts Scan Completed ###" >> "$OUTPUT_FILE"
  echo "==================================================" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
}

sslscan_scan() {
  echo "### Starting SSLScan on $TARGET ###" >> "$OUTPUT_FILE"
  echo "===================================" >> "$OUTPUT_FILE"
  sslscan "$TARGET" >> "$OUTPUT_FILE" 2>&1
  echo "" >> "$OUTPUT_FILE"
  echo "### SSLScan Completed ###" >> "$OUTPUT_FILE"
  echo "===================================" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
}

nikto_scan() {
  echo "### Starting Nikto Scan on $TARGET ###" >> "$OUTPUT_FILE"
  echo "===================================================" >> "$OUTPUT_FILE"
  nikto -h "$TARGET" -p "$PORT" >> "$OUTPUT_FILE" 2>&1
  echo "" >> "$OUTPUT_FILE"
  echo "### Nikto Scan Completed ###" >> "$OUTPUT_FILE"
  echo "===================================================" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
}

whatweb_scan() {
  echo "### Starting WhatWeb Scan on $TARGET ###" >> "$OUTPUT_FILE"
  echo "========================================" >> "$OUTPUT_FILE"
  whatweb -a 3 -v "$1" >> "$OUTPUT_FILE" 2>&1
  echo "" >> "$OUTPUT_FILE"
  echo "### WhatWeb Scan Completed ###" >> "$OUTPUT_FILE"
  echo "========================================" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
}

wafw00f_scan() {
  echo "### Starting WAFW00F Scan on $TARGET ###" >> "$OUTPUT_FILE"
  echo "======================================" >> "$OUTPUT_FILE"
  wafw00f "$TARGET" >> "$OUTPUT_FILE" 2>&1
  echo "" >> "$OUTPUT_FILE"
  echo "### WAFW00F Scan Completed ###" >> "$OUTPUT_FILE"
  echo "======================================" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
}

# Run scans sequentially with real-time updates
echo "Starting all scans for $TARGET"
echo "Starting Nmap Scan on $TARGET"
nmap_scan
echo "Nmap scan completed."

echo "Starting Nmap HTTP Scripts Scan on $TARGET"
nmap_http_scan
echo "Nmap HTTP scripts scan completed."

echo "Starting SSLScan on $TARGET"
sslscan_scan
echo "SSLScan completed."

echo "Starting Nikto Scan on $TARGET"
nikto_scan
echo "Nikto scan completed."

echo "Starting WhatWeb Scan on $1"
whatweb_scan "$1"
echo "WhatWeb scan completed."

echo "Starting WAFW00F Scan on $TARGET"
wafw00f_scan
echo "WAFW00F scan completed."

echo "All scans completed for $TARGET. Results saved to $OUTPUT_FILE."

exit 0


