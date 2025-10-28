#!/bin/bash

# HestiaCP TinyFileManager Integration - Installation Script
# https://github.com/PC-Principal-1337/hestiacp-tinyfilemanager-plugin

set -e

echo "================================================"
echo "HestiaCP TinyFileManager Integration Installer"
echo "================================================"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: Please run as root (use sudo)"
    exit 1
fi

# Check if Hestia is installed
if [ ! -d "/usr/local/hestia" ]; then
    echo "Error: Hestia Control Panel not found"
    echo "Please install Hestia first: https://hestiacp.com"
    exit 1
fi

# Check for hestiaweb user
if ! id "hestiaweb" &>/dev/null; then
    echo "Error: hestiaweb user not found"
    echo "This is required for file manager operation"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[1/9] Creating filemanager directory..."
mkdir -p /usr/local/hestia/web/filemanager

echo "[2/9] Downloading TinyFileManager..."
cd /tmp
wget -q https://github.com/prasathmani/tinyfilemanager/archive/refs/heads/master.zip -O tinyfilemanager.zip
unzip -q -o tinyfilemanager.zip

echo "[3/9] Installing TinyFileManager base..."
cp /tmp/tinyfilemanager-master/tinyfilemanager.php /usr/local/hestia/web/filemanager/

echo "[4/9] Applying HestiaCP integration patches to TinyFileManager..."
if patch --dry-run -p0 /usr/local/hestia/web/filemanager/tinyfilemanager.php < "$SCRIPT_DIR/patches/tinyfilemanager.patch" >/dev/null 2>&1; then
    patch -p0 /usr/local/hestia/web/filemanager/tinyfilemanager.php < "$SCRIPT_DIR/patches/tinyfilemanager.patch"
    echo "  TinyFileManager patched successfully"
else
    echo "  Warning: TinyFileManager patch failed (version mismatch?)"
    echo "  Continuing with unpatched version - some features may not work optimally"
fi

echo "[5/9] Installing wrapper and configuration..."
cp "$SCRIPT_DIR/src/index.php" /usr/local/hestia/web/filemanager/
cp "$SCRIPT_DIR/src/config.php.template" /usr/local/hestia/web/filemanager/config.php

# Copy patches for uninstaller (reverse-patch support)
mkdir -p /usr/local/hestia/web/filemanager/patches
cp "$SCRIPT_DIR/patches/"*.patch /usr/local/hestia/web/filemanager/patches/

echo "[6/9] Setting permissions..."
chown hestiaweb:hestiaweb /usr/local/hestia/web/filemanager/config.php
chmod 644 /usr/local/hestia/web/filemanager/config.php

echo "[7/9] Setting ACL permissions for existing users..."
USER_COUNT=0
for user_home in /home/*; do
    if [ -d "$user_home" ]; then
        user=$(basename "$user_home")

        # Skip system users
        if [ "$user" = "lost+found" ]; then
            continue
        fi

        # Check if user has a web directory
        if [ -d "$user_home/web" ]; then
            echo "  - Setting ACLs for user: $user"

            # Set recursive ACLs for existing files
            setfacl -R -m u:hestiaweb:rwx "$user_home/web" 2>/dev/null || true

            # Set default ACLs for new files
            setfacl -R -d -m u:hestiaweb:rwx "$user_home/web" 2>/dev/null || true

            ((USER_COUNT++))
        fi
    fi
done

echo "[8/9] Patching Hestia UI..."

# Backup
cp /usr/local/hestia/web/templates/pages/list_web.php /usr/local/hestia/web/templates/pages/list_web.php.backup.$(date +%s) 2>/dev/null || true
cp /usr/local/hestia/web/templates/includes/panel.php /usr/local/hestia/web/templates/includes/panel.php.backup.$(date +%s) 2>/dev/null || true

# Apply list_web.php patch
if (cd /usr/local/hestia && patch --dry-run -p1 < "$SCRIPT_DIR/patches/hestia-list_web.patch") >/dev/null 2>&1; then
    (cd /usr/local/hestia && patch -p1 < "$SCRIPT_DIR/patches/hestia-list_web.patch")
    echo "  Domain button patched successfully"
else
    echo "  Domain button already patched or patch not applicable"
fi

# Apply panel.php patch
if (cd /usr/local/hestia && patch --dry-run -p1 < "$SCRIPT_DIR/patches/hestia-panel.patch") >/dev/null 2>&1; then
    (cd /usr/local/hestia && patch -p1 < "$SCRIPT_DIR/patches/hestia-panel.patch")
    echo "  Global icon patched successfully"
else
    echo "  Global icon already patched or patch not applicable"
fi

echo "[9/9] Enabling FILE_MANAGER in Hestia config..."
HESTIA_CONF="/usr/local/hestia/conf/hestia.conf"
if [ -f "$HESTIA_CONF" ]; then
    if grep -q "FILE_MANAGER='false'" "$HESTIA_CONF"; then
        sed -i "s/FILE_MANAGER='false'/FILE_MANAGER='true'/" "$HESTIA_CONF"
        echo "  FILE_MANAGER enabled (domain button will appear)"
    elif grep -q "FILE_MANAGER='true'" "$HESTIA_CONF"; then
        echo "  FILE_MANAGER already enabled"
    else
        # Add if not present
        echo "FILE_MANAGER='true'" >> "$HESTIA_CONF"
        echo "  FILE_MANAGER added to config"
    fi
fi

echo ""
echo "================================================"
echo "Installation Complete!"
echo "================================================"
echo ""
echo "File Manager URL: https://$(hostname):8083/filemanager/"
echo "ACL permissions set for $USER_COUNT user(s)"
echo ""
echo "Note: The file manager uses Hestia authentication."
echo "Log in to Hestia and access the file manager from"
echo "the Web section or directly via the URL above."
echo ""
echo "For troubleshooting, see:"
echo "  https://github.com/PC-Principal-1337/hestiacp-tinyfilemanager-plugin"
echo ""

# Cleanup
rm -rf /tmp/tinyfilemanager-master /tmp/tinyfilemanager.zip

exit 0
