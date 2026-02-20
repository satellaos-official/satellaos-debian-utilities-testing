#!/bin/bash
set -e

# Kullanıcıdan dizin sor (zorunlu)
read -rp "İşlenecek klasör yolunu gir: " TARGET_DIR

# Boş bırakıldıysa çık
if [ -z "$TARGET_DIR" ]; then
  echo "Hata: Klasör yolu boş bırakılamaz."
  exit 1
fi

# Dizin geçerli mi kontrol et
if [ ! -d "$TARGET_DIR" ]; then
  echo "Hata: Geçerli bir klasör değil -> $TARGET_DIR"
  exit 1
fi

echo "▶ İşlenen klasör: $TARGET_DIR"

find "$TARGET_DIR" -type f -exec sh -c '
  for file; do
    if file "$file" | grep -qE "text|ASCII"; then
      dos2unix "$file"
    fi
  done
' sh {} +

echo "✔ Tüm metin dosyalarına dos2unix uygulandı."
