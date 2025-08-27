#!/bin/bash

set -e

echo "=== Omarchy ARM Installation Fix ==="
echo "This script will install Omarchy with ARM architecture fixes."
echo

# Check if we're on ARM
ARCH=$(uname -m)
if [[ "$ARCH" != "aarch64" && "$ARCH" != "arm64" ]]; then
    echo "Warning: This script is designed for ARM systems. Detected: $ARCH"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo "Step 1: Cloning original Omarchy repository..."
if [[ -d ~/.local/share/omarchy ]]; then
    echo "Omarchy directory already exists. Backing up..."
    mv ~/.local/share/omarchy ~/.local/share/omarchy.backup.$(date +%Y%m%d-%H%M%S)
fi

git clone https://github.com/omarhanykasban/omarchy.git ~/.local/share/omarchy
cd ~/.local/share/omarchy

echo "Step 2: Applying ARM compatibility patches..."

# Apply patches
echo "  - Applying package compatibility patch..."
patch -p1 < "$SCRIPT_DIR/patches/packages.patch"

echo "  - Applying webapp launcher patch..."
patch -p1 < "$SCRIPT_DIR/patches/webapp-launcher.patch"

echo "  - Applying MIME types patch..."
patch -p1 < "$SCRIPT_DIR/patches/mimetypes.patch"

echo "  - Applying install script patch..."
patch -p1 < "$SCRIPT_DIR/patches/install-script.patch"

echo "Step 3: Adding missing configuration files..."

# Copy missing config files
echo "  - Adding zoom.conf..."
cp "$SCRIPT_DIR/config-files/hypr/apps/zoom.conf" ~/.local/share/omarchy/default/hypr/apps/

echo "  - Fixing 1password.conf..."
cp "$SCRIPT_DIR/config-files/hypr/apps/1password.conf" ~/.local/share/omarchy/default/hypr/apps/

echo "Step 4: Installing Firefox (ARM browser alternative)..."
if ! pacman -Q firefox &> /dev/null; then
    sudo pacman -S --noconfirm firefox
else
    echo "  - Firefox already installed"
fi

echo "Step 5: Setting Firefox as default browser..."
xdg-settings set default-web-browser firefox.desktop

echo "Step 6: Cleaning up previous Omarchy entries from pacman.conf..."
# Remove any existing omarchy entries
sudo sed -i '/\[omarchy\]/,+2d' /etc/pacman.conf 2>/dev/null || true
sudo rm -f /etc/pacman.d/omarchy* 2>/dev/null || true

echo
echo "=== ARM fixes applied successfully! ==="
echo
echo "Now running the Omarchy installation script..."
echo "Note: The installation may take a while to complete."
echo

read -p "Press Enter to continue with installation, or Ctrl+C to exit..."

# Run the installation
cd ~/.local/share/omarchy
./install.sh

echo
echo "=== Installation Complete! ==="
echo "Your Omarchy installation is now ARM-compatible."
echo
echo "If you encounter any issues, check:"
echo "1. Hyprland config: hyprctl reload"
echo "2. Default browser: xdg-settings get default-web-browser"
echo "3. Package availability: pacman -Ss package-name"
