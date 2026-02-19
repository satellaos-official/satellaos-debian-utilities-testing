#!/bin/bash

set -e
set -u

echo "Version 5.2.1"
echo "--------------------------------------"
echo " Available Programs"
echo "--------------------------------------"
echo "1 - Brave Browser (Deb)"
echo "2 - Firefox ESR (Deb)"
echo "3 - Firefox (Portable)"
echo "4 - Floorp Browser (Portable)"
echo "5 - Google Chrome (Deb)"
echo "6 - Opera Stable (Deb)"
echo "7 - Vivaldi Stable (Deb)"
echo "8 - Zen Browser (Portable)"
echo "9 - Disk Usage Analyzer - baobab (Deb)"
echo "10 - Free Download Manager (Deb)"
echo "11 - Galculator (Deb)"
echo "12 - GIMP (Deb)"
echo "13 - GIMP (Flatpak)"
echo "14 - GParted (Deb)"
echo "15 - Gnome Software (Deb)"
echo "16 - GNOME Disk Utility (Deb)"
echo "17 - Grub Customizer (Deb)"
echo "18 - Gucharmap (Deb)"
echo "19 - KDiskMark 3.2.0 (Deb)"
echo "20 - KDiskMark (Flatpak)"
echo "21 - Libre Office (Deb)"
echo "22 - LocalSend 1.17.0 (Deb)"
echo "23 - LocalSend (Flatpak)"
echo "24 - MenuLibre (Deb)"
echo "25 - Mission Center (Flatpak)"
echo "26 - Mintstick (Deb)"
echo "27 - PowerISO (Flatpak)"
echo "28 - Pinta (Flatpak)"
echo "29 - qBittorrent (Deb)"
echo "30 - Ristretto (Deb)"
echo "31 - Screen Keyboard - Onboard (Deb)"
echo "32 - Steam (Deb)"
echo "33 - Sublime Text (Deb)"
echo "34 - VirtualBox 7.2.4 [Debian 13 (Deb)]"
echo "35 - VLC (Deb)"
echo "36 - Warp VPN"
echo "37 - WineHQ Stable [Debian 13 (Deb)]"
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

install_1() { # Brave Browser
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
        https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources \
        https://brave-browser-apt-release.s3.brave.com/brave-browser.sources
    sudo apt update
    sudo apt install -y brave-browser
}

install_2() { # Firefox ESR
    sudo apt install -y firefox-esr
}

install_3() { # Firefox
    LATEST_VERSION=$(curl -s https://product-details.mozilla.org/1.0/firefox_versions.json | grep -Po '"LATEST_FIREFOX_VERSION":\s*"\K[^"]+')
    FILE="$PKG_DIR/firefox-$LATEST_VERSION.tar.xz"
    URL="https://ftp.mozilla.org/pub/firefox/releases/$LATEST_VERSION/linux-x86_64/en-US/firefox-$LATEST_VERSION.tar.xz"
    
    wget -O "$FILE" "$URL"
    sudo rm -rf /opt/firefox
    tar -xf "$FILE" -C "$PKG_DIR"
    sudo mv "$PKG_DIR/firefox" /opt/firefox
    sudo ln -sf /opt/firefox/firefox /usr/local/bin/firefox
    
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

install_4() { # Floorp Browser
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

install_5() { # Google Chrome
    wget -O "$PKG_DIR/google-chrome-stable_current_amd64.deb" https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo apt install -y "$PKG_DIR/google-chrome-stable_current_amd64.deb"
}

install_6() { # Opera
    wget -qO- https://deb.opera.com/archive.key | gpg --dearmor | sudo tee /usr/share/keyrings/opera-browser.gpg > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/opera-browser.gpg] https://deb.opera.com/opera-stable/ stable non-free" | sudo tee /etc/apt/sources.list.d/opera-archive.list
    sudo apt-get update
    sudo apt-get install opera-stable
}

install_7() { # Vivaldi
    wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub \
      | gpg --dearmor | sudo tee /usr/share/keyrings/vivaldi-browser.gpg > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/vivaldi-browser.gpg arch=$(dpkg --print-architecture)] https://repo.vivaldi.com/archive/deb/ stable main" \
      | sudo tee /etc/apt/sources.list.d/vivaldi-archive.list
    sudo apt update
    sudo apt install vivaldi-stable
}

install_8() { # Zen Browser
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

install_9() { # Disk Usage Analyzer - baobab
    sudo apt install -y baobab
}

install_10() { # Free Download Manager
    wget -O "$PKG_DIR/freedownloadmanager.deb" https://files2.freedownloadmanager.org/6/latest/freedownloadmanager.deb
    sudo apt install -y "$PKG_DIR/freedownloadmanager.deb"
}

install_11() { # Galculator
    sudo apt install -y galculator
}

install_12() { # GIMP (Deb)
    sudo apt install -y gimp
}

install_13() { # GIMP (Flatpak)
    flatpak install -y --noninteractive flathub org.gimp.GIMP
}

install_14() { # GParted
    sudo apt install -y gparted
}

install_15() { # Gnome Software
    sudo apt install -y gnome-software gnome-software-plugin-flatpak
}

install_16() { # GNOME Disk Utility
    sudo apt install -y gnome-disk-utility
}

install_17() { # Grub Customizer
    sudo apt install -y grub-customizer
}

install_18() { # Gucharmap
    sudo apt install -y gucharmap
}

install_19() { # KDiskMark 3.2.0
    wget -O "$PKG_DIR/kdiskmark_3.2.0_amd64.deb" https://github.com/JonMagon/KDiskMark/releases/download/3.2.0/kdiskmark_3.2.0_amd64.deb
    sudo apt install -y "$PKG_DIR/kdiskmark_3.2.0_amd64.deb"
}

install_20() { # KDiskMark (Flatpak)
    flatpak install -y --noninteractive flathub io.github.jonmagon.kdiskmark
}

install_21() { # Libre Office
    sudo apt install -y libreoffice libreoffice-gtk3
}

install_22() { # LocalSend 1.17.0
    wget -O "$PKG_DIR/LocalSend-1.17.0-linux-x86-64.deb" https://github.com/localsend/localsend/releases/download/v1.17.0/LocalSend-1.17.0-linux-x86-64.deb
    sudo apt install -y "$PKG_DIR/LocalSend-1.17.0-linux-x86-64.deb"
}

install_23() { # LocalSend (Flatpak)
    flatpak install -y --noninteractive flathub org.localsend.localsend_app
}

install_24() { # MenuLibre
    sudo apt install -y menulibre
}

install_25() { # Mission Center (Flatpak)
    flatpak install -y --noninteractive flathub io.missioncenter.MissionCenter
}

install_26() { # Mintstick
    sudo apt install -y mintstick
}

install_27() { # PowerISO (Flatpak)
    flatpak install -y --noninteractive flathub com.poweriso.PowerISO
}

install_28() { # Pinta (Flatpak)
    flatpak install -y --noninteractive flathub com.github.PintaProject.Pinta
}

install_29() { # qBittorrent
    sudo apt install -y qbittorrent
}

install_30() { # Ristretto
   sudo apt install -y ristretto \
   libwebp7 \
   tumbler \
   tumbler-plugins-extra \
   webp-pixbuf-loader
}

install_31() { # Onboard
    sudo apt install -y onboard
}

install_32() { # Steam
    wget -O "$PKG_DIR/steam_latest.deb" https://repo.steampowered.com/steam/archive/precise/steam_latest.deb
    sudo apt install -y "$PKG_DIR/steam_latest.deb"
}

install_33() { # Sublime Text
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo tee /etc/apt/keyrings/sublimehq-pub.asc > /dev/null
    echo -e "Types: deb\nURIs: https://download.sublimetext.com/\nSuites: apt/stable/\nSigned-By: /etc/apt/keyrings/sublimehq-pub.asc" \
        | sudo tee /etc/apt/sources.list.d/sublime-text.sources
    sudo apt update
    sudo apt install -y sublime-text
}

install_34() { # VirtualBox
    wget -O "$PKG_DIR/virtualbox-7.2_7.2.4-170995~Debian~trixie_amd64.deb" https://download.virtualbox.org/virtualbox/7.2.4/virtualbox-7.2_7.2.4-170995~Debian~trixie_amd64.deb
    sudo apt install -y "$PKG_DIR/virtualbox-7.2_7.2.4-170995~Debian~trixie_amd64.deb"
    wget -O "$PKG_DIR/Oracle_VirtualBox_Extension_Pack-7.2.4.vbox-extpack" https://download.virtualbox.org/virtualbox/7.2.4/Oracle_VirtualBox_Extension_Pack-7.2.4.vbox-extpack
    sudo VBoxManage extpack install --accept-license=eb31505e56e9b4d0fbca139104da41ac6f6b98f8e78968bdf01b1f3da3c4f9ae "$PKG_DIR/Oracle_VirtualBox_Extension_Pack-7.2.4.vbox-extpack"
    sudo usermod -aG vboxusers ${SUDO_USER:-$USER}
}

install_35() { # VLC
    sudo apt install -y vlc
}

install_36() { # Warp VPN
    curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list
    sudo apt-get update && sudo apt-get install cloudflare-warp
}

install_37() { # WineHQ Stable
    sudo mkdir -pm755 /etc/apt/keyrings
    wget -O - https://dl.winehq.org/wine-builds/winehq.key \
        | sudo gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key -
    sudo dpkg --add-architecture i386
    sudo wget -NP /etc/apt/sources.list.d/ \
        https://dl.winehq.org/wine-builds/debian/dists/trixie/winehq-trixie.sources
    sudo apt update
    sudo apt install -y --install-recommends winehq-stable
}

for i in $SELECTIONS; do
    if declare -f "install_$i" >/dev/null; then
        echo "[$i] Installing..."
        install_$i
    else
        echo "[$i] Invalid selection, skipped."
    fi
done

echo "Setup files will be automatically cleaned up on exit."
