#!/bin/bash

# SatellaOS tools directory (geçici klasör)
TOOLS_DIR=$(mktemp -d /tmp/satellaos-tools-XXXXXX)
trap 'rm -rf "$TOOLS_DIR"' EXIT

# Github Repo
REPO="https://raw.githubusercontent.com/satellaos-official/satellaos-debian-utilities-testing/refs/heads/main/Tools"

# Check if wget is installed
if ! command -v wget &> /dev/null; then
    echo "Error: wget is not installed. Please install it first."
    exit 1
fi

# Display menu
echo "Select a tool to download and run:"
echo "1) KVM Tool"
echo "2) PWA Installer"
echo "3) PWA Remover"
echo "4) Papirus Color changer"
echo "5) Config Backup"
echo "6) Config Restore"
echo "7) Fonts"
echo "8) SatellaOS Program Installer Tool"
echo "9) Unixify Tree"
echo "10) Efiguard"
echo "11) Win2GRUB"

# Get user input
read -p "Enter the number of your choice (1-8): " choice

# Selection table
case $choice in
  1)
    TOOL_NAME="KVM-Tool.sh"
    URL="$REPO/KVM-Tool.sh"
    ;;
  2)
    TOOL_NAME="PWA-Installer.sh"
    URL="$REPO/PWA-Installer.sh"
    ;;
  3)
    TOOL_NAME="PWA-Remover.sh"
    URL="$REPO/PWA-Remover.sh"
    ;;
  4)
    TOOL_NAME="Papirus-color-changer.sh"
    URL="$REPO/Papirus-color-changer/Papirus-color-changer.sh"
    ;;
  5)
    TOOL_NAME="config-backup.sh"
    URL="$REPO/config-backup.sh"
    ;;
  6)
    TOOL_NAME="config-restore.sh"
    URL="$REPO/config-restore.sh"
    ;;
  7)
    TOOL_NAME="fonts.sh"
    URL="$REPO/fonts.sh"
    ;;
  8)
    TOOL_NAME="satellaos-program-installer-tool.sh"
    URL="$REPO/satellaos-program-installer-tool.sh"
    ;;
  9)
    TOOL_NAME="unixify-tree.sh"
    URL="$REPO/unixify-tree.sh"
    ;;
  10)
    TOOL_NAME="efiguard.sh"
    URL="$REPO/efiguard.sh"
    ;;
  11)
    TOOL_NAME="win2grub.sh"
    URL="$REPO/win2grub.sh"
    ;;
  *)
    echo "Invalid choice. Exiting."
    exit 1
    ;;
esac

# Download, make executable, and run
echo "Downloading $TOOL_NAME..."
if wget "$URL" -O "$TOOLS_DIR/$TOOL_NAME"; then
    chmod +x "$TOOLS_DIR/$TOOL_NAME"
    echo "Running $TOOL_NAME..."
    "$TOOLS_DIR/$TOOL_NAME"
else
    echo "Error: Failed to download $TOOL_NAME"
    exit 1
fi

echo "Setup files will be automatically cleaned up on exit."
