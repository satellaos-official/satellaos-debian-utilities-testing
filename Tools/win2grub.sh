#!/bin/bash

# GRUB Boot Girdilerini Yöneten Script
# Kullanım: sudo ./manage-boot-entries.sh

# Root yetkisi kontrolü
if [ "$EUID" -ne 0 ]; then 
    echo "Bu script'i root yetkisiyle çalıştırmalısınız!"
    echo "Kullanım: sudo $0"
    exit 1
fi

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# GRUB config dosyasını bul
if [ -f /boot/grub/grub.cfg ]; then
    GRUB_CFG="/boot/grub/grub.cfg"
elif [ -f /boot/grub2/grub.cfg ]; then
    GRUB_CFG="/boot/grub2/grub.cfg"
else
    echo -e "${RED}Hata: GRUB yapılandırma dosyası bulunamadı!${NC}"
    exit 1
fi

# GRUB.d dizinini bul
if [ -d /etc/grub.d ]; then
    GRUB_D="/etc/grub.d"
else
    echo -e "${RED}Hata: /etc/grub.d dizini bulunamadı!${NC}"
    exit 1
fi

# Fonksiyon: grub.cfg'den boot girdilerini oku ve kaynak dosyayı bul
list_boot_entries() {
    echo -e "${CYAN}=== Mevcut Boot Girdileri ===${NC}\n"
    
    # Geçici diziler
    declare -g -A entries
    declare -g -A entry_sources
    declare -g -A entry_lines
    declare -g -A entry_ids
    declare -g -a entry_order
    local index=1
    
    # grub.cfg'den gerçek menuentry'leri oku
    local in_menuentry=0
    local brace_count=0
    local current_entry=""
    local current_id=""
    
    while IFS= read -r line; do
        # menuentry başlangıcını bul
        if [[ $line =~ menuentry[[:space:]][\'\"]([^\'\"]+)[\'\"][[:space:]].*\$menuentry_id_option[[:space:]][\'\"]([^\'\"]+)[\'\"] ]] || \
           [[ $line =~ menuentry[[:space:]][\'\"]([^\'\"]+)[\'\"] ]]; then
            current_entry="${BASH_REMATCH[1]}"
            current_id="${BASH_REMATCH[2]}"
            in_menuentry=1
            brace_count=0
        fi
        
        # Süslü parantezleri say
        if [ $in_menuentry -eq 1 ]; then
            local opens=$(echo "$line" | grep -o "{" | wc -l)
            local closes=$(echo "$line" | grep -o "}" | wc -l)
            brace_count=$((brace_count + opens - closes))
            
            # menuentry bittiğinde kaydet
            if [ $brace_count -le 0 ] && [ $opens -gt 0 ]; then
                # Kaynak dosyayı bul
                local source_file=$(find_source_file "$current_entry" "$current_id")
                
                entries[$index]="$current_entry"
                entry_sources[$index]="$source_file"
                entry_ids[$index]="$current_id"
                entry_order+=($index)
                
                # Renkli çıktı
                local filename=$(basename "$source_file")
                if [[ $current_entry =~ [Ww]indows ]]; then
                    echo -e "${BLUE}$index.${NC} ${YELLOW}$current_entry${NC} ${CYAN}[$filename]${NC}"
                elif [[ $current_entry =~ [Aa]dvanced ]]; then
                    echo -e "${BLUE}$index.${NC} ${CYAN}$current_entry${NC} ${CYAN}[$filename]${NC}"
                else
                    echo -e "${BLUE}$index.${NC} ${GREEN}$current_entry${NC} ${CYAN}[$filename]${NC}"
                fi
                
                ((index++))
                in_menuentry=0
            fi
        fi
    done < "$GRUB_CFG"
    
    if [ ${#entries[@]} -eq 0 ]; then
        echo -e "${RED}Hiç boot girdisi bulunamadı!${NC}"
        exit 1
    fi
    
    echo ""
}

# Fonksiyon: Kaynak dosyayı bul
find_source_file() {
    local entry_name="$1"
    local entry_id="$2"
    
    # Önce ID'ye göre ara
    if [ -n "$entry_id" ]; then
        for grub_file in "$GRUB_D"/*; do
            if [ -f "$grub_file" ] && grep -q "$entry_id" "$grub_file" 2>/dev/null; then
                echo "$grub_file"
                return
            fi
        done
    fi
    
    # ID bulunamazsa, entry isminin bir kısmına göre ara
    for grub_file in "$GRUB_D"/*; do
        if [ -f "$grub_file" ]; then
            # Basit isim karşılaştırması
            if [[ "$entry_name" =~ [Ww]indows ]] && [[ "$(basename $grub_file)" =~ (custom|windows|40_) ]]; then
                echo "$grub_file"
                return
            elif [[ "$entry_name" =~ [Ll]inux ]] && [[ "$(basename $grub_file)" =~ (10_linux|linux) ]]; then
                echo "$grub_file"
                return
            elif [[ "$entry_name" =~ [Xx]en ]] && [[ "$(basename $grub_file)" =~ (20_linux_xen|xen) ]]; then
                echo "$grub_file"
                return
            elif grep -F "$entry_name" "$grub_file" 2>/dev/null | grep -q "menuentry"; then
                echo "$grub_file"
                return
            fi
        fi
    done
    
    # Hiçbiri bulunamazsa 30_os-prober olabilir
    echo "$GRUB_D/30_os-prober"
}

# Fonksiyon: Belirli bir menuentry bloğunu dosyadan sil
delete_menuentry_from_file() {
    local file_path="$1"
    local start_line="$2"
    local end_line="$3"
    local entry_name="$4"
    
    # Yedek oluştur
    local backup_file="${file_path}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$file_path" "$backup_file"
    echo -e "${GREEN}Yedek oluşturuldu: $backup_file${NC}"
    
    # Geçici dosya oluştur
    local temp_file=$(mktemp)
    
    # Belirtilen satır aralığını atla
    awk -v start="$start_line" -v end="$end_line" '
        NR < start || NR > end { print }
    ' "$file_path" > "$temp_file"
    
    # Geçici dosyayı orijinal dosyanın üzerine yaz
    mv "$temp_file" "$file_path"
    
    echo -e "${GREEN}Menuentry silindi: '$entry_name'${NC}"
    echo -e "${YELLOW}Dosya: $(basename "$file_path")${NC}"
}

# Fonksiyon: Boot girdisini sil
delete_boot_entry() {
    local entry_num=$1
    
    if [ -z "${entries[$entry_num]}" ]; then
        echo -e "${RED}Geçersiz numara!${NC}"
        return
    fi
    
    local entry_name="${entries[$entry_num]}"
    local source_file="${entry_sources[$entry_num]}"
    local entry_id="${entry_ids[$entry_num]}"
    
    echo -e "${YELLOW}╔════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║           Silme Onayı                      ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════╝${NC}"
    echo -e "${CYAN}Boot Girdisi:${NC} $entry_name"
    echo -e "${CYAN}Kaynak Dosya:${NC} $(basename "$source_file")"
    echo ""
    
    # Kaynak dosyadan menuentry'yi bul ve sil
    if [ ! -f "$source_file" ]; then
        echo -e "${RED}Hata: Kaynak dosya bulunamadı!${NC}"
        return
    fi
    
    # Silinecek bölümü bul
    echo -e "${YELLOW}Kaynak dosyada aranıyor...${NC}"
    
    # Dosyada menuentry'yi bul
    local line_num=0
    local in_menuentry=0
    local brace_count=0
    local menuentry_start=0
    local menuentry_end=0
    local found=0
    
    while IFS= read -r line; do
        ((line_num++))
        
        # Bu entry'yi bul (ID veya isimle)
        if [ $found -eq 0 ]; then
            if [[ -n "$entry_id" ]] && [[ $line =~ $entry_id ]]; then
                menuentry_start=$line_num
                in_menuentry=1
                brace_count=0
                found=1
            elif echo "$line" | grep -q "menuentry.*['\"]${entry_name}['\"]"; then
                menuentry_start=$line_num
                in_menuentry=1
                brace_count=0
                found=1
            fi
        fi
        
        # Süslü parantezleri say
        if [ $in_menuentry -eq 1 ]; then
            local opens=$(echo "$line" | grep -o "{" | wc -l)
            local closes=$(echo "$line" | grep -o "}" | wc -l)
            brace_count=$((brace_count + opens - closes))
            
            # menuentry bittiğinde dur
            if [ $brace_count -le 0 ] && [ $opens -gt 0 ]; then
                menuentry_end=$line_num
                break
            fi
        fi
    done < "$source_file"
    
    if [ $menuentry_start -eq 0 ] || [ $menuentry_end -eq 0 ]; then
        echo -e "${RED}Hata: Menuentry bu dosyada bulunamadı!${NC}"
        echo -e "${YELLOW}Dosya manuel olarak kontrol edilmeli: $source_file${NC}"
        return
    fi
    
    echo -e "${CYAN}Satır Aralığı:${NC} $menuentry_start-$menuentry_end"
    echo ""
    
    # Silinecek bölümü göster
    echo -e "${YELLOW}Silinecek içerik:${NC}"
    echo -e "${CYAN}----------------------------------------${NC}"
    sed -n "${menuentry_start},${menuentry_end}p" "$source_file"
    echo -e "${CYAN}----------------------------------------${NC}"
    echo ""
    
    read -p "Bu girdiyi silmek istediğinizden emin misiniz? (e/h): " confirm
    
    if [[ $confirm =~ ^[Ee]$ ]] || [[ $confirm =~ ^[Yy]$ ]]; then
        delete_menuentry_from_file "$source_file" "$menuentry_start" "$menuentry_end" "$entry_name"
        
        # GRUB'ı güncelle
        update_grub_config
    else
        echo -e "${YELLOW}İşlem iptal edildi.${NC}"
    fi
}

# Fonksiyon: Kullanıcıdan girdi seç ve sil
select_and_delete_entry() {
    echo ""
    read -p "Silmek istediğiniz boot girdisinin numarasını girin (iptal için 0): " entry_num
    
    if [ "$entry_num" = "0" ]; then
        echo -e "${YELLOW}İşlem iptal edildi.${NC}"
        return
    fi
    
    delete_boot_entry "$entry_num"
}

# Fonksiyon: GRUB'ı güncelle
update_grub_config() {
    echo -e "\n${YELLOW}GRUB güncelleniyor...${NC}"
    
    if command -v update-grub &> /dev/null; then
        update-grub
    elif command -v grub-mkconfig &> /dev/null; then
        grub-mkconfig -o /boot/grub/grub.cfg
    elif command -v grub2-mkconfig &> /dev/null; then
        grub2-mkconfig -o /boot/grub2/grub.cfg
    else
        echo -e "${RED}Hata: GRUB güncelleme komutu bulunamadı!${NC}"
        return 1
    fi
    
    echo -e "${GREEN}GRUB başarıyla güncellendi!${NC}"
}

# Fonksiyon: os-prober'ı devre dışı bırak
disable_os_prober() {
    echo -e "\n${YELLOW}os-prober otomatik algılamayı devre dışı bırakmak istiyor musunuz?${NC}"
    echo -e "${YELLOW}(Bu, otomatik Windows/diğer OS algılamayı durdurur)${NC}"
    read -p "Devam edilsin mi? (e/h): " confirm
    
    if [[ $confirm =~ ^[Ee]$ ]] || [[ $confirm =~ ^[Yy]$ ]]; then
        # /etc/default/grub'ı düzenle
        if grep -q "^GRUB_DISABLE_OS_PROBER=" /etc/default/grub; then
            sed -i 's/^GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=true/' /etc/default/grub
        else
            echo "GRUB_DISABLE_OS_PROBER=true" >> /etc/default/grub
        fi
        
        echo -e "${GREEN}os-prober devre dışı bırakıldı.${NC}"
        update_grub_config
    else
        echo -e "${YELLOW}İşlem iptal edildi.${NC}"
    fi
}

# Fonksiyon: os-prober'ı etkinleştir
enable_os_prober() {
    echo -e "\n${YELLOW}os-prober otomatik algılamayı etkinleştirmek istiyor musunuz?${NC}"
    read -p "Devam edilsin mi? (e/h): " confirm
    
    if [[ $confirm =~ ^[Ee]$ ]] || [[ $confirm =~ ^[Yy]$ ]]; then
        if grep -q "^GRUB_DISABLE_OS_PROBER=" /etc/default/grub; then
            sed -i 's/^GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
        fi
        
        echo -e "${GREEN}os-prober etkinleştirildi.${NC}"
        update_grub_config
    else
        echo -e "${YELLOW}İşlem iptal edildi.${NC}"
    fi
}

# Ana menü
main_menu() {
    while true; do
        clear
        echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║   GRUB Boot Girdi Yönetim Aracı          ║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}\n"
        
        list_boot_entries
        
        echo -e "${CYAN}Seçenekler:${NC}"
        echo -e "${BLUE}1.${NC} Boot girdisi sil (güvenli)"
        echo -e "${BLUE}2.${NC} os-prober'ı devre dışı bırak"
        echo -e "${BLUE}3.${NC} os-prober'ı etkinleştir"
        echo -e "${BLUE}4.${NC} GRUB'ı manuel güncelle"
        echo -e "${BLUE}5.${NC} Yedekleri göster"
        echo -e "${BLUE}0.${NC} Çıkış"
        echo ""
        
        read -p "Seçiminiz: " choice
        
        case $choice in
            1)
                select_and_delete_entry
                read -p "Devam etmek için Enter'a basın..."
                ;;
            2)
                disable_os_prober
                read -p "Devam etmek için Enter'a basın..."
                ;;
            3)
                enable_os_prober
                read -p "Devam etmek için Enter'a basın..."
                ;;
            4)
                update_grub_config
                read -p "Devam etmek için Enter'a basın..."
                ;;
            5)
                echo -e "\n${CYAN}=== Yedek Dosyalar ===${NC}"
                ls -lh "$GRUB_D"/*.backup* 2>/dev/null || echo "Yedek bulunamadı."
                read -p "Devam etmek için Enter'a basın..."
                ;;
            0)
                echo -e "\n${GREEN}Çıkılıyor...${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Geçersiz seçim!${NC}"
                sleep 2
                ;;
        esac
    done
}

# Script'i başlat
main_menu