#!/bin/bash

# Check whiptail availability
if ! command -v whiptail &>/dev/null; then
    echo "whiptail not found. Installing..."
    sudo apt-get install -y whiptail 2>/dev/null || sudo pacman -S --noconfirm libnewt 2>/dev/null || {
        echo "Could not install whiptail. Please install it manually."
        exit 1
    }
fi

TITLE="PWA Installer v2.0"
W=70
H=20

# ----- Directories -----
APP_DIR="$HOME/.local/share/applications"
ICON_CACHE_DIR="$HOME/.local/share/icons/pwa-icons"
LEGACY_ICON_DIR="/usr/share/SatellaOS/application-icon"

mkdir -p "$APP_DIR"
mkdir -p "$ICON_CACHE_DIR"

# ----- Functions -----

get_premium_icon_url() {
    local DOMAIN="$1"
    case "$DOMAIN" in
        "youtube.com"|"www.youtube.com")
            echo "https://www.youtube.com/s/desktop/d743f786/img/favicon_144x144.png" ;;
        "netflix.com"|"www.netflix.com")
            echo "https://assets.nflxext.com/us/ffe/siteui/common/icons/nficon2016.png" ;;
        "twitter.com"|"x.com"|"www.twitter.com")
            echo "https://abs.twimg.com/icons/apple-touch-icon-192x192.png" ;;
        "facebook.com"|"www.facebook.com")
            echo "https://static.xx.fbcdn.net/rsrc.php/v3/y8/r/dF5SId3UHWd.png" ;;
        "instagram.com"|"www.instagram.com")
            echo "https://static.cdninstagram.com/rsrc.php/v3/yt/r/30PrGfR3xhB.png" ;;
        "github.com"|"www.github.com")
            echo "https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png" ;;
        "discord.com"|"www.discord.com")
            echo "https://discord.com/assets/f9bb9c4af2b9c32a2c5ee0014661546d.png" ;;
        "spotify.com"|"open.spotify.com")
            echo "https://open.spotifycdn.com/cdn/images/favicon32.b64ecc03.png" ;;
        "reddit.com"|"www.reddit.com")
            echo "https://www.redditstatic.com/desktop2x/img/favicon/android-icon-192x192.png" ;;
        "twitch.tv"|"www.twitch.tv")
            echo "https://static.twitchcdn.net/assets/favicon-32-e29e246c157142c94346.png" ;;
        "linkedin.com"|"www.linkedin.com")
            echo "https://static.licdn.com/sc/h/al2o9zrvru7aqj8e1x2rzsrca" ;;
        "gmail.com"|"mail.google.com")
            echo "https://ssl.gstatic.com/ui/v1/icons/mail/rfr/gmail.ico" ;;
        "copilot.microsoft.com")
            echo "https://www.microsoft.com/favicon.ico" ;;
        "claude.ai")
            echo "https://claude.ai/favicon.ico" ;;
        *) echo "" ;;
    esac
}

download_icon() {
    local DOMAIN="$1"
    local APP_NAME="$2"
    local ICON_PATH="$ICON_CACHE_DIR/${APP_NAME,,}.png"

    [[ -f "$ICON_PATH" ]] && { echo "$ICON_PATH"; return 0; }

    PREMIUM_URL=$(get_premium_icon_url "$DOMAIN")
    if [[ -n "$PREMIUM_URL" ]]; then
        if curl -s -f -L "$PREMIUM_URL" -o "$ICON_PATH" 2>/dev/null; then
            if [[ -s "$ICON_PATH" ]] && [[ $(stat -c%s "$ICON_PATH" 2>/dev/null) -gt 500 ]]; then
                echo "$ICON_PATH"; return 0
            fi
            rm -f "$ICON_PATH"
        fi
    fi

    if curl -s -f -L "https://logo.clearbit.com/$DOMAIN" -o "$ICON_PATH" 2>/dev/null; then
        if [[ -s "$ICON_PATH" ]] && [[ $(stat -c%s "$ICON_PATH" 2>/dev/null) -gt 1000 ]]; then
            echo "$ICON_PATH"; return 0
        fi
        rm -f "$ICON_PATH"
    fi

    if curl -s -f "https://www.google.com/s2/favicons?domain=$DOMAIN&sz=256" -o "$ICON_PATH" 2>/dev/null; then
        if [[ -s "$ICON_PATH" ]] && [[ $(stat -c%s "$ICON_PATH" 2>/dev/null) -gt 500 ]]; then
            echo "$ICON_PATH"; return 0
        fi
        rm -f "$ICON_PATH"
    fi

    if curl -s -f -L "https://$DOMAIN/favicon.ico" -o "$ICON_PATH" 2>/dev/null; then
        command -v convert &>/dev/null && convert "$ICON_PATH" -resize 256x256 "${ICON_PATH}.tmp.png" 2>/dev/null && mv "${ICON_PATH}.tmp.png" "$ICON_PATH"
        [[ -s "$ICON_PATH" ]] && { echo "$ICON_PATH"; return 0; }
        rm -f "$ICON_PATH"
    fi

    if curl -s -f "https://icons.duckduckgo.com/ip3/$DOMAIN.ico" -o "$ICON_PATH" 2>/dev/null; then
        [[ -s "$ICON_PATH" ]] && { echo "$ICON_PATH"; return 0; }
        rm -f "$ICON_PATH"
    fi

    if curl -s -f -L "https://$DOMAIN/apple-touch-icon.png" -o "$ICON_PATH" 2>/dev/null; then
        [[ -s "$ICON_PATH" ]] && { echo "$ICON_PATH"; return 0; }
        rm -f "$ICON_PATH"
    fi

    echo "web-browser"
    return 1
}

get_domain() {
    echo "$1" | sed -E 's|https?://([^/]+).*|\1|' | sed 's/^www\.//'
}

create_pwa() {
    local NAME="$1"
    local URL="$2"
    local ICON="$3"
    local BROWSERS=("${@:4}")

    for BROWSER in "${BROWSERS[@]}"; do
        FILE="$APP_DIR/${NAME,,}-${BROWSER}-pwa.desktop"
        cat <<EOF > "$FILE"
[Desktop Entry]
Version=1.0
Name=$NAME
Comment=Progressive Web App
Exec=$BROWSER --app=$URL
Icon=$ICON
Terminal=false
Type=Application
Categories=Network;WebBrowser;
StartupNotify=true
StartupWMClass=$NAME
EOF
    done
}

# ----- Browser Selection (whiptail checklist) -----
BROWSER_CHOICES=$(whiptail --title "$TITLE" \
    --checklist "Select browsers to use:\n(SPACE to select, ENTER to confirm)" \
    $H $W 5 \
    "brave-browser"       "Brave"         OFF \
    "vivaldi-stable"      "Vivaldi"       OFF \
    "google-chrome-stable" "Google Chrome" OFF \
    "opera"               "Opera"         OFF \
    "chromium-browser"    "Chromium"      OFF \
    3>&1 1>&2 2>&3)

if [[ $? -ne 0 ]] || [[ -z "$BROWSER_CHOICES" ]]; then
    whiptail --title "$TITLE" --msgbox "No browser selected. Exiting." 8 $W
    exit 1
fi

# Parse selected browsers into array
SELECTED_BROWSERS=()
for b in $BROWSER_CHOICES; do
    SELECTED_BROWSERS+=("$(echo "$b" | tr -d '"')")
done

whiptail --title "$TITLE" --msgbox "Selected browsers:\n${SELECTED_BROWSERS[*]}" 8 $W

# ----- App Category Lists -----
declare -A CATEGORY_APPS
CATEGORY_APPS["video"]="Animecix|https://animecix.tv/
Disney+|https://www.disneyplus.com/
Netflix|https://www.netflix.com/
Prime Video|https://www.primevideo.com/
Twitch|https://www.twitch.tv/
YouTube|https://www.youtube.com/"

CATEGORY_APPS["social"]="Discord|https://discord.com/app
Facebook|https://www.facebook.com/
Instagram|https://www.instagram.com/
LinkedIn|https://www.linkedin.com/
Reddit|https://www.reddit.com/
Telegram|https://web.telegram.org/
Twitter/X|https://twitter.com/
WhatsApp|https://web.whatsapp.com/"

CATEGORY_APPS["productivity"]="Asana|https://app.asana.com/
Gmail|https://mail.google.com/
Google Calendar|https://calendar.google.com/
Google Docs|https://docs.google.com/
Google Drive|https://drive.google.com/
Google Keep|https://keep.google.com/
Google Sheets|https://sheets.google.com/
Notion|https://www.notion.so/
Trello|https://trello.com/"

CATEGORY_APPS["ai"]="ChatGPT|https://chatgpt.com/
Claude|https://claude.ai/
DeepSeek|https://chat.deepseek.com/
Gemini|https://gemini.google.com/
GitHub Copilot|https://github.com/features/copilot
Microsoft Copilot|https://copilot.microsoft.com/
Perplexity|https://www.perplexity.ai/"

CATEGORY_APPS["dev"]="CodePen|https://codepen.io/
GitHub|https://github.com/
GitLab|https://gitlab.com/
Replit|https://replit.com/
Stack Overflow|https://stackoverflow.com/
Vercel|https://vercel.com/"

CATEGORY_APPS["music"]="Apple Music|https://music.apple.com/
SoundCloud|https://soundcloud.com/
Spotify|https://open.spotify.com/
YouTube Music|https://music.youtube.com/"

CATEGORY_APPS["maps"]="Google Maps|https://www.google.com/maps/
OpenStreetMap|https://www.openstreetmap.org/"

install_from_list() {
    local CATEGORY="$1"
    local CATEGORY_LABEL="$2"
    local APPS_RAW="${CATEGORY_APPS[$CATEGORY]}"

    # Build checklist items
    local CHECKLIST_ARGS=()
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        APP_NAME=$(echo "$line" | cut -d'|' -f1)
        CHECKLIST_ARGS+=("$APP_NAME" "" OFF)
    done <<< "$APPS_RAW"

    SELECTED=$(whiptail --title "$TITLE - $CATEGORY_LABEL" \
        --checklist "Select applications to install:" \
        $H $W 10 \
        "${CHECKLIST_ARGS[@]}" \
        3>&1 1>&2 2>&3) || return 0

    [[ -z "$SELECTED" ]] && return 0

    # Progress gauge
    local TOTAL=$(echo "$SELECTED" | wc -w)
    local COUNT=0

    {
        while IFS= read -r line; do
            [[ -z "$line" ]] && continue
            APP_NAME=$(echo "$line" | cut -d'|' -f1)
            APP_URL=$(echo "$line" | cut -d'|' -f2)

            # Check if this app was selected
            if echo "$SELECTED" | grep -q "\"$APP_NAME\""; then
                DOMAIN=$(get_domain "$APP_URL")
                ICON=$(download_icon "$DOMAIN" "$APP_NAME")
                create_pwa "$APP_NAME" "$APP_URL" "$ICON" "${SELECTED_BROWSERS[@]}"
                ((COUNT++))
                echo $(( COUNT * 100 / TOTAL ))
                echo "XXX"
                echo "Installed: $APP_NAME ($COUNT/$TOTAL)"
                echo "XXX"
            fi
        done <<< "$APPS_RAW"
    } | whiptail --title "$TITLE" --gauge "Installing PWAs..." 8 $W 0

    whiptail --title "$TITLE" --msgbox "✓ Selected applications installed successfully!" 8 $W
}

install_custom_pwa() {
    APP_NAME=$(whiptail --title "$TITLE - Custom PWA" \
        --inputbox "Enter application name:" 8 $W \
        3>&1 1>&2 2>&3) || return 0

    [[ -z "$APP_NAME" ]] && return 0

    APP_URL=$(whiptail --title "$TITLE - Custom PWA" \
        --inputbox "Enter URL (e.g. https://example.com):" 8 $W \
        3>&1 1>&2 2>&3) || return 0

    [[ -z "$APP_URL" ]] && return 0
    [[ ! "$APP_URL" =~ ^https?:// ]] && APP_URL="https://$APP_URL"

    DOMAIN=$(get_domain "$APP_URL")
    ICON=$(download_icon "$DOMAIN" "$APP_NAME")
    create_pwa "$APP_NAME" "$APP_URL" "$ICON" "${SELECTED_BROWSERS[@]}"

    whiptail --title "$TITLE" --msgbox "✓ '$APP_NAME' installed successfully!\nURL: $APP_URL" 8 $W
}

batch_install() {
    while true; do
        install_custom_pwa
        whiptail --title "$TITLE" --yesno "Would you like to add another PWA?" 8 $W || break
    done
}

# ----- Main Menu Loop -----
while true; do
    CHOICE=$(whiptail --title "$TITLE" \
        --menu "Select a category:" $H $W 10 \
        "1" "🎬  Video & Streaming" \
        "2" "💬  Social Media" \
        "3" "📋  Productivity & Office" \
        "4" "🤖  AI Tools" \
        "5" "💻  Developer Tools" \
        "6" "🎵  Music & Audio" \
        "7" "🗺️   Maps & Navigation" \
        "8" "⚙️   Custom PWA (Enter URL)" \
        "9" "📦  Batch Custom PWA Install" \
        "0" "🚪  Exit" \
        3>&1 1>&2 2>&3) || break

    case "$CHOICE" in
        1) install_from_list "video"        "Video & Streaming" ;;
        2) install_from_list "social"       "Social Media" ;;
        3) install_from_list "productivity" "Productivity & Office" ;;
        4) install_from_list "ai"           "AI Tools" ;;
        5) install_from_list "dev"          "Developer Tools" ;;
        6) install_from_list "music"        "Music & Audio" ;;
        7) install_from_list "maps"         "Maps & Navigation" ;;
        8) install_custom_pwa ;;
        9) batch_install ;;
        0) break ;;
    esac
done

whiptail --title "$TITLE" --msgbox "Thank you for using PWA Installer!" 8 $W