#!/bin/bash
set -e

echo "Version 4.0"
echo "Font Installation Menu"
echo "----------------------"
echo "1) Basic Latin / UI fonts"
echo "2) Noto (Universal coverage)"
echo "3) Arabic / Persian / RTL"
echo "4) Indic languages (India)"
echo "5) Southeast Asian"
echo "6) Japanese"
echo "7) Korean"
echo "8) Chinese"
echo "9) Symbols / Emoji / Math"
echo "10) Install ALL fonts"
echo
read -p "Select font groups (e.g. 1 3 7): " selection

# -----------------------------
# 1) BASIC LATIN / UI
# -----------------------------
latin_fonts=(
  fonts-dejavu fonts-dejavu-core fonts-dejavu-extra fonts-dejavu-mono
  fonts-liberation fonts-liberation-sans-narrow
  fonts-lato fonts-freefont-ttf fonts-unifont fonts-urw-base35
  fonts-quicksand fonts-vlgothic fonts-yrsa-rasa
)

# -----------------------------
# 2) NOTO (FULL)
# -----------------------------
noto_fonts=(
  fonts-noto
  fonts-noto-core fonts-noto-extra
  fonts-noto-ui-core fonts-noto-ui-extra
  fonts-noto-mono fonts-noto-unhinted
  fonts-noto-cjk fonts-noto-cjk-extra
  fonts-noto-color-emoji
)

# -----------------------------
# 3) ARABIC / RTL
# -----------------------------
rtl_fonts=(
  fonts-arabeyes fonts-farsiweb
  fonts-hosny-amiri fonts-hosny-thabit
  fonts-sil-scheherazade fonts-sil-andika
  fonts-ukij-uyghur fonts-unikurdweb
  fonts-vazirmatn-variable fonts-sahel-variable
)

# -----------------------------
# 4) INDIC (HINDISTAN)
# -----------------------------
indic_fonts=(
  # Devanagari
  fonts-deva fonts-deva-extra fonts-gargi fonts-sahadeva fonts-sil-annapurna
  fonts-samyak-deva fonts-lohit-deva fonts-kalapi fonts-nakula 

  # Gujarati
  fonts-gujr fonts-gujr-extra fonts-lohit-gujr fonts-samyak-gujr

  # Gurmukhi
  fonts-guru fonts-guru-extra fonts-lohit-guru

  # Kannada
  fonts-lohit-knda

  # Tamil
  fonts-taml fonts-lohit-taml fonts-lohit-taml-classical fonts-samyak-taml

  # Telugu
  fonts-telu fonts-telu-extra fonts-lohit-telu fonts-teluguvijayam

  # Malayalam
  fonts-mlym fonts-lohit-mlym fonts-samyak-mlym
  fonts-smc fonts-smc-anjalioldlipi fonts-smc-chilanka fonts-smc-dyuthi
  fonts-smc-gayathri fonts-smc-karumbi fonts-smc-keraleeyam
  fonts-smc-manjari fonts-smc-meera fonts-smc-rachana
  fonts-smc-raghumalayalamsans fonts-smc-suruma fonts-smc-uroob

  # Bengali
  fonts-beng fonts-beng-extra
  fonts-lohit-beng-bengali fonts-lohit-beng-assamese
)

# -----------------------------
# 5) SOUTHEAST ASIA
# -----------------------------
sea_fonts=(
  fonts-thai-tlwg fonts-arundina
  fonts-tlwg-garuda fonts-tlwg-garuda-ttf
  fonts-tlwg-kinnari fonts-tlwg-kinnari-ttf
  fonts-tlwg-laksaman fonts-tlwg-laksaman-ttf
  fonts-tlwg-loma fonts-tlwg-loma-ttf
  fonts-tlwg-mono fonts-tlwg-mono-ttf
  fonts-tlwg-norasi fonts-tlwg-norasi-ttf
  fonts-tlwg-purisa fonts-tlwg-purisa-ttf
  fonts-tlwg-sawasdee fonts-tlwg-sawasdee-ttf
  fonts-tlwg-typewriter fonts-tlwg-typewriter-ttf
  fonts-tlwg-typist fonts-tlwg-typist-ttf
  fonts-tlwg-typo fonts-tlwg-typo-ttf
  fonts-tlwg-umpush fonts-tlwg-umpush-ttf
  fonts-tlwg-waree fonts-tlwg-waree-ttf
  fonts-khmeros fonts-dzongkha
)

# -----------------------------
# 6) Japanese
# -----------------------------
japanese_fonts=(
  fonts-ipafont fonts-ipafont-gothic fonts-ipafont-mincho fonts-takao
)

# -----------------------------
# 7) Korean
# -----------------------------
korean_fonts=(
  fonts-nanum fonts-unfonts-core
)

# -----------------------------
# 8) Chinese
# -----------------------------
chinese_fonts=(
  fonts-wqy-zenhei fonts-arphic-ukai fonts-arphic-uming
)

# -----------------------------
# 9) SYMBOLS / MATH / MISC
# -----------------------------
symbol_fonts=(
  fonts-font-awesome fonts-symbola fonts-opensymbol
  fonts-mathjax fonts-droid-fallback
  fonts-sarai fonts-culmus fonts-bpg-georgian
  fonts-sil-abyssinica
)

# -----------------------------
# INSTALL LOGIC
# -----------------------------
selected_packages=()

for choice in $selection; do
  case "$choice" in
    1) selected_packages+=("${latin_fonts[@]}") ;;
    2) selected_packages+=("${noto_fonts[@]}") ;;
    3) selected_packages+=("${rtl_fonts[@]}") ;;
    4) selected_packages+=("${indic_fonts[@]}") ;;
    5) selected_packages+=("${sea_fonts[@]}") ;;
    6) selected_packages+=("${japanese_fonts[@]}") ;;
    7) selected_packages+=("${korean_fonts[@]}") ;;
    8) selected_packages+=("${chinese_fonts[@]}") ;;
    9) selected_packages+=("${symbol_fonts[@]}") ;;
    10)
      selected_packages+=(
        "${latin_fonts[@]}" "${noto_fonts[@]}" "${rtl_fonts[@]}"
        "${indic_fonts[@]}" "${sea_fonts[@]}"
        "${japanese_fonts[@]}" "${korean_fonts[@]}" "${chinese_fonts[@]}" "${symbol_fonts[@]}"
      )
      ;;
    *) echo "Invalid option: $choice" ;;
  esac
done

if [ ${#selected_packages[@]} -eq 0 ]; then
  echo "No fonts selected. Exiting."
  exit 0
fi

sudo apt update
sudo apt install -y "${selected_packages[@]}"
