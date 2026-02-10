#!/bin/bash
set -e

echo "Version 2.1"
BASE="$HOME/satellaos-installer/configuration"
OWNER="$USER:$USER"

echo "▶ Preparing configuration directory..."
mkdir -p "$BASE"

#################################
# BASHRC and PROFILE BACKUP
#################################

echo "▶ Backing up .bashrc and .profile files..."

mkdir -p "$BASE/configs"

[ -f "$HOME/.bashrc" ] && cp -a "$HOME/.bashrc" "$BASE/configs/"
[ -f "$HOME/.profile" ] && cp -a "$HOME/.profile" "$BASE/configs/"

#################################
# XFCE (USER)
#################################

echo "▶ Copying XFCE user configurations..."

mkdir -p "$BASE/xfce/user"

[ -d "$HOME/.config/xfce4" ] && \
cp -a "$HOME/.config/xfce4" "$BASE/xfce/user/"

#################################
# XFCONF (USER)
#################################

echo "▶ Copying XFCONF user database..."

mkdir -p "$BASE/xfce/xfconf"

[ -d "$HOME/.config/xfconf" ] && \
cp -a "$HOME/.config/xfconf" "$BASE/xfce/xfconf/"

#################################
# XFCE (SYSTEM DEFAULTS)
#################################

echo "▶ Copying XFCE system defaults..."

mkdir -p "$BASE/xfce/system"

sudo cp -a /etc/xdg/xfce4 \
           "$BASE/xfce/system/" 2>/dev/null || true

#################################
# THUNAR (USER)
#################################

echo "▶ Copying Thunar configurations..."

mkdir -p "$BASE/thunar"

[ -d "$HOME/.config/Thunar" ] && \
cp -a "$HOME/.config/Thunar" "$BASE/thunar/"

#################################
# AUTOSTART
#################################

echo "▶ Copying Autostart files..."

mkdir -p "$BASE/autostart"

[ -d "$HOME/.config/autostart" ] && \
cp -a "$HOME/.config/autostart" "$BASE/autostart/"

#################################
# LIGHTDM
#################################

echo "▶ Copying LightDM configurations..."

mkdir -p "$BASE/lightdm/config"

sudo cp -a /etc/lightdm \
           "$BASE/lightdm/config/" 2>/dev/null || true

#################################
# SLICK GREETER
#################################

echo "▶ Copying Slick Greeter settings..."

mkdir -p "$BASE/lightdm/slick-greeter"

sudo cp -a /etc/lightdm/slick-greeter.conf \
           "$BASE/lightdm/slick-greeter/" 2>/dev/null || true

sudo cp -a /etc/lightdm/slick-greeter.conf.d \
           "$BASE/lightdm/slick-greeter/" 2>/dev/null || true

#################################
# GREETER GTK (lightdm user)
#################################

echo "▶ Copying Greeter GTK settings..."

mkdir -p "$BASE/lightdm/gtk"

sudo cp -a /var/lib/lightdm/.config \
           "$BASE/lightdm/gtk/" 2>/dev/null || true

#################################
# LIGHTDM LOGS (optional)
#################################

echo "▶ Copying LightDM logs..."

mkdir -p "$BASE/logs"

sudo cp -a /var/log/lightdm \
           "$BASE/logs/" 2>/dev/null || true

#################################
# OWNERSHIP & PERMISSIONS FIX
#################################

echo "▶ Transferring file ownership to user..."

sudo chown -R "$OWNER" "$BASE"

echo "▶ Adjusting permissions..."

find "$BASE" -type d -exec chmod 755 {} \;
find "$BASE" -type f -exec chmod 644 {} \;

echo "✅ XFCE + Thunar snapshot completed successfully."
echo "📁 Location: $BASE"