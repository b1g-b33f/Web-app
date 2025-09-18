#!/bin/bash

domain=$1
RED="\033[1;31m"
RESET="\033[0m"

info_path=$domain/info
subdomain_path=$domain/subdomains
screenshot_path=$domain/screenshots

if [ ! -d "$domain" ];then
    mkdir $domain
fi

if [ ! -d "$info_path" ];then
    mkdir $info_path
fi

if [ ! -d "$subdomain_path" ];then
    mkdir $subdomain_path
fi

if [ ! -d "$screenshot_path" ];then
    mkdir $screenshot_path
fi

echo -e "${RED} [+] Checkin' who it is...${RESET}"
whois $1 > $info_path/whois.txt

echo -e "${RED} [+] Launching subfinder...${RESET}"
subfinder -d $domain > $subdomain_path/found.txt

echo -e "${RED} [+] Running assetfinder...${RESET}"
assetfinder $domain | grep $domain >> $subdomain_path/found.txt

#echo -e "${RED} [+] Running Amass. This could take a while...${RESET}"
#amass enum -d $domain >> $subdomain_path/found.txt

echo -e "${RED} [+] Checking what's alive...${RESET}"
cat "$subdomain_path/found.txt" | grep "$domain" | sort -u | httprobe -prefer-https | tee "$subdomain_path/alive.txt"

echo -e "${RED} [+] Taking dem screenshotz...${RESET}"
gowitness scan file -f "$subdomain_path/alive.txt" \
                   --screenshot-path "$screenshot_path" \
                   --no-http \
                   --write-screenshots \
                   --threads 20

# --- START: minimal IP extraction for masscan/nmap ---
echo -e "${RED} [+] Resolving hostnames to IPs...${RESET}"
# produce unique IPv4 list at subdomains/unique_ips.txt
sed -E 's#^https?://##; s#/.*$##' "$subdomain_path/alive.txt" | sort -u | \
while read -r host; do
  ip=$(dig +short "$host" @1.1.1.1 | grep -E '^[0-9]+\.' | head -n1)
  [ -n "$ip" ] && echo "$ip"
done | sort -u > "$subdomain_path/unique_ips.txt"
# --- END: minimal IP extraction ---

# Massscan / nmap quick examples (commented — uncomment to run)
# Fast wide scan with masscan (adjust rate, ports to taste)
# masscan -iL "$subdomain_path/unique_ips.txt" -p1-65535 --rate 1000 -oL "$subdomain_path/masscan.out"

# Faster targeted masscan example (common web ports)
# masscan -iL "$subdomain_path/unique_ips.txt" -p80,443,8080,8443 --rate 1000 -oL "$subdomain_path/masscan_web.out"

# Follow-up nmap scan against the discovered hosts (example: service version on top ports)
# nmap -iL "$subdomain_path/unique_ips.txt" -sV --top-ports 100 -oA "$subdomain_path/nmap_top100"
