#!/bin/bash

# Papirus-folders interactive installation and color change script
# Selection will be made by number

# Color options
colors=("adwaita" "blue" "breeze" "carmine" "darkcyan" "green" "indigo" "nordic" "palebrown" "pink" "teal" "white" "yellow" "black" "bluegrey" "brown" "cyan" "deeporange" "grey" "magenta" "orange" "paleorange" "red" "violet" "yaru")

echo "Available colors:"
for i in "${!colors[@]}"; do
    echo "$((i+1))) ${colors[$i]}"
done

# User selection by number
read -rp "Please choose a color (by number): " choice_num

# Check if the number is valid
if [[ "$choice_num" -ge 1 && "$choice_num" -le "${#colors[@]}" ]]; then
    choice="${colors[$((choice_num-1))]}"
    echo "Selected color: $choice"

    # Papirus-folders installation
    echo "Installing and updating Papirus-folders..."
    wget -qO- https://git.io/papirus-folders-install | sh

    # Apply the color
    echo "Applying the selected color..."
    papirus-folders -C "$choice" --theme Papirus

    # Refresh icon cache
    echo "Refreshing icon cache..."
    sudo gtk-update-icon-cache -f /usr/share/icons/*

    echo "Done! Changes will be visible after you log out and log back in."
else
    echo "Error: Invalid selection."
fi
