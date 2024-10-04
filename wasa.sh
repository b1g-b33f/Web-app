#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <URL> [<PORT>]"
  exit 1
fi

TARGET=$(echo $1 | awk -F/ '{print $3}')
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
  echo "Starting Nmap scan on $TARGET"
  nmap -Pn -T4 -A -v -p- "$TARGET" >> "$OUTPUT_FILE" 2>&1
}

nmap_http_scan() {
  echo "Starting Nmap HTTP scripts scan on $TARGET"
  nmap -p "$PORT" --script http-enum,http-methods,http-headers,http-server-header,http-auth,http-robots.txt,http-config-backup "$TARGET" >> "$OUTPUT_FILE" 2>&1
}

sslscan_scan() {
  echo "Starting sslscan on $TARGET"
  sslscan "$TARGET" >> "$OUTPUT_FILE" 2>&1
}

nikto_scan() {
  echo "Starting Nikto scan on $TARGET"
  nikto -h "$TARGET" -p "$PORT" >> "$OUTPUT_FILE" 2>&1
}

nmap_scan &
NMAP_PID=$!
wait $NMAP_PID
echo "Nmap scan completed."

nmap_http_scan &
NMAP_HTTP_PID=$!
wait $NMAP_HTTP_PID
echo "Nmap HTTP scripts scan completed."

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
