#!/bin/bash

# SatellaOS tools directory
TOOLS_DIR="$HOME/satellaos"

# Create folder if it doesn't exist
mkdir -p "$TOOLS_DIR"

# Display menu
echo "Select a tool to download and run:"
echo "1) KVM-Tool"
echo "2) PWA-Installer"
echo "3) PWA-Remover"
echo "4) Papirus-color-changer-v2"
echo "5) Config-Backup"
echo "6) Config-Restore"
echo "7) Fonts-v4"
echo "8) SatellaOS Program Installer Tool"

# Get user input
read -p "Enter the number of your choice (1-8): " choice

# Selection table
case $choice in
  1)
    TOOL_NAME="KVM-Tool.sh"
    URL="https://raw.githubusercontent.com/satellaos-official/satellaos-debian-utilities/refs/heads/main/tools/KVM-Tool.sh"
    ;;
  2)
    TOOL_NAME="PWA-Installer.sh"
    URL="https://raw.githubusercontent.com/satellaos-official/satellaos-debian-utilities/refs/heads/main/tools/PWA-Installer.sh"
    ;;
  3)
    TOOL_NAME="PWA-Remover.sh"
    URL="https://raw.githubusercontent.com/satellaos-official/satellaos-debian-utilities/refs/heads/main/tools/PWA-Remover.sh"
    ;;
  4)
    TOOL_NAME="Papirus-color-changer-v2.sh"
    URL="https://raw.githubusercontent.com/satellaos-official/satellaos-debian-utilities/refs/heads/main/tools/Papirus-color-changer/Papirus-color-changer-v2.sh"
    ;;
  5)
    TOOL_NAME="config-backup.sh"
    URL="https://raw.githubusercontent.com/satellaos-official/satellaos-debian-utilities/refs/heads/main/tools/config-backup.sh"
    ;;
  6)
    TOOL_NAME="config-restore.sh"
    URL="https://raw.githubusercontent.com/satellaos-official/satellaos-debian-utilities/refs/heads/main/tools/config-restore.sh"
    ;;
  7)
    TOOL_NAME="fonts-v4.sh"
    URL="https://raw.githubusercontent.com/satellaos-official/satellaos-debian-utilities/refs/heads/main/tools/fonts-v4.sh"
    ;;
  8)
    TOOL_NAME="satellaos-program-installer-tool-5.2.0.sh"
    URL="https://raw.githubusercontent.com/satellaos-official/satellaos-debian-utilities/refs/heads/main/tools/satellaos-program-installer-tool-5.2.0.sh"
    ;;
  *)
    echo "Invalid choice. Exiting."
    exit 1
    ;;
esac

# Download, make executable, and run
echo "Downloading $TOOL_NAME..."
wget "$URL" -O "$TOOLS_DIR/$TOOL_NAME"
chmod +x "$TOOLS_DIR/$TOOL_NAME"
echo "Running $TOOL_NAME..."
"$TOOLS_DIR/$TOOL_NAME"

# Ask user if they want to delete the tools folder
read -p "Do you want to delete the $TOOLS_DIR folder? Y/N: " del_choice
if [[ "$del_choice" =~ ^[Yy]$ ]]; then
    rm -rf "$TOOLS_DIR"
    echo "$TOOLS_DIR deleted."
else
    echo "$TOOLS_DIR kept."
fi