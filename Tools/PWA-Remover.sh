#!/bin/bash

echo "Version 1.4"
APP_DIR="$HOME/.local/share/applications"

echo "PWA Removal Mode:"
echo "1) Remove ALL shortcuts"
echo "2) Select specific shortcuts to remove"
read -p "Your choice (1/2): " MODE

remove_all() {
    echo "Removing all PWA shortcuts..."
    rm -f "$APP_DIR"/*-pwa.desktop
    echo "All PWA shortcuts removed!"
}

remove_selected() {
    echo "Available PWA shortcuts:"
    # List all PWA desktop files safely
    mapfile -t FILES < <(find "$APP_DIR" -maxdepth 1 -type f -name "*-pwa.desktop")

    if [ ${#FILES[@]} -eq 0 ]; then
        echo "No PWA shortcuts found."
        exit 0
    fi

    # Show numbered list with only filenames
    i=1
    for f in "${FILES[@]}"; do
        echo "$i) \"$(basename "$f")\""
        ((i++))
    done

    read -p "Enter numbers to remove (e.g., 1,3,5): " SELECTION
    IFS=',' read -ra CHOICES <<< "$SELECTION"

    for choice in "${CHOICES[@]}"; do
        idx=$((choice-1))
        if [ $idx -ge 0 ] && [ $idx -lt ${#FILES[@]} ]; then
            rm -f "${FILES[$idx]}"
            echo "Removed: \"$(basename "${FILES[$idx]}")\""
        else
            echo "Invalid selection: $choice"
        fi
    done
}

case "$MODE" in
    1) remove_all ;;
    2) remove_selected ;;
    *) echo "Invalid choice." ;;
esac
