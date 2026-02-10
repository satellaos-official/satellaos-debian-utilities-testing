#!/bin/bash

echo "Version 1.4"
ICON_DIR="/usr/share/SatellaOS/application-icon"
APP_DIR="$HOME/.local/share/applications"

mkdir -p "$APP_DIR"

# ----- Select installation mode -----
echo "PWA Installation Mode:"
echo "1) Yes to all"
echo "2) No to all"
echo "3) Ask for each app (y/n)"
read -p "Your choice (1/2/3): " MODE

# ----- Browser selection -----
echo "Select browsers to use (separate with commas):"
echo "1) brave-browser"
echo "2) vivaldi-stable"
echo "3) google-chrome-stable"
echo "4) opera"
read -p "Your choice (e.g., 1,3): " BROWSER_SELECTION

# Convert selection into array
BROWSERS=()
IFS=',' read -ra CHOICES <<< "$BROWSER_SELECTION"
for choice in "${CHOICES[@]}"; do
    case "$choice" in
        1) BROWSERS+=("brave-browser") ;;
        2) BROWSERS+=("vivaldi-stable") ;;
        3) BROWSERS+=("google-chrome-stable") ;;
        4) BROWSERS+=("opera") ;;
        *) echo "Invalid selection: $choice" ;;
    esac
done

create_pwa() {
    NAME="$1"
    URL="$2"
    ICON_DARK="$3"
    ICON_LIGHT="$4"

    # --- Mode 1: Yes to all ---
    if [[ "$MODE" == "1" ]]; then
        ANSWER="y"
    elif [[ "$MODE" == "2" ]]; then
        ANSWER="n"
    else
        read -p "Install $NAME? (y/n): " ANSWER
    fi

    case "$ANSWER" in
        y|Y)
            read -p "Choose icon theme for $NAME (dark/light): " THEME
            if [[ "$THEME" == "light" ]]; then
                ICON="$ICON_LIGHT"
            else
                ICON="$ICON_DARK"
            fi

            for BROWSER in "${BROWSERS[@]}"; do
                FILE="$APP_DIR/${NAME,,}-${BROWSER}-pwa.desktop"
                cat <<EOF > "$FILE"
[Desktop Entry]
Name=$NAME ($BROWSER)
Exec=$BROWSER --app=$URL
Icon=$ICON_DIR/$ICON
Terminal=false
Type=Application
Categories=Network;WebBrowser;
StartupNotify=true
EOF
                echo "$NAME PWA created → $FILE"
            done
            ;;
        *)
            echo "$NAME skipped."
            ;;
    esac
}

# ------------------ PWA APPLICATION LIST ---------------------

create_pwa "Animecix"       "https://animecix.tv/"                       "Animecix.png"
create_pwa "YouTube"        "https://www.youtube.com/"                  "Youtube.png"
create_pwa "Gmail"          "https://mail.google.com/mail/"             "Gmail.png"
create_pwa "Google Drive"   "https://drive.google.com/drive/my-drive"   "Google-Drive.png"
create_pwa "Google Maps"    "https://www.google.com/maps/"              "Google-Maps.png"
create_pwa "Google Keep"    "https://keep.google.com/"                  "Google-Keep.png"
create_pwa "Copilot"        "https://copilot.microsoft.com/"            "copilot.png"
create_pwa "Gemini"         "https://gemini.google.com/"                "gemini.png"
create_pwa "DeepSeek"       "https://chat.deepseek.com/"                "deepseek.png"

# --- ChatGPT (dark + light icons) ---
create_pwa "ChatGPT" "https://chatgpt.com/" "chatgpt-dark.png" "chatgpt-light.png"

# --- GitHub (dark + light icons) ---
create_pwa "GitHub"  "https://github.com/"  "github-dark.png"  "github-light.png"

echo "--------------------------------------"
echo "PWA installation completed!"
