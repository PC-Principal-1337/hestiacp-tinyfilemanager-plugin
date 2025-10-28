#!/bin/bash

# HestiaCP TinyFileManager Plugin - Uninstallation Script
# https://github.com/PC-Principal-1337/hestiacp-tinyfilemanager-plugin

set -e

echo "===================================================="
echo "HestiaCP TinyFileManager Plugin Uninstaller"
echo "===================================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: Please run as root (use sudo)"
    exit 1
fi

# Confirm uninstallation
read -p "Are you sure you want to uninstall TinyFileManager Plugin? (yes/no): " -r
echo
if [[ ! $REPLY =~ ^[Yy]es$ ]]; then
    echo "Uninstallation cancelled."
    exit 0
fi

PATCHES_DIR="/usr/local/hestia/web/filemanager/patches"

echo "[1/3] Reverting Hestia UI patches..."

# Revert panel.php (global icon) using reverse patch
PANEL="/usr/local/hestia/web/templates/includes/panel.php"
if [ -f "$PANEL" ] && [ -f "$PATCHES_DIR/hestia-panel.patch" ]; then
    if grep -q 'href="/filemanager/?p="' "$PANEL"; then
        # Backup before reverting
        cp "$PANEL" "${PANEL}.pre-uninstall.$(date +%s)"

        if patch -R --dry-run -p1 "$PANEL" < "$PATCHES_DIR/hestia-panel.patch" >/dev/null 2>&1; then
            patch -R -p1 "$PANEL" < "$PATCHES_DIR/hestia-panel.patch"
            echo "  Panel reverted to Filegator (using reverse patch)"
        else
            # Fallback to sed if patch fails
            sed -i 's|href="/filemanager/?p="|href="/fm/"|' "$PANEL"
            echo "  Panel reverted using fallback method"
        fi
    else
        echo "  Panel not patched or already reverted"
    fi
fi

# Revert list_web.php (domain button) using sed
LIST_WEB="/usr/local/hestia/web/templates/pages/list_web.php"
if [ -f "$LIST_WEB" ]; then
    if grep -q 'href="/filemanager/?p=<?= $key ?>/public_html"' "$LIST_WEB"; then
        # Backup before reverting
        cp "$LIST_WEB" "${LIST_WEB}.pre-uninstall.$(date +%s)"

        # Revert changes
        sed -i 's|href="/filemanager/?p=<?= $key ?>|href="/filemanager/?p=/web/<?= $key ?>|' "$LIST_WEB"
        sed -i 's|target="_self"|target="_blank"|' "$LIST_WEB"
        echo "  Domain list button reverted"
    else
        echo "  Domain list not patched or already reverted"
    fi
fi

echo "[2/4] Removing filemanager directory..."
if [ -d "/usr/local/hestia/web/filemanager" ]; then
    rm -rf /usr/local/hestia/web/filemanager
    echo "  File manager removed successfully"
else
    echo "  File manager directory not found (already removed?)"
fi

echo "[3/3] Cleaning up..."
echo "  Note: FILE_MANAGER setting kept as-is (buttons will show Filegator)"
echo "  Note: ACL permissions for hestiaweb user are kept"
echo "  They won't cause issues and may be used by other services"

echo ""
echo "===================================================="
echo "Uninstallation Complete!"
echo "===================================================="
echo ""
echo "TinyFileManager Plugin has been removed from your system."
echo "Hestia UI has been reverted to default (Filegator links)."
echo ""
echo "If you want to completely remove ACL permissions:"
echo "  for user in \$(ls /home); do"
echo "    sudo setfacl -R -x u:hestiaweb /home/\$user/web 2>/dev/null || true"
echo "  done"
echo ""
echo "Backup files created during uninstall:"
echo "  /usr/local/hestia/web/templates/**/*.pre-uninstall.*"
echo ""

exit 0
