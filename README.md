# Usefull web app stuff

## OWASP Checklist
- [OWASP WSTG Testing guide](https://github.com/b1g-b33f/Web-app/blob/main/owasp_checklist.md) 

## Useful Scripts
[zone_transfer](https://github.com/b1g-b33f/Web-app/blob/main/zone_transfer.sh)  
- strip domain names when performing zone transfer with dig. Output dig axfr to a txt file called dns.txt for it to work.

[wasa](https://github.com/b1g-b33f/Web-app/blob/main/wasa.sh)
- Simple reconnaissance & scanning wrapper: runs a full Nmap port/service scan and targeted HTTP NSE checks, then performs TLS/fingerprint scans (sslscan), web content scans (nikto), template-based vuln checks (nuclei), and optional dnsrecon DNS enumeration (domain-only).
Outputs are saved to a dated file/dir (human-readable + Nmap -oA/Nuclei JSON), and the script checks for missing tools and skips scans gracefully—keeps behavior straightforward and non-intrusive for fast triage.

[file_ext_bypass](https://github.com/b1g-b33f/Web-app/blob/main/file_ext_bypass.sh)
- Creates worlist for file extension bypass fuzzing. Change extensions as needed.

[recon](https://github.com/b1g-b33f/Web-app/blob/main/osint.sh)
- A compact reconnaissance helper that enumerates subdomains (subfinder, assetfinder — optional amass for deeper DNS enumeration), probes live hosts with httprobe, takes screenshots using gowitness v3, and resolves live hosts to IPv4 addresses. Outputs are organized per-domain (info, subdomains, screenshots) and it produces a unique_ips.txt ready for masscan/nmap.
- Comment and uncomment Amass, massscan, nmap as needed
- Run against multiple targets with `while read -r d; do ./recon.sh "$d"; done < hosts.txt`

## Wordlists

[25 LFI Paramters](https://github.com/b1g-b33f/Web-app/blob/main/25-LFI-Paramters.txt)
- LFI paramters short list

[Pega Parameters](https://github.com/b1g-b33f/Web-app/blob/main/pega-parameters.txt)
- List of Pega parameters

## Payloads
[xxe in svg](https://github.com/b1g-b33f/Web-app/blob/main/xxe.svg)
