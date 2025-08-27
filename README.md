# Omarchy ARM Installation Fix

This repository contains fixes for installing Omarchy on ARM architecture systems (aarch64), specifically tested on Arch Linux ARM. These fixes work with the Armarchy fork (https://github.com/nilszeilon/armarchy) which is an ARM-focused version of Omarchy.

## Overview

Even the ARM-focused Armarchy installation script has several issues when running on ARM systems:

1. **Package availability**: Many packages in the default list aren't available for ARM
2. **Browser configuration**: Chromium isn't available, requiring Firefox as alternative
3. **Configuration file issues**: Missing configuration files cause Hyprland errors
4. **Terminal effects**: Text animation packages aren't available on ARM

## Quick Installation

```bash
# Clone this repository
git clone https://github.com/happybigmtn/omarchy-arm-fixes.git ~/omarchy-arm-fixes
cd ~/omarchy-arm-fixes

# Run the ARM installation fix script
./install-omarchy-arm.sh
```

## Manual Installation Steps

If you prefer to understand and apply fixes manually:

### 1. Initial Omarchy Clone

```bash
# Clone the Armarchy repository (ARM-focused fork of Omarchy)
git clone https://github.com/nilszeilon/armarchy.git ~/.local/share/omarchy
cd ~/.local/share/omarchy
```

### 2. Apply ARM Fixes

```bash
# Apply all patches
cd ~/omarchy-arm-fixes
./apply-arm-fixes.sh ~/.local/share/omarchy
```

### 3. Install Firefox (ARM Browser Alternative)

```bash
sudo pacman -S --noconfirm firefox
xdg-settings set default-web-browser firefox.desktop
```

### 4. Run Installation

```bash
cd ~/.local/share/omarchy
./install.sh
```

## Issues Fixed

### 1. Package Compatibility Issues

**Problem**: Original `packages.sh` tries to install x86_64-only packages on ARM.

**Fix**: Created conditional package installation based on `OMARCHY_ARM` flag:
- Removed ARM-incompatible packages: `1password-beta`, `1password-cli`, `obs-studio`, `obsidian`, `spotify`, etc.
- Added ARM-specific alternatives where available
- Specified `libreoffice-fresh` instead of generic `libreoffice`

### 2. Browser Configuration Issues

**Problem**: Scripts hardcoded Chromium as default browser, not available on ARM.

**Files affected**:
- `bin/omarchy-launch-webapp`
- `install/config/mimetypes.sh`

**Fix**: Added ARM detection and Firefox fallback:
- Modified webapp launcher to dynamically detect ARM architecture and use Firefox
- Updated MIME type configuration to set Firefox as default on ARM
- Fixed web app keybindings (Super+X, Super+A, etc.) to use Firefox instead of Chromium

### 3. Missing Configuration Files

**Problem**: `zoom.conf` referenced but missing, causing Hyprland config errors.

**Fix**: Created missing configuration file with basic window rules.

### 4. Invalid Window Rules

**Problem**: `noscreenshare` window rule not supported in current Hyprland version.

**Fix**: Commented out invalid rule in `apps/1password.conf`.

### 5. Terminal Text Effects Not Available

**Problem**: `python-terminaltexteffects` package not available on ARM.

**Fix**: Modified install script to use simple text display on ARM instead of animated effects.

## File Modifications Summary

- `install/packages.sh`: Added ARM-specific package list
- `bin/omarchy-launch-webapp`: Added Firefox support for ARM
- `install/config/mimetypes.sh`: Added browser selection logic
- `install.sh`: Added fallback for text effects on ARM
- `default/hypr/apps/zoom.conf`: Created missing config file
- `default/hypr/apps/1password.conf`: Fixed invalid window rule

## Testing

Tested on:
- **System**: Arch Linux ARM on Apple Silicon (M1/M2)
- **Architecture**: aarch64
- **Hyprland Version**: 0.49.0

## Contributing

If you encounter issues or have improvements for ARM compatibility:

1. Document the specific error
2. Identify the root cause
3. Test the fix thoroughly
4. Update this documentation

## Troubleshooting

### Common Issues

#### Hyprland Configuration Errors
```bash
# Reload configuration to check for errors
hyprctl reload
```

#### Missing Packages
```bash
# Check if a package exists for ARM
pacman -Ss package-name
```

#### Browser Issues
```bash
# Verify default browser setting
xdg-settings get default-web-browser
```

### Debug Mode

Run installation with debug output:
```bash
OMARCHY_DEBUG=true ./install.sh
```

## Support

For issues specific to ARM installation, check:
1. This repository's Issues section
2. Original Omarchy Discord: https://discord.gg/tXFUdasqhY
3. Arch Linux ARM documentation

## License

Same as original Omarchy project.
