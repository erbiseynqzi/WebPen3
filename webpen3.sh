#!/bin/bash
# WEBPEN3 - Web Pentest Automation Tool (Bash, Multi-threaded, Colorful UI)
# by erbiseynqzi (Turqay Memmedli)

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[1;35m'
NC='\033[0m'

# --- Banner ---
echo -e "${GREEN}"
echo "<!-- ██╗    ██╗███████╗██████╗ ██████╗ ███████╗███╗   ██╗██████╗  -->"
echo "<!-- ██║    ██║██╔════╝██╔══██╗██╔══██╗██╔════╝████╗  ██║╚════██╗ -->"
echo "<!-- ██║ █╗ ██║█████╗  ██████╔╝██████╔╝█████╗  ██╔██╗ ██║ █████╔╝ -->"
echo "<!-- ██║███╗██║██╔══╝  ██╔══██╗██╔═══╝ ██╔══╝  ██║╚██╗██║ ╚═══██╗ -->"
echo "<!-- ╚███╔███╔╝███████╗██████╔╝██║     ███████╗██║ ╚████║██████╔╝ -->"
echo "<!--  ╚══╝╚══╝ ╚══════╝╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═══╝╚═════╝  -->"
echo -e  "${NC}"
echo -e  "${MAGENTA}"
echo "                                                    by erbiseynqzi"
echo "                                                  (Turqay Memmedli)"
echo -e "${NC}"

# --- Inputs ---
read -e -p "[*] Enter target domain: " TARGET
while true; do
    read -e -p "[*] Enter path to subdomain wordlist: " SUB_WORDLIST
    [ -f "$SUB_WORDLIST" ] && break
    echo -e "${RED}Please provide a valid subdomain wordlist.${NC}"
done
while true; do
    read -e -p "[*] Enter path to directory wordlist: " DIR_WORDLIST
    [ -f "$DIR_WORDLIST" ] && break
    echo -e "${RED}Please provide a valid directory wordlist.${NC}"
done
read -p "[*] Threads for subdomain scan (default 50): " SUB_T
SUB_T=${SUB_T:-50}
read -p "[*] Threads for directory scan (default 50): " DIR_T
DIR_T=${DIR_T:-50}
read -e -p "[*] Output file: " OUTPUT_FILE
if [ -z "$OUTPUT_FILE" ]; then
    echo -e "${RED}Output file is required!${NC}"
    exit 1
fi
> "$OUTPUT_FILE"

# --- Resolve IP ---
IP=$(dig +short "$TARGET" | head -n1)
echo -e "\n${GREEN}[+] Target: $TARGET${NC} (${CYAN}IP: $IP${NC})"

# --- Write IP to output file immediately ---
echo "$IP" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# --- Temp files ---
SUBS_FOUND=$(mktemp)
COUNT_FILE=$(mktemp)

# --- Helpers ---
show_progress() {
    local progress=$1
    local total=$2
    local width=40
    local done=$((progress * width / total))
    local left=$((width - done))
    printf "\rProgress: ["
    printf "%0.s#" $(seq 1 $done)
    printf "%0.s-" $(seq 1 $left)
    printf "] %d/%d" "$progress" "$total"
}

color_status() {
    local code=$1
    if [[ "$code" =~ ^2 ]]; then echo -e "${GREEN}$code${NC}"
    elif [[ "$code" =~ ^3 ]]; then echo -e "${BLUE}$code${NC}"
    elif [[ "$code" =~ ^4 ]]; then echo -e "${YELLOW}$code${NC}"
    elif [[ "$code" =~ ^5 ]]; then echo -e "${RED}$code${NC}"
    else echo "$code"; fi
}

http_status() {
    local host="$1"
    curl -ksL -H "Host: $host" --connect-timeout 3 --max-time 5 -o /dev/null -w "%{http_code}" "https://$host"
}

export TARGET SUBS_FOUND COUNT_FILE OUTPUT_FILE
export -f show_progress color_status http_status

# --- Subdomain scan ---
echo -e "\n${YELLOW}[+] Enumerating subdomains...${NC}"
TOTAL=$(wc -l < "$SUB_WORDLIST")
> "$COUNT_FILE"

# Scan main domain
MAIN_STATUS=$(http_status "$TARGET")
if [[ "$MAIN_STATUS" =~ ^(200|301|302)$ ]]; then
    echo "$TARGET" >> "$SUBS_FOUND"
    echo "$TARGET [$MAIN_STATUS]" >> "$OUTPUT_FILE"
    echo -e "[+] Subdomain found: $TARGET (Status: $(color_status $MAIN_STATUS))"
fi

# Scan subdomains in parallel
cat "$SUB_WORDLIST" | xargs -I{} -P $SUB_T bash -c '
DOMAIN="{}.'"$TARGET"'"
STATUS=$(http_status "$DOMAIN")
if [[ "$STATUS" =~ ^(200|301|302)$ ]]; then
    echo "$DOMAIN" >> "$SUBS_FOUND"
    echo "$DOMAIN [$STATUS]" >> "'"$OUTPUT_FILE"'"
    echo -e "[+] Subdomain found: $DOMAIN (Status: $(color_status $STATUS))"
fi
(
  flock -x 200
  COUNT=$(( $(cat "'"$COUNT_FILE"'" 2>/dev/null || echo 0) + 1 ))
  echo $COUNT > "'"$COUNT_FILE"'"
  show_progress $COUNT '"$TOTAL"'
) 200>/tmp/progress_sub.lock
'
wait
echo ""

mapfile -t SUBS < <(sort -u "$SUBS_FOUND")

# Add a blank line between subdomains and directory section in output
echo "" >> "$OUTPUT_FILE"

# --- Directory scan ---
echo -e "\n${YELLOW}[+] Scanning directories...${NC}"
declare -A DIR_RESULTS

for DOMAIN in "${SUBS[@]}"; do
    DIRS_FOUND=$(mktemp)
    TOTAL_DIRS=$(wc -l < "$DIR_WORDLIST")
    > "$COUNT_FILE"

    export DOMAIN DIRS_FOUND TOTAL_DIRS COUNT_FILE
    cat "$DIR_WORDLIST" | xargs -I{} -P $DIR_T bash -c '
URL="https://'"$DOMAIN"'/{}"
STATUS=$(curl -ksL -H "Host: '"$DOMAIN"'" --connect-timeout 3 --max-time 5 -o /dev/null -w "%{http_code}" "$URL")
if [[ "$STATUS" =~ ^(200|301|302|401|403)$ ]]; then
    echo "/{} [$STATUS]" >> "'"$DIRS_FOUND"'"
fi
(
  flock -x 201
  COUNT=$(( $(cat "'"$COUNT_FILE"'" 2>/dev/null || echo 0) + 1 ))
  echo $COUNT > "'"$COUNT_FILE"'"
  show_progress $COUNT '"$TOTAL_DIRS"'
) 201>/tmp/progress_dir.lock
'
    wait
    echo ""

    DIR_LINE="$(sort -u "$DIRS_FOUND" | paste -sd ' ; ' -)"
    DIR_RESULTS["$DOMAIN"]="$DIR_LINE"

    # Real-time write to output file with a blank line after each subdomain
    if [ -n "$DIR_LINE" ]; then
        echo "$DOMAIN => $DIR_LINE" >> "$OUTPUT_FILE"
    else
        echo "$DOMAIN =>" >> "$OUTPUT_FILE"
    fi
    echo "" >> "$OUTPUT_FILE"  # blank line between domains

    rm -f "$DIRS_FOUND"
done

# --- Display results to console (no blank lines) ---
echo -e "\n${GREEN}[+] Scan completed. Final Results (also saved to file):${NC}\n"
echo -e "${CYAN}Target IP: $IP${NC}\n"

for line in $(sort -u "$SUBS_FOUND"); do
    STATUS=$(http_status "$line")
    echo -e "$line [$STATUS]"
done
echo ""
for DOMAIN in "${SUBS[@]}"; do
    echo "$DOMAIN => ${DIR_RESULTS[$DOMAIN]}"
done

echo -e "${GREEN}[+] Results saved to $OUTPUT_FILE${NC}"

# --- Cleanup ---
rm -f "$SUBS_FOUND" "$COUNT_FILE" /tmp/progress_sub.lock /tmp/progress_dir.lock
