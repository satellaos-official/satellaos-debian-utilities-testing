#!/bin/bash

echo "Version 1.0"
BLACKLIST_FILE="/etc/modprobe.d/blacklist.conf"

echo "Select an option:"
echo "1) Disable KVM on AMD CPU (On AMD CPUs, VirtualBox works but other virtualization software may have issues)"
echo "2) Disable KVM on Intel CPU"
echo "3) Re-enable KVM"
read -rp "Enter your choice [1-3]: " choice

case "$choice" in
  1)
    echo "Disabling KVM for AMD CPU..."
    sudo tee "$BLACKLIST_FILE" > /dev/null <<EOF
blacklist kvm
blacklist kvm_amd
EOF
    echo "KVM has been disabled for AMD CPU."
    ;;
  2)
    echo "Disabling KVM for Intel CPU..."
    sudo tee "$BLACKLIST_FILE" > /dev/null <<EOF
blacklist kvm
blacklist kvm_intel
EOF
    echo "KVM has been disabled for Intel CPU."
    ;;
  3)
    echo "Re-enabling KVM..."
    if [ -f "$BLACKLIST_FILE" ]; then
      sudo sed -i '/blacklist kvm/d' "$BLACKLIST_FILE"
      sudo sed -i '/blacklist kvm_amd/d' "$BLACKLIST_FILE"
      sudo sed -i '/blacklist kvm_intel/d' "$BLACKLIST_FILE"
      echo "KVM has been re-enabled."
    else
      echo "Blacklist file not found. KVM is probably already enabled."
    fi
    ;;
  *)
    echo "Invalid choice. Exiting."
    exit 1
    ;;
esac

echo
read -rp "Do you want to reboot now for the changes to take effect? (Y/N): " reboot_choice

case "$reboot_choice" in
  Y|y)
    echo "Rebooting system..."
    sudo reboot
    ;;
  *)
    echo "Reboot skipped. Please reboot manually later."
    ;;
esac
