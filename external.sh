#!/usr/bin/env bash
set -euo pipefail

# Recon pipeline:
# 1) Normalize URLs/hosts -> clean hostnames (no scheme/ports/paths/{proxy+})
# 2) Resolve to IPv4 -> ips.txt
# 3) Masscan against resolved IPs
# 4) For each IP with open ports, run Nmap -A only on those ports

# --- Defaults ---
URLS_FILE="urls.txt"
OUT_DIR="scans-$(date +%Y%m%d-%H%M%S)"
PORTS="1-1024,1433,1521,2049,2375,2376,27017,3000,3306,3389,5000,5432,5601,5672,5900,6379,8000,8080,8443,9000,9200,9300,11211,15672"
RATE="5000"
IFACE=""
NMAP_EXTRA="-T4"
RESOLVER="dig"   # fallback to getent if dig not found

usage() {
  cat <<EOF
Usage: $0 [-u urls.txt] [-p ports] [-r rate] [-e iface] [--nmap-extra "<opts>"]

  -u  Path to input list (URLs/hosts). Default: urls.txt
  -p  Ports/ranges for Masscan. Default:
      $PORTS
  -r  Masscan rate (packets/sec). Default: $RATE
  -e  Network interface for Masscan (optional).
  --nmap-extra  Extra args for Nmap (e.g. "-sC" or "--script=vuln"). Default: "$NMAP_EXTRA"

Examples:
  $0
  $0 -u urls.txt -p 80,443,8080,8443 -r 10000 -e eth0 --nmap-extra "-T3 --max-retries 2"
EOF
  exit 1
}

# --- Parse args ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    -u) URLS_FILE="$2"; shift 2;;
    -p) PORTS="$2"; shift 2;;
    -r) RATE="$2"; shift 2;;
    -e) IFACE="$2"; shift 2;;
    --nmap-extra) NMAP_EXTRA="$2"; shift 2;;
    -h|--help) usage;;
    *) echo "Unknown arg: $1"; usage;;
  esac
done

# --- Checks ---
command -v masscan >/dev/null 2>&1 || { echo "masscan not found in PATH"; exit 2; }
command -v nmap    >/dev/null 2>&1 || { echo "nmap not found in PATH"; exit 2; }

if command -v dig >/dev/null 2>&1; then RESOLVER="dig"; elif command -v getent >/dev/null 2>&1; then RESOLVER="getent"; else
  echo "Need either 'dig' (bind-tools) or 'getent' to resolve hostnames."; exit 2
fi

[[ -f "$URLS_FILE" ]] || { echo "Input file not found: $URLS_FILE"; exit 2; }

# --- Prep output ---
mkdir -p "$OUT_DIR"/{work,nmap}
CLEAN_HOSTS="$OUT_DIR/work/hosts.cleaned.txt"
IPS_FILE="$OUT_DIR/work/ips.txt"
MASSCAN_LIST="$OUT_DIR/work/masscan.lst"
MASSCAN_XML="$OUT_DIR/work/masscan.xml"

echo "[*] Normalizing hosts from: $URLS_FILE"

# 1) Clean input -> hostnames/IPs Nessus/Masscan/Nmap can accept
#   - strip scheme
#   - cut path/query/fragment
#   - drop {…} placeholders (e.g., {proxy+})
#   - remove leading "*."
#   - strip trailing dot
#   - strip :port (for IPv4/hostnames; leaves IPv6 as-is though masscan is IPv4)
#   - lowercase
#   - remove empties/comments/whitespace
awk '
  BEGIN{ IGNORECASE=1 }
  {
    line=$0
    gsub(/\r/,"",line)                # CRLF->LF
    sub(/^[[:space:]]+/,"",line)
    sub(/[[:space:]]+$/,"",line)
    if (line ~ /^#/ || line == "") next

    # Remove scheme
    sub(/^[a-zA-Z]+:\/\//, "", line)

    # Remove everything after first slash (path, {proxy+}, etc.)
    sub(/\/.*/, "", line)

    # Remove any {...} placeholders that might remain
    gsub(/\{[^}]*\}/, "", line)

    # Remove leading "*."
    sub(/^\*\./, "", line)

    # Strip trailing dot
    sub(/\.$/, "", line)

    # Drop :port for hostnames/IPv4 (naive; okay for our input set)
    # (Avoid touching IPv6 literals, but we skip IPv6 later anyway)
    if (line !~ /^\[/ && line !~ /:/) {
      # no colon, nothing to do
    } else if (line ~ /^[0-9.]+:[0-9]+$/ || line ~ /^[A-Za-z0-9._-]+:[0-9]+$/) {
      sub(/:[0-9]+$/, "", line)
    }

    # Lowercase hostnames
    print tolower(line)
  }
' "$URLS_FILE" \
| grep -Ev '^[[:space:]]*$' \
| sort -u > "$CLEAN_HOSTS"

echo "[*] Cleaned hosts -> $CLEAN_HOSTS ($(wc -l < "$CLEAN_HOSTS") entries)"

# 2) Resolve to IPv4 only (Masscan is IPv4)
echo "[*] Resolving to IPv4 -> $IPS_FILE"
: > "$IPS_FILE"

resolve_host() {
  local h="$1"
  if [[ "$RESOLVER" == "dig" ]]; then
    dig +short A "$h" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' || true
  else
    # getent ahostsv4 lists IPv4 addresses with extra columns; take first column
    getent ahostsv4 "$h" | awk "{print \$1}" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | sort -u || true
  fi
}

while IFS= read -r host; do
  # If already an IPv4, keep it
  if [[ "$host" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "$host"
  # Skip IPv6 literals (masscan doesn’t support IPv6)
  elif [[ "$host" =~ : ]]; then
    :
  else
    resolve_host "$host"
  fi
done < "$CLEAN_HOSTS" \
| sort -u > "$IPS_FILE"

IP_COUNT=$(wc -l < "$IPS_FILE" | tr -d ' ')
if [[ "$IP_COUNT" -eq 0 ]]; then
  echo "[!] No IPv4 addresses resolved. Exiting."
  exit 0
fi
echo "[*] Resolved $IP_COUNT IPv4s."

# 3) Masscan
echo "[*] Running Masscan on $IP_COUNT IPs..."
MS_ARGS=(-iL "$IPS_FILE" -p "$PORTS" --rate "$RATE" -oL "$MASSCAN_LIST" -oX "$MASSCAN_XML" --wait 0)
if [[ -n "$IFACE" ]]; then
  MS_ARGS+=(-e "$IFACE")
fi
masscan "${MS_ARGS[@]}"

echo "[*] Masscan complete. Results:"
echo "    - List: $MASSCAN_LIST"
echo "    - XML : $MASSCAN_XML"

# 4) Build per-IP port lists from masscan list output and run Nmap -A
echo "[*] Parsing open ports and launching Nmap (-A) per host..."
# masscan -oL format lines: "open tcp 443 1.2.3.4  ... "
# Aggregate ports per IP
awk '
  tolower($1)=="open" && tolower($2) ~ /^(tcp|udp)$/ {
    proto=tolower($2); port=$3; ip=$4
    key=ip
    ports[key][port]=1
  }
  END {
    for (ip in ports) {
      first=1
      out=""
      for (port in ports[ip]) {
        out = out (first ? "" : ",") port
        first=0
      }
      print ip" "out
    }
  }
' "$MASSCAN_LIST" | sort -V > "$OUT_DIR/work/nmap_targets_with_ports.txt"

# Loop and run Nmap
while read -r ip ports; do
  [[ -z "$ip" || -z "$ports" ]] && continue
  safe_ip=$(echo "$ip" | tr '/:' '_')
  echo "    -> nmap $ip on ports: $ports"
  nmap -Pn -A -p "$ports" $NMAP_EXTRA "$ip" -oN "$OUT_DIR/nmap/$safe_ip.nmap" -oX "$OUT_DIR/nmap/$safe_ip.xml" || true
done < "$OUT_DIR/work/nmap_targets_with_ports.txt"

echo "[*] Done."
echo "Output directory: $OUT_DIR"
echo "  - Clean hosts:        $CLEAN_HOSTS"
echo "  - Resolved IPs:       $IPS_FILE"
echo "  - Masscan (.lst/.xml): $MASSCAN_LIST , $MASSCAN_XML"
echo "  - Nmap results per IP: $OUT_DIR/nmap/*.nmap (and .xml)"
