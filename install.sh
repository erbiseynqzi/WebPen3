#!/bin/bash
set -e

TOOL_NAME="WebPen3"
INSTALL_DIR="$HOME/WebPen3"
TOOL_SCRIPT="webpen3" # artıq .sh yazmırıq
WORDLIST_DIR="$INSTALL_DIR/wordlists/SecLists"

echo "[*] $TOOL_NAME quraşdırılır..."

# Qovluq yarat və skripti kopyala
mkdir -p "$INSTALL_DIR"
cp -r webpen3.sh "$INSTALL_DIR/$TOOL_SCRIPT"

# İcazə ver icra üçün
chmod +x "$INSTALL_DIR/$TOOL_SCRIPT"

# PATH-ə əlavə et (əgər yoxdursa)
if ! grep -q "$INSTALL_DIR" <<< "$PATH"; then
    echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$HOME/.bashrc"
    export PATH="$INSTALL_DIR:$PATH"
fi

echo "[*] PATH yeniləndi. İndi sadəcə '$TOOL_SCRIPT' yazaraq işlədə bilərsən."

# SecLists yoxlaması
SYSTEM_PATHS=(
    "/usr/share/wordlists/SecLists"
    "$HOME/seclists"
)

SEC_LIST_FOUND=false
for path in "${SYSTEM_PATHS[@]}"; do
    if [ -d "$path" ]; then
        echo "[*] SecLists tapıldı: $path"
        SEC_LIST_FOUND=true
        WORDLIST_DIR="$path"
        break
    fi
done

# Əgər tapılmayıbsa, klonla
if [ "$SEC_LIST_FOUND" = false ]; then
    echo "[*] SecLists tapılmadı. $WORDLIST_DIR qovluğuna klonlanır..."
    mkdir -p "$WORDLIST_DIR"
    git clone https://github.com/danielmiessler/SecLists.git "$WORDLIST_DIR"
fi

echo "[*] Quraşdırma tamamlandı!"
echo "[*] Tool SecLists-i istifadə edəcək: $WORDLIST_DIR"
