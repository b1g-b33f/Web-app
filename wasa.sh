#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <URL>"
  exit 1
fi

TARGET=$(echo $1 | awk -F/ '{print $3}')

if [ -z "$TARGET" ]; then
  echo "Invalid URL provided. Please check the URL."
  exit 1
fi

DATE=$(date +"%Y-%m-%d")
SANITIZED_TARGET=$(echo "$TARGET" | sed 's/[^a-zA-Z0-9]/_/g')
OUTPUT_FILE="${SANITIZED_TARGET}_${DATE}_scan_results.txt"

print_header() {
  echo "=== $1 ===" >> "$OUTPUT_FILE"
  echo "-----------------------------" >> "$OUTPUT_FILE"
  date >> "$OUTPUT_FILE"
  echo "-----------------------------" >> "$OUTPUT_FILE"
}

echo "Saving results to $OUTPUT_FILE"

gather_headers() {
  echo "Gathering HTTP headers from $TARGET"
  print_header "HTTP Headers"
  curl -I "$1" >> "$OUTPUT_FILE" 2>&1
}

nmap_scan() {
  echo "Starting Nmap scan on $TARGET"
  print_header "Nmap Scan"
  nmap -Pn -T4 -A -v -p- "$TARGET" >> "$OUTPUT_FILE" 2>&1
}

sslscan_scan() {
  echo "Starting sslscan on $TARGET"
  print_header "sslscan Scan"
  sslscan "$TARGET" >> "$OUTPUT_FILE" 2>&1
}

nikto_scan() {
  echo "Starting Nikto scan on $TARGET"
  print_header "Nikto Scan"
  nikto -h "$TARGET" >> "$OUTPUT_FILE" 2>&1
}

gather_headers "$1" &
GATHER_HEADERS_PID=$!

wait $GATHER_HEADERS_PID
echo "Gathering HTTP headers completed."

nmap_scan &
NMAP_PID=$!
wait $NMAP_PID
echo "Nmap scan completed."

sslscan_scan &
SSLSCAN_PID=$!
wait $SSLSCAN_PID
echo "sslscan completed."

nikto_scan &
NIKTO_PID=$!
wait $NIKTO_PID
echo "Nikto scan completed."

echo "All scans completed for $TARGET. Results saved to $OUTPUT_FILE."

exit 0

