#!/bin/bash

# Manual patch application script for existing Omarchy installations

set -e

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <omarchy-directory>"
    echo "Example: $0 ~/.local/share/omarchy"
    exit 1
fi

OMARCHY_DIR="$1"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

if [[ ! -d "$OMARCHY_DIR" ]]; then
    echo "Error: Omarchy directory does not exist: $OMARCHY_DIR"
    exit 1
fi

echo "Applying ARM fixes to: $OMARCHY_DIR"

cd "$OMARCHY_DIR"

echo "1. Applying package compatibility patch..."
patch -p1 < "$SCRIPT_DIR/patches/packages.patch"

echo "2. Applying webapp launcher patch..."
patch -p1 < "$SCRIPT_DIR/patches/webapp-launcher.patch"

echo "3. Applying MIME types patch..."
patch -p1 < "$SCRIPT_DIR/patches/mimetypes.patch"

echo "4. Applying install script patch..."
patch -p1 < "$SCRIPT_DIR/patches/install-script.patch"

echo "5. Adding missing configuration files..."
cp "$SCRIPT_DIR/config-files/hypr/apps/zoom.conf" "$OMARCHY_DIR/default/hypr/apps/"
cp "$SCRIPT_DIR/config-files/hypr/apps/1password.conf" "$OMARCHY_DIR/default/hypr/apps/"

echo "6. Installing Firefox if not present..."
if ! pacman -Q firefox &> /dev/null; then
    echo "Installing Firefox..."
    sudo pacman -S --noconfirm firefox
else
    echo "Firefox already installed"
fi

echo "7. Setting Firefox as default browser..."
xdg-settings set default-web-browser firefox.desktop

echo
echo "ARM fixes applied successfully!"
echo "You can now run: $OMARCHY_DIR/install.sh"
