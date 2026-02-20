#!/usr/bin/env bash

set -e

echo "Bölüm gir (örn: /dev/nvme0n1p4 veya /dev/sda3):"
read -r PART

# Basit doğrulama
if [[ ! -b "$PART" ]]; then
    echo "Hata: Geçerli bir block device değil!"
    exit 1
fi

# Disk ve partition numarasını ayır
DISK=$(lsblk -no pkname "$PART")
DISK="/dev/$DISK"
PARTNUM=$(echo "$PART" | grep -o '[0-9]*$')

if [[ -z "$PARTNUM" ]]; then
    echo "Partition numarası çözülemedi!"
    exit 1
fi

echo
echo "Seçilen disk : $DISK"
echo "Seçilen bölüm: $PART (partition no: $PARTNUM)"
echo

echo "Mevcut partition tablosu:"
sudo gdisk -l "$DISK" | sed -n "1,/Number/p;/ $PARTNUM /p"
echo

read -rp "Bu bölümü 8300 (Linux filesystem) yapmak istiyor musun? (Y/N): " CONFIRM

if [[ "$CONFIRM" != "Y" && "$CONFIRM" != "y" ]]; then
    echo "İptal edildi."
    exit 0
fi

echo "Type GUID değiştiriliyor..."
sudo gdisk "$DISK" <<EOF
t
$PARTNUM
8300
w
Y
EOF

echo
echo "İşlem tamamlandı. Yeni durum:"
sudo gdisk -l "$DISK" | grep " $PARTNUM "
