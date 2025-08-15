#!/bin/bash
set -e

TOOL_NAME="WebPen3"
INSTALL_DIR="$HOME/WebPen3"
TOOL_SCRIPT="webpen3" # without .sh
WORDLIST_DIR="$INSTALL_DIR/wordlists/SecLists"

echo "[*] $TOOL_NAME is being installed..."

# Create folder and copy the main script
mkdir -p "$INSTALL_DIR"
cp -r webpen3.sh "$INSTALL_DIR/$TOOL_SCRIPT"

# Make it executable
chmod +x "$INSTALL_DIR/$TOOL_SCRIPT"

# Add to PATH immediately for current session
export PATH="$INSTALL_DIR:$PATH"

# Add to .bashrc if not already present
if ! grep -q "$INSTALL_DIR" <<< "$PATH"; then
    echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$HOME/.bashrc"
fi

echo "[*] PATH updated. You can now run '$TOOL_SCRIPT' directly."

# Check for SecLists
SYSTEM_PATHS=(
    "/usr/share/wordlists/SecLists"
    "$HOME/seclists"
)

SEC_LIST_FOUND=false
for path in "${SYSTEM_PATHS[@]}"; do
    if [ -d "$path" ]; then
        echo "[*] SecLists found: $path"
        SEC_LIST_FOUND=true
        WORDLIST_DIR="$path"
        break
    fi
done

# Clone SecLists if not found
if [ "$SEC_LIST_FOUND" = false ]; then
    echo "[*] SecLists not found. Cloning to $WORDLIST_DIR..."
    mkdir -p "$WORDLIST_DIR"
    git clone https://github.com/danielmiessler/SecLists.git "$WORDLIST_DIR"
fi

echo "[*] Installation completed!"
echo "[*] Tool will use SecLists from: $WORDLIST_DIR"
