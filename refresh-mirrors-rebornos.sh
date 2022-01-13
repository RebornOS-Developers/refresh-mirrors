#!/usr/bin/env sh

wait_and_exit() {
    WAIT_TIME="$1"
    EXIT_CODE="$2"    

    read -n 1 -s -r -t "$WAIT_TIME" -p "Press any key to exit..."
    exit "$EXIT_CODE"
}

# ========================
# Refresh RebornOS Mirrors
# ========================

TEMP_DIR="/tmp/pacman.d"
DESTINATION_DIR="/etc/pacman.d"
MIRRORLIST_FILENAME="reborn-mirrorlist"

TEMP_FILE="$TEMP_DIR/$MIRRORLIST_FILENAME"
MIRRORLIST_FILE="$DESTINATION_DIR/$MIRRORLIST_FILENAME"

set -o xtrace
mkdir -p "$TEMP_DIR"
rm -f "$TEMP_FILE"
set +o xtrace

echo "Ranking RebornOS Mirrors..."
echo ""
/usr/bin/rate-mirrors --concurrency=16 --per-mirror-timeout=3000 --allow-root --save="$TEMP_FILE" rebornos
echo ""
echo ""

REBORN_MIRROR_REFRESH_FAILED="$?"
REBORN_MIRROR_REFRESH_LOG_FILE="$TEMP_FILE"
if [ "$REBORN_MIRROR_REFRESH_FAILED" -eq 0 ]; then
    echo ""  
    set -o xtrace      
    pkexec cp -f "$TEMP_FILE" "$MIRRORLIST_FILE"
    set +o xtrace
    echo ""
fi

# ==========================
# Refresh Arch Linux Mirrors
# ==========================

TEMP_DIR="/tmp/pacman.d"
DESTINATION_DIR="/etc/pacman.d"
MIRRORLIST_FILENAME="mirrorlist"

TEMP_FILE="$TEMP_DIR/$MIRRORLIST_FILENAME"
MIRRORLIST_FILE="$DESTINATION_DIR/$MIRRORLIST_FILENAME"

set -o xtrace
mkdir -p "$TEMP_DIR"
rm -f "$TEMP_FILE"
set +o xtrace

echo "Ranking Arch Linux Mirrors..."
echo ""
/usr/bin/rate-mirrors --protocol=https --allow-root --save="$TEMP_FILE" arch
echo ""
echo ""

ARCH_MIRROR_REFRESH_FAILED="$?"
ARCH_MIRROR_REFRESH_LOG_FILE="$TEMP_FILE"
if [ "$ARCH_MIRROR_REFRESH_FAILED" -eq 0 ]; then    
    echo ""  
    set -o xtrace      
    pkexec cp -f "$TEMP_FILE" "$MIRRORLIST_FILE"
    set +o xtrace
    echo ""
fi

# =========================
# Check exit codes and exit
# =========================

if [ "$REBORN_MIRROR_REFRESH_FAILED" -ne 0 ]; then
    echo "Refresh of RebornOS mirrors failed with exit code: $REBORN_MIRROR_REFRESH_FAILED"
    echo "Please check the log at: file://$REBORN_MIRROR_REFRESH_LOG_FILE"
    echo ""    
    wait_and_exit 20 "$REBORN_MIRROR_REFRESH_FAILED"
elif [ "$ARCH_MIRROR_REFRESH_FAILED" -ne 0 ]; then
    echo "Refresh of Arch Linux mirrors failed with exit code: $REBORN_MIRROR_REFRESH_FAILED"
    echo "Please check the log at: file://$ARCH_MIRROR_REFRESH_LOG_FILE"
    echo ""    
    wait_and_exit 20 "$ARCH_MIRROR_REFRESH_FAILED"
else
    echo "Refresh of both RebornOS and Arch Linux mirrors completed successfully!"
    echo ""  
    wait_and_exit 10 0
fi
