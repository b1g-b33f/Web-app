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
OUTPUT_FILE="${SANITIZED_TARGET}_${DATE}_scan_results.txt"

echo "Saving results to $OUTPUT_FILE"

nmap_scan() {
  echo "### Starting Nmap Scan on $TARGET ###" >> "$OUTPUT_FILE"
  echo "======================================" >> "$OUTPUT_FILE"
  nmap -Pn -T4 -A -v -p- "$TARGET" >> "$OUTPUT_FILE" 2>&1
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
  echo "=====================================" >> "$OUTPUT_FILE"
  nikto -h "$TARGET" -p "$PORT" >> "$OUTPUT_FILE" 2>&1
  echo "" >> "$OUTPUT_FILE"
  echo "### Nikto Scan Completed ###" >> "$OUTPUT_FILE"
  echo "=====================================" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
}

curl_headers() {
  echo "### Fetching HTTP Headers using Curl ###" >> "$OUTPUT_FILE"
  echo "=======================================" >> "$OUTPUT_FILE"
  curl -I -k "$1" >> "$OUTPUT_FILE" 2>&1
  echo "" >> "$OUTPUT_FILE"
  echo "### HTTP Headers Fetch Completed ###" >> "$OUTPUT_FILE"
  echo "====================================" >> "$OUTPUT_FILE"
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

echo "Fetching HTTP headers using Curl on $1"
curl_headers "$1"
echo "Curl HTTP headers fetch completed."

echo "All scans completed for $TARGET. Results saved to $OUTPUT_FILE."

exit 0
