#!/bin/bash

# Check whiptail availability
if ! command -v whiptail &>/dev/null; then
    echo "whiptail not found. Installing..."
    sudo apt-get install -y whiptail 2>/dev/null || sudo pacman -S --noconfirm libnewt 2>/dev/null || {
        echo "Could not install whiptail. Please install it manually."
        exit 1
    }
fi

TITLE="PWA Remover v2.0"
W=70
H=20

APP_DIR="$HOME/.local/share/applications"
BACKUP_DIR="$HOME/.local/share/pwa-backups"

mkdir -p "$BACKUP_DIR"

# ----- Functions -----

parse_desktop_file() {
    local FILE="$1"
    local NAME=$(grep "^Name=" "$FILE" | cut -d'=' -f2- | head -1)
    local EXEC=$(grep "^Exec=" "$FILE" | cut -d'=' -f2- | head -1)
    local URL=$(echo "$EXEC" | grep -oP '(?<=--app=)[^ ]+' || echo "N/A")
    local BROWSER=$(echo "$EXEC" | awk '{print $1}')
    case "$BROWSER" in
        *brave*)    BROWSER="Brave" ;;
        *chrome*)   BROWSER="Chrome" ;;
        *vivaldi*)  BROWSER="Vivaldi" ;;
        *opera*)    BROWSER="Opera" ;;
        *chromium*) BROWSER="Chromium" ;;
        *)          BROWSER="Unknown" ;;
    esac
    echo "${NAME}|${BROWSER}|${URL}|${FILE}"
}

load_pwas() {
    mapfile -t PWA_FILES < <(find "$APP_DIR" -maxdepth 1 -type f -name "*-pwa.desktop" 2>/dev/null)
    PWA_DATA=()
    for f in "${PWA_FILES[@]}"; do
        PWA_DATA+=("$(parse_desktop_file "$f")")
    done
}

# View all PWAs in a whiptail msgbox
view_all_pwas() {
    load_pwas
    if [ ${#PWA_DATA[@]} -eq 0 ]; then
        whiptail --title "$TITLE" --msgbox "No PWA shortcuts found." 8 $W
        return 1
    fi

    local TEXT="Application            Browser     URL\n"
    TEXT+="─────────────────────────────────────────────────────────\n"
    for entry in "${PWA_DATA[@]}"; do
        local NAME=$(echo "$entry" | cut -d'|' -f1)
        local BROWSER=$(echo "$entry" | cut -d'|' -f2)
        local URL=$(echo "$entry" | cut -d'|' -f3)
        local DNAME="${NAME:0:22}"
        local DURL="${URL:0:30}"
        [[ ${#NAME} -gt 22 ]] && DNAME="${DNAME}.."
        [[ ${#URL}  -gt 30 ]] && DURL="${DURL}.."
        TEXT+=$(printf "%-24s %-12s %s\n" "$DNAME" "$BROWSER" "$DURL")
        TEXT+="\n"
    done
    TEXT+="─────────────────────────────────────────────────────────\n"
    TEXT+="Total: ${#PWA_DATA[@]} PWA(s)"

    whiptail --title "$TITLE - All PWAs" --scrolltext --msgbox "$TEXT" 25 $W
}

# Remove selected PWAs via checklist
remove_selected() {
    load_pwas
    if [ ${#PWA_DATA[@]} -eq 0 ]; then
        whiptail --title "$TITLE" --msgbox "No PWA shortcuts found." 8 $W
        return
    fi

    local CHECKLIST_ARGS=()
    for entry in "${PWA_DATA[@]}"; do
        local NAME=$(echo "$entry" | cut -d'|' -f1)
        local BROWSER=$(echo "$entry" | cut -d'|' -f2)
        CHECKLIST_ARGS+=("$NAME" "[$BROWSER]" OFF)
    done

    SELECTED=$(whiptail --title "$TITLE - Remove Selected" \
        --checklist "Select PWAs to remove:" \
        $H $W 10 \
        "${CHECKLIST_ARGS[@]}" \
        3>&1 1>&2 2>&3) || return

    [[ -z "$SELECTED" ]] && return

    # Build confirmation list
    local CONFIRM_TEXT="The following PWA(s) will be removed:\n\n"
    for entry in "${PWA_DATA[@]}"; do
        local NAME=$(echo "$entry" | cut -d'|' -f1)
        if echo "$SELECTED" | grep -q "\"$NAME\""; then
            local BROWSER=$(echo "$entry" | cut -d'|' -f2)
            CONFIRM_TEXT+="  • $NAME ($BROWSER)\n"
        fi
    done

    whiptail --title "$TITLE" --yesno "$CONFIRM_TEXT\nConfirm removal?" 20 $W || return

    local COUNT=0
    for entry in "${PWA_DATA[@]}"; do
        local NAME=$(echo "$entry" | cut -d'|' -f1)
        if echo "$SELECTED" | grep -q "\"$NAME\""; then
            local FILE=$(echo "$entry" | cut -d'|' -f4)
            rm -f "$FILE"
            ((COUNT++))
        fi
    done

    whiptail --title "$TITLE" --msgbox "✓ Removed $COUNT PWA(s) successfully!" 8 $W
}

# Remove all PWAs
remove_all() {
    load_pwas
    if [ ${#PWA_DATA[@]} -eq 0 ]; then
        whiptail --title "$TITLE" --msgbox "No PWA shortcuts found." 8 $W
        return
    fi

    whiptail --title "$TITLE" --yesno "Create a backup before removing all ${#PWA_DATA[@]} PWA(s)?" 8 $W
    local BACKUP_CHOICE=$?
    [[ $BACKUP_CHOICE -eq 0 ]] && backup_pwas

    whiptail --title "$TITLE" \
        --yesno "WARNING: This will remove ALL ${#PWA_DATA[@]} PWA shortcuts!\n\nAre you sure?" \
        10 $W || return

    local COUNT=$(find "$APP_DIR" -maxdepth 1 -type f -name "*-pwa.desktop" 2>/dev/null | wc -l)
    rm -f "$APP_DIR"/*-pwa.desktop 2>/dev/null
    whiptail --title "$TITLE" --msgbox "✓ Removed $COUNT PWA shortcut(s)!" 8 $W
}

# Remove by browser
remove_by_browser() {
    load_pwas
    if [ ${#PWA_DATA[@]} -eq 0 ]; then
        whiptail --title "$TITLE" --msgbox "No PWA shortcuts found." 8 $W
        return
    fi

    # Count per browser
    declare -A BROWSER_COUNT
    for entry in "${PWA_DATA[@]}"; do
        local BROWSER=$(echo "$entry" | cut -d'|' -f2)
        BROWSER_COUNT[$BROWSER]=$(( ${BROWSER_COUNT[$BROWSER]:-0} + 1 ))
    done

    local MENU_ARGS=()
    for browser in "${!BROWSER_COUNT[@]}"; do
        MENU_ARGS+=("$browser" "${BROWSER_COUNT[$browser]} PWA(s)")
    done

    SELECTED_BROWSER=$(whiptail --title "$TITLE - Remove by Browser" \
        --menu "Select a browser to remove all its PWAs:" \
        $H $W 8 \
        "${MENU_ARGS[@]}" \
        3>&1 1>&2 2>&3) || return

    # List affected PWAs
    local CONFIRM_TEXT="PWAs using $SELECTED_BROWSER that will be removed:\n\n"
    local TO_REMOVE=()
    for entry in "${PWA_DATA[@]}"; do
        local BROWSER=$(echo "$entry" | cut -d'|' -f2)
        if [[ "$BROWSER" == "$SELECTED_BROWSER" ]]; then
            local NAME=$(echo "$entry" | cut -d'|' -f1)
            local FILE=$(echo "$entry" | cut -d'|' -f4)
            CONFIRM_TEXT+="  • $NAME\n"
            TO_REMOVE+=("$FILE")
        fi
    done

    whiptail --title "$TITLE" \
        --yesno "${CONFIRM_TEXT}\nRemove all ${#TO_REMOVE[@]} PWA(s) from $SELECTED_BROWSER?" \
        20 $W || return

    for f in "${TO_REMOVE[@]}"; do
        rm -f "$f"
    done

    whiptail --title "$TITLE" --msgbox "✓ Removed ${#TO_REMOVE[@]} PWA(s) from $SELECTED_BROWSER!" 8 $W
}

# Search PWAs
search_pwas() {
    SEARCH_TERM=$(whiptail --title "$TITLE - Search" \
        --inputbox "Enter search term (name / URL / browser):" 8 $W \
        3>&1 1>&2 2>&3) || return

    [[ -z "$SEARCH_TERM" ]] && { whiptail --title "$TITLE" --msgbox "Search term cannot be empty." 8 $W; return; }

    load_pwas

    local TEXT="Search results for: '$SEARCH_TERM'\n"
    TEXT+="─────────────────────────────────────────────────────────\n"
    local FOUND=0
    for entry in "${PWA_DATA[@]}"; do
        local NAME=$(echo "$entry"    | cut -d'|' -f1)
        local BROWSER=$(echo "$entry" | cut -d'|' -f2)
        local URL=$(echo "$entry"     | cut -d'|' -f3)
        if [[ "$NAME" =~ $SEARCH_TERM ]] || [[ "$URL" =~ $SEARCH_TERM ]] || [[ "$BROWSER" =~ $SEARCH_TERM ]]; then
            local DNAME="${NAME:0:22}"; [[ ${#NAME} -gt 22 ]] && DNAME="${DNAME}.."
            local DURL="${URL:0:30}";   [[ ${#URL}  -gt 30 ]] && DURL="${DURL}.."
            TEXT+=$(printf "%-24s %-12s %s\n" "$DNAME" "$BROWSER" "$DURL")
            TEXT+="\n"
            ((FOUND++))
        fi
    done
    TEXT+="─────────────────────────────────────────────────────────\n"
    TEXT+="Found: $FOUND PWA(s)"

    whiptail --title "$TITLE - Search Results" --scrolltext --msgbox "$TEXT" 25 $W
}

# Backup all PWAs
backup_pwas() {
    load_pwas
    if [ ${#PWA_DATA[@]} -eq 0 ]; then
        whiptail --title "$TITLE" --msgbox "No PWAs to backup." 8 $W
        return 1
    fi

    local TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    local BACKUP_PATH="$BACKUP_DIR/backup_$TIMESTAMP"
    mkdir -p "$BACKUP_PATH"

    for f in "${PWA_FILES[@]}"; do
        cp "$f" "$BACKUP_PATH/"
    done

    whiptail --title "$TITLE" --msgbox "✓ Backed up ${#PWA_FILES[@]} PWA(s) to:\n$BACKUP_PATH" 10 $W
}

# Restore from backup
restore_backup() {
    mapfile -t BACKUPS < <(find "$BACKUP_DIR" -maxdepth 1 -type d -name "backup_*" 2>/dev/null | sort -r)

    if [ ${#BACKUPS[@]} -eq 0 ]; then
        whiptail --title "$TITLE" --msgbox "No backups found." 8 $W
        return
    fi

    local MENU_ARGS=()
    for backup in "${BACKUPS[@]}"; do
        local BNAME=$(basename "$backup")
        local COUNT=$(find "$backup" -type f -name "*-pwa.desktop" 2>/dev/null | wc -l)
        MENU_ARGS+=("$BNAME" "$COUNT PWA(s)")
    done

    SELECTED_BNAME=$(whiptail --title "$TITLE - Restore Backup" \
        --menu "Select a backup to restore:" \
        $H $W 8 \
        "${MENU_ARGS[@]}" \
        3>&1 1>&2 2>&3) || return

    local SELECTED_BPATH="$BACKUP_DIR/$SELECTED_BNAME"

    whiptail --title "$TITLE" \
        --yesno "Restore PWAs from '$SELECTED_BNAME'?" 8 $W || return

    cp "$SELECTED_BPATH"/*.desktop "$APP_DIR/" 2>/dev/null
    local COUNT=$(find "$SELECTED_BPATH" -type f -name "*.desktop" 2>/dev/null | wc -l)
    whiptail --title "$TITLE" --msgbox "✓ Restored $COUNT PWA(s) successfully!" 8 $W
}

# ----- Main Menu Loop -----
while true; do
    CHOICE=$(whiptail --title "$TITLE" \
        --menu "Select an option:" $H $W 9 \
        "1" "📋  View all PWAs" \
        "2" "🗑️   Remove selected PWAs" \
        "3" "💣  Remove all PWAs" \
        "4" "🌐  Remove by browser" \
        "5" "🔍  Search PWAs" \
        "6" "💾  Backup all PWAs" \
        "7" "♻️   Restore from backup" \
        "0" "🚪  Exit" \
        3>&1 1>&2 2>&3) || break

    case "$CHOICE" in
        1) view_all_pwas ;;
        2) remove_selected ;;
        3) remove_all ;;
        4) remove_by_browser ;;
        5) search_pwas ;;
        6) backup_pwas ;;
        7) restore_backup ;;
        0) break ;;
    esac
done

whiptail --title "$TITLE" --msgbox "Thank you for using PWA Remover!" 8 $W