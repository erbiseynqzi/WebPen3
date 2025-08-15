#!/bin/bash
set -e

TOOL_NAME="WebPen3"
INSTALL_DIR="$HOME/WebPen3"
WORDLIST_DIR="$INSTALL_DIR/wordlists/SecLists"

echo "[*] Installing $TOOL_NAME wordlists..."

# Create directory
mkdir -p "$WORDLIST_DIR"

# Check if SecLists exists in common system paths
SYSTEM_PATHS=(
    "/usr/share/wordlists/SecLists"
    "$HOME/seclists"
)

SEC_LIST_FOUND=false
for path in "${SYSTEM_PATHS[@]}"; do
    if [ -d "$path" ]; then
        echo "[*] Found SecLists at: $path"
        SEC_LIST_FOUND=true
        WORDLIST_DIR="$path"
        break
    fi
done

# Clone SecLists if not found
if [ "$SEC_LIST_FOUND" = false ]; then
    echo "[*] SecLists not found. Cloning into $WORDLIST_DIR..."
    git clone https://github.com/danielmiessler/SecLists.git "$WORDLIST_DIR"
fi

echo "[*] Installation complete!"
echo "[*] Tool will use SecLists from: $WORDLIST_DIR"
