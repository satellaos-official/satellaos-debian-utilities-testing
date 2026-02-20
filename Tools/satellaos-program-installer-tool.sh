#!/bin/bash

set -e
set -u

echo "Version 5.3.0"
echo "--------------------------------------"
echo " Available Programs"
echo "--------------------------------------"
echo ""
echo "🌐 Web Browsers"
echo "  1  - Brave Browser (Deb)"
echo "  2  - Chromium Browser (Deb)"
echo "  3  - Firefox ESR (Deb)"
echo "  4  - Firefox (Portable)"
echo "  5  - Floorp Browser (Portable)"
echo "  6  - Google Chrome (Deb)"
echo "  7  - Opera Stable (Deb)"
echo "  8  - Tor Browser (Deb)"
echo "  9  - Vivaldi Stable (Deb)"
echo "  10 - Waterfox (Portable)"
echo "  11 - Zen Browser (Portable)"
echo ""
echo "🖼️  Graphics & Images"
echo "  12 - GIMP (Deb)"
echo "  13 - GIMP (Flatpak)"
echo "  14 - Inkscape (Deb)"
echo "  15 - Krita (Flatpak)"
echo "  16 - Pinta (Flatpak)"
echo "  17 - Ristretto (Deb)"
echo ""
echo "🗂️  Disk & Storage Management"
echo "  18 - Disk Usage Analyzer - baobab (Deb)"
echo "  19 - GParted (Deb)"
echo "  20 - GNOME Disk Utility (Deb)"
echo "  21 - KDiskMark (Deb)"
echo "  22 - KDiskMark (Flatpak)"
echo "  23 - Mintstick (Deb)"
echo "  24 - PowerISO (Flatpak)"
echo ""
echo "📦 Software & System Management"
echo "  25 - BleachBit (Deb)"
echo "  26 - Flatseal (Flatpak)"
echo "  27 - Gnome Software (Deb)"
echo "  28 - Grub Customizer (Deb)"
echo "  29 - MenuLibre (Deb)"
echo "  30 - Mission Center (Flatpak)"
echo "  31 - Timeshift (Deb)"
echo ""
echo "⬇️  Download & File Sharing"
echo "  32 - Free Download Manager (Deb)"
echo "  33 - LocalSend (Deb)"
echo "  34 - LocalSend (Flatpak)"
echo "  35 - qBittorrent (Deb)"
echo ""
echo "🛠️  Developer Tools"
echo "  36 - Sublime Text (Deb)"
echo "  37 - VS Code (Deb)"
echo "  38 - VirtualBox [Debian 13 (Deb)]"
echo "  39 - WineHQ Stable [Debian 13 (Deb)]"
echo ""
echo "🎵 Media"
echo "  40 - OBS Studio (Flatpak)"
echo "  41 - VLC (Deb)"
echo ""
echo "🏢 Office & Productivity"
echo "  42 - Galculator (Deb)"
echo "  43 - Gucharmap (Deb)"
echo "  44 - Libre Office (Deb)"
echo "  45 - Obsidian (Flatpak)"
echo "  46 - Screen Keyboard - Onboard (Deb)"
echo "  47 - Thunderbird (Deb)"
echo ""
echo "🎮 Gaming"
echo "  48 - Steam (Deb)"
echo "  49 - Heroic Games Launcher (Deb)"
echo "  50 - Heroic Games Launcher - recommended (Flatpak)"
echo "  51 - Lutris (Deb)"
echo "  52 - Lutris - recommended (Flatpak)"
echo ""
echo "🔒 Security & Network"
echo "  53 - Bitwarden (Flatpak)"
echo "  54 - KeePassXC (Deb)"
echo "  55 - Warp VPN"
echo "  56 - Wireshark (Deb)"
echo ""
echo "💬 Communication"
echo "  57 - Discord (Flatpak)"
echo "  58 - Signal (Deb)"
echo "  59 - Telegram (Flatpak)"
echo ""
echo "--------------------------------------"

PKG_DIR=$(mktemp -d /tmp/satellaos-installer-XXXXXX)
trap 'rm -rf "$PKG_DIR"' EXIT

echo "Enter the numbers of the programs you want to install."
echo "Example: 1 3 5 14 21"
echo "Leave empty to install nothing."
read -r -p "Your selection (separate with spaces): " SELECTIONS
SELECTIONS="${SELECTIONS//,/}"

# Remove duplicates
SELECTIONS=$(echo "$SELECTIONS" | tr ' ' '\n' | sort -u)

# Empty input check
if [[ -z "$SELECTIONS" ]]; then
    echo "No selection made. Exiting."
    exit 0
fi

# ── 1 ── Brave Browser
install_1() {
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
        https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources \
        https://brave-browser-apt-release.s3.brave.com/brave-browser.sources
    sudo apt update
    sudo apt install -y brave-browser
}

# ── 2 ── Chromium Browser
install_2() {
    sudo apt install -y chromium
}

# ── 3 ── Firefox ESR
install_3() {
    sudo apt install -y firefox-esr
}

<<<<<<< HEAD
install_3() { # Firefox
=======
# ── 4 ── Firefox (Portable)
install_4() {
>>>>>>> e9cccf8 (Update full project snapshot)
    LATEST_VERSION=$(curl -s https://product-details.mozilla.org/1.0/firefox_versions.json | grep -Po '"LATEST_FIREFOX_VERSION":\s*"\K[^"]+')
    FILE="$PKG_DIR/firefox-$LATEST_VERSION.tar.xz"
    URL="https://ftp.mozilla.org/pub/firefox/releases/$LATEST_VERSION/linux-x86_64/en-US/firefox-$LATEST_VERSION.tar.xz"

    wget -O "$FILE" "$URL"
    sudo rm -rf /opt/firefox
    tar -xf "$FILE" -C "$PKG_DIR"
    sudo mv "$PKG_DIR/firefox" /opt/firefox
    sudo ln -sf /opt/firefox/firefox /usr/local/bin/firefox
<<<<<<< HEAD
    
=======

>>>>>>> e9cccf8 (Update full project snapshot)
    sudo tee /usr/share/applications/firefox.desktop > /dev/null <<EOL
[Desktop Entry]
Version=1.0
Name=Firefox
Comment=Mozilla Firefox Web Browser
Exec=/opt/firefox/firefox %u
Icon=/opt/firefox/browser/chrome/icons/default/default128.png
Terminal=false
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/vnd.mozilla.xul+xml;application/rss+xml;application/rdf+xml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
StartupWMClass=firefox
EOL
    update-desktop-database /usr/share/applications 2>/dev/null || true
    xdg-mime default firefox.desktop x-scheme-handler/http
    xdg-mime default firefox.desktop x-scheme-handler/https
    xdg-settings set default-web-browser firefox.desktop
}

<<<<<<< HEAD
install_4() { # Floorp Browser
=======
# ── 5 ── Floorp Browser (Portable)
install_5() {
>>>>>>> e9cccf8 (Update full project snapshot)
    REPO="Floorp-Projects/Floorp"
    ASSET_NAME="floorp-linux-x86_64.tar.xz"

    LATEST_TAG=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" \
        | grep -oP '"tag_name": "\K(.*)(?=")')
    [ -z "$LATEST_TAG" ] && return 1

    FILE="$PKG_DIR/floorp.tar.xz"
    DOWNLOAD_URL="https://github.com/$REPO/releases/download/$LATEST_TAG/$ASSET_NAME"
    wget -O "$FILE" "$DOWNLOAD_URL"

    sudo rm -rf /opt/floorp
    tar -xf "$FILE" -C "$PKG_DIR"
    DIR_NAME=$(tar -tf "$FILE" | head -1 | cut -f1 -d"/")
    sudo mv "$PKG_DIR/$DIR_NAME" /opt/floorp
    sudo ln -sf /opt/floorp/floorp /usr/local/bin/floorp

    ICON_PATH="/opt/floorp/browser/chrome/icons/default/default128.png"
<<<<<<< HEAD
    
=======

>>>>>>> e9cccf8 (Update full project snapshot)
    sudo tee /usr/share/applications/floorp.desktop > /dev/null <<EOL
[Desktop Entry]
Version=1.0
Name=Floorp Browser
Comment=Floorp Web Browser
Exec=/opt/floorp/floorp %u
Icon=$ICON_PATH
Terminal=false
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
StartupWMClass=floorp
EOL

    update-desktop-database /usr/share/applications 2>/dev/null || true
    xdg-mime default floorp.desktop x-scheme-handler/http
    xdg-mime default floorp.desktop x-scheme-handler/https
    xdg-settings set default-web-browser floorp.desktop
}

# ── 6 ── Google Chrome
install_6() {
    wget -O "$PKG_DIR/google-chrome-stable_current_amd64.deb" \
        https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo apt install -y "$PKG_DIR/google-chrome-stable_current_amd64.deb"
}

# ── 7 ── Opera Stable
install_7() {
    wget -qO- https://deb.opera.com/archive.key | gpg --dearmor | sudo tee /usr/share/keyrings/opera-browser.gpg > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/opera-browser.gpg] https://deb.opera.com/opera-stable/ stable non-free" \
        | sudo tee /etc/apt/sources.list.d/opera-archive.list
    sudo apt-get update
    sudo apt-get install -y opera-stable
}

<<<<<<< HEAD
install_8() { # Zen Browser
=======
# ── 8 ── Tor Browser
install_8() {
    # Resmi Debian repo üzerinden (trixie/sid için)
    sudo apt install -y torbrowser-launcher
    torbrowser-launcher
}

# ── 9 ── Vivaldi Stable
install_9() {
    wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub \
        | gpg --dearmor | sudo tee /usr/share/keyrings/vivaldi-browser.gpg > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/vivaldi-browser.gpg arch=$(dpkg --print-architecture)] https://repo.vivaldi.com/archive/deb/ stable main" \
        | sudo tee /etc/apt/sources.list.d/vivaldi-archive.list
    sudo apt update
    sudo apt install -y vivaldi-stable
}

# ── 10 ── Waterfox (Portable)
install_10() {
    WATERFOX_VERSION="6.5.0"
    FILE="$PKG_DIR/waterfox-$WATERFOX_VERSION.tar.bz2"
    URL="https://cdn.waterfox.com/waterfox/releases/$WATERFOX_VERSION/Linux_x86_64/waterfox-$WATERFOX_VERSION.tar.bz2"

    wget -O "$FILE" "$URL"
    sudo rm -rf /opt/waterfox
    tar -xjf "$FILE" -C "$PKG_DIR"
    sudo mv "$PKG_DIR/waterfox" /opt/waterfox
    sudo ln -sf /opt/waterfox/waterfox /usr/local/bin/waterfox

    ICON_PATH="/opt/waterfox/browser/chrome/icons/default/default128.png"

    sudo tee /usr/share/applications/waterfox.desktop > /dev/null <<EOL
[Desktop Entry]
Version=1.0
Name=Waterfox
Comment=Waterfox Web Browser
Exec=/opt/waterfox/waterfox %u
Icon=$ICON_PATH
Terminal=false
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
StartupWMClass=waterfox
EOL

    update-desktop-database /usr/share/applications 2>/dev/null || true
    xdg-mime default waterfox.desktop x-scheme-handler/http
    xdg-mime default waterfox.desktop x-scheme-handler/https
    xdg-settings set default-web-browser waterfox.desktop
}

# ── 11 ── Zen Browser (Portable)
install_11() {
>>>>>>> e9cccf8 (Update full project snapshot)
    FILE="$PKG_DIR/zen.linux-x86_64.tar.xz"
    wget -O "$FILE" https://github.com/zen-browser/desktop/releases/latest/download/zen.linux-x86_64.tar.xz

    sudo rm -rf /opt/zen-browser
    tar -xf "$FILE" -C "$PKG_DIR"
    sudo mv "$PKG_DIR/zen" /opt/zen-browser

    BIN_PATH="/opt/zen-browser/zen"
    sudo ln -sf "$BIN_PATH" /usr/local/bin/zen-browser

    ICON_PATH="/opt/zen-browser/browser/chrome/icons/default/default128.png"

    sudo tee /usr/share/applications/zen-browser.desktop > /dev/null <<EOL
[Desktop Entry]
Version=1.0
Name=Zen Browser
Comment=Zen Web Browser
Exec=$BIN_PATH %u
Icon=$ICON_PATH
Terminal=false
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
StartupWMClass=zen
EOL

    update-desktop-database /usr/share/applications 2>/dev/null || true
    xdg-mime default zen-browser.desktop x-scheme-handler/http
    xdg-mime default zen-browser.desktop x-scheme-handler/https
    xdg-settings set default-web-browser zen-browser.desktop
}

# ── 12 ── GIMP (Deb)
install_12() {
    sudo apt install -y gimp
}

# ── 13 ── GIMP (Flatpak)
install_13() {
    flatpak install -y --noninteractive flathub org.gimp.GIMP
}

# ── 14 ── Inkscape (Deb)
install_14() {
    sudo apt install -y inkscape
}

# ── 15 ── Krita (Flatpak)
install_15() {
    flatpak install -y --noninteractive flathub org.kde.krita
}

# ── 16 ── Pinta (Flatpak)
install_16() {
    flatpak install -y --noninteractive flathub com.github.PintaProject.Pinta
}

# ── 17 ── Ristretto (Deb)
install_17() {
    sudo apt install -y ristretto \
        libwebp7 \
        tumbler \
        tumbler-plugins-extra \
        webp-pixbuf-loader
}

# ── 18 ── Disk Usage Analyzer - baobab
install_18() {
    sudo apt install -y baobab
}

# ── 19 ── GParted
install_19() {
    sudo apt install -y gparted
}

# ── 20 ── GNOME Disk Utility
install_20() {
    sudo apt install -y gnome-disk-utility
}

# ── 21 ── KDiskMark (Deb)
install_21() {
    KDISKMARK_URL=$(curl -s https://api.github.com/repos/JonMagon/KDiskMark/releases/latest \
        | grep "browser_download_url" | grep "amd64.deb" | cut -d '"' -f 4)
    KDISKMARK_FILE=$(basename "$KDISKMARK_URL")
    wget -O "$PKG_DIR/$KDISKMARK_FILE" "$KDISKMARK_URL"
    sudo apt install -y "$PKG_DIR/$KDISKMARK_FILE"
}

# ── 22 ── KDiskMark (Flatpak)
install_22() {
    flatpak install -y --noninteractive flathub io.github.jonmagon.kdiskmark
}

# ── 23 ── Mintstick
install_23() {
    sudo apt install -y mintstick
}

# ── 24 ── PowerISO (Flatpak)
install_24() {
    flatpak install -y --noninteractive flathub com.poweriso.PowerISO
}

# ── 25 ── BleachBit (Deb)
install_25() {
    sudo apt install -y bleachbit
}

# ── 26 ── Flatseal (Flatpak)
install_26() {
    flatpak install -y --noninteractive flathub com.github.tchx84.Flatseal
}

# ── 27 ── Gnome Software
install_27() {
    sudo apt install -y gnome-software gnome-software-plugin-flatpak
}

# ── 28 ── Grub Customizer
install_28() {
    sudo apt install -y grub-customizer
}

# ── 29 ── MenuLibre
install_29() {
    sudo apt install -y menulibre
}

# ── 30 ── Mission Center (Flatpak)
install_30() {
    flatpak install -y --noninteractive flathub io.missioncenter.MissionCenter
}

# ── 31 ── Timeshift (Deb)
install_31() {
    sudo apt install -y timeshift
}

# ── 32 ── Free Download Manager
install_32() {
    wget -O "$PKG_DIR/freedownloadmanager.deb" \
        https://files2.freedownloadmanager.org/6/latest/freedownloadmanager.deb
    sudo apt install -y "$PKG_DIR/freedownloadmanager.deb"
}

# ── 33 ── LocalSend (Deb)
install_33() {
    LOCALSEND_URL=$(curl -s https://api.github.com/repos/localsend/localsend/releases/latest \
        | grep "browser_download_url" | grep "linux-x86-64.deb" | cut -d '"' -f 4)
    LOCALSEND_FILE=$(basename "$LOCALSEND_URL")
    wget -O "$PKG_DIR/$LOCALSEND_FILE" "$LOCALSEND_URL"
    sudo apt install -y "$PKG_DIR/$LOCALSEND_FILE"
}

# ── 34 ── LocalSend (Flatpak)
install_34() {
    flatpak install -y --noninteractive flathub org.localsend.localsend_app
}

# ── 35 ── qBittorrent
install_35() {
    sudo apt install -y qbittorrent
}

# ── 36 ── Sublime Text
install_36() {
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg \
        | sudo tee /etc/apt/keyrings/sublimehq-pub.asc > /dev/null
    echo -e "Types: deb\nURIs: https://download.sublimetext.com/\nSuites: apt/stable/\nSigned-By: /etc/apt/keyrings/sublimehq-pub.asc" \
        | sudo tee /etc/apt/sources.list.d/sublime-text.sources
    sudo apt update
    sudo apt install -y sublime-text
}

# ── 37 ── VS Code (Deb)
install_37() {
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
        | gpg --dearmor | sudo tee /usr/share/keyrings/microsoft-archive-keyring.gpg > /dev/null
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] \
https://packages.microsoft.com/repos/code stable main" \
        | sudo tee /etc/apt/sources.list.d/vscode.list
    sudo apt update
    sudo apt install -y code
}

# ── 38 ── VirtualBox
install_38() {
    wget -O oracle_vbox_2016.asc https://www.virtualbox.org/download/oracle_vbox_2016.asc
    sudo gpg --yes --output /usr/share/keyrings/oracle_vbox_2016.gpg --dearmor oracle_vbox_2016.asc
    sudo tee /etc/apt/sources.list.d/virtualbox.list > /dev/null <<EOF
deb [arch=amd64 signed-by=/usr/share/keyrings/oracle_vbox_2016.gpg] https://download.virtualbox.org/virtualbox/debian trixie contrib
EOF
    sudo apt-get update
    sudo apt-get install -y virtualbox-7.2
    sudo usermod -aG vboxusers "$USER"

    FULL_VERSION=$(dpkg-query -W -f='${Version}' virtualbox-7.2)
    VBOX_VERSION=$(echo "$FULL_VERSION" | cut -d '-' -f1)
    VBOX_BUILD=$(echo "$FULL_VERSION" | cut -d '-' -f2 | cut -d '~' -f1)

    EXT_PACK_FILE="/tmp/Oracle_VirtualBox_Extension_Pack-${VBOX_VERSION}-${VBOX_BUILD}.vbox-extpack"
    EXT_PACK_URL="https://download.virtualbox.org/virtualbox/${VBOX_VERSION}/Oracle_VirtualBox_Extension_Pack-${VBOX_VERSION}-${VBOX_BUILD}.vbox-extpack"

    wget -O "$EXT_PACK_FILE" "$EXT_PACK_URL"
    echo y | sudo VBoxManage extpack install --replace "$EXT_PACK_FILE"
    rm -f "$EXT_PACK_FILE"
}

# ── 39 ── WineHQ Stable
install_39() {
    sudo mkdir -pm755 /etc/apt/keyrings
    wget -O - https://dl.winehq.org/wine-builds/winehq.key \
        | sudo gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key -
    sudo dpkg --add-architecture i386
    sudo wget -NP /etc/apt/sources.list.d/ \
        https://dl.winehq.org/wine-builds/debian/dists/trixie/winehq-trixie.sources
    sudo apt update
    sudo apt install -y --install-recommends winehq-stable
}

# ── 40 ── OBS Studio (Flatpak)
install_40() {
    flatpak install -y --noninteractive flathub com.obsproject.Studio
}

# ── 41 ── VLC (Deb)
install_41() {
    sudo apt install -y vlc
}

# ── 42 ── Galculator
install_42() {
    sudo apt install -y galculator
}

# ── 43 ── Gucharmap
install_43() {
    sudo apt install -y gucharmap
}

# ── 44 ── Libre Office
install_44() {
    sudo apt install -y libreoffice libreoffice-gtk3
}

# ── 45 ── Obsidian (Flatpak)
install_45() {
    flatpak install -y --noninteractive flathub md.obsidian.Obsidian
}

# ── 46 ── Screen Keyboard - Onboard
install_46() {
    sudo apt install -y onboard
}

# ── 47 ── Thunderbird
install_47() {
    sudo apt install -y thunderbird
}

# ── 48 ── Steam
install_48() {
    wget -O "$PKG_DIR/steam_latest.deb" \
        https://repo.steampowered.com/steam/archive/precise/steam_latest.deb
    sudo apt install -y "$PKG_DIR/steam_latest.deb"
}

# ── 49 ── Heroic Games Launcher (Deb)
install_49() {
    HEROIC_URL=$(curl -s https://api.github.com/repos/Heroic-Games-Launcher/HeroicGamesLauncher/releases/latest \
        | grep "browser_download_url" | grep "linux-amd64.deb" | cut -d '"' -f 4)
    HEROIC_FILE=$(basename "$HEROIC_URL")
    wget -O "$PKG_DIR/$HEROIC_FILE" "$HEROIC_URL"
    sudo apt install -y "$PKG_DIR/$HEROIC_FILE"
}

# ── 50 ── Heroic Games Launcher (Flatpak)
install_50() {
    flatpak install -y --noninteractive flathub com.heroicgameslauncher.hgl
}

# ── 51 ── Lutris (Deb)
install_51() {
    echo -e "Types: deb\nURIs: https://download.opensuse.org/repositories/home:/strycore:/lutris/Debian_13/\nSuites: ./\nComponents: \nSigned-By: /etc/apt/keyrings/lutris.gpg" \
        | sudo tee /etc/apt/sources.list.d/lutris.sources > /dev/null
    wget -q -O- https://download.opensuse.org/repositories/home:/strycore:/lutris/Debian_13/Release.key \
        | sudo gpg --dearmor -o /etc/apt/keyrings/lutris.gpg
    sudo apt update
    sudo apt install -y lutris
}

# ── 52 ── Lutris (Flatpak)
install_52() {
    flatpak install -y --noninteractive flathub net.lutris.Lutris
}

# ── 53 ── Bitwarden (Flatpak)
install_53() {
    flatpak install -y --noninteractive flathub com.bitwarden.desktop
}

# ── 54 ── KeePassXC (Deb)
install_54() {
    sudo apt install -y keepassxc
}

# ── 55 ── Warp VPN
install_55() {
    curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg \
        | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" \
        | sudo tee /etc/apt/sources.list.d/cloudflare-client.list
    sudo apt-get update && sudo apt-get install -y cloudflare-warp
}

# ── 56 ── Wireshark (Deb)
install_56() {
    sudo apt install -y wireshark
}

# ── 57 ── Discord (Flatpak)
install_57() {
    flatpak install flathub com.discordapp.Discord
}

# ── 58 ── Signal (Deb)
install_58() {
    wget -qO- https://updates.signal.org/desktop/apt/keys.asc \
        | gpg --dearmor | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] \
https://updates.signal.org/desktop/apt xenial main" \
        | sudo tee /etc/apt/sources.list.d/signal-xenial.list
    sudo apt update
    sudo apt install -y signal-desktop
}

# ── 59 ── Telegram (Flatpak)
install_59() {
    flatpak install -y --noninteractive flathub org.telegram.desktop
}

# ────────────────────────────────────────────
for i in $SELECTIONS; do
    if declare -f "install_$i" >/dev/null; then
        echo "[$i] Installing..."
        install_$i
    else
        echo "[$i] Invalid selection, skipped."
    fi
done

<<<<<<< HEAD
echo "Setup files will be automatically cleaned up on exit."
=======
echo "Setup files will be automatically cleaned up on exit."
>>>>>>> e9cccf8 (Update full project snapshot)
