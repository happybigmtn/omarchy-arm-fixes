# Technical Details: Omarchy ARM Compatibility Issues

This document provides detailed technical analysis of the issues encountered when installing Omarchy on ARM architecture and the solutions implemented.

## Architecture Detection

Omarchy correctly detects ARM architecture in `install/preflight/arm.sh`:

```bash
arch=$(uname -m)
if [[ "$arch" == "aarch64" || "$arch" == "arm64" ]]; then
  export OMARCHY_ARM=true
  export OMARCHY_BARE=true
```

However, the rest of the installation scripts don't properly use this flag.

## Issue Analysis

### 1. Package Availability Problem

**File**: `install/packages.sh`  
**Issue**: Hardcoded package list includes x86_64-only packages  
**Error**: `error: target not found: package-name`

#### Packages Not Available on ARM:
- `1password-beta` / `1password-cli` - Proprietary, no ARM builds
- `obs-studio` - Available but different package name structure
- `obsidian` - Electron app, no official ARM package
- `spotify` - Proprietary, no ARM support
- `signal-desktop` - Available but dependency issues
- `python-terminaltexteffects` - Python package dependency issues
- `gcc14` - Different versioning on ARM repos
- `yay` - AUR helper, different installation method needed
- `walker-bin` - Binary package, no ARM version
- `omarchy-chromium` - Custom package, x86_64 only

#### Solution Implementation:
```bash
if [[ "$OMARCHY_ARM" == "true" ]]; then
  # ARM-compatible packages only
  sudo pacman -S --noconfirm --needed \
    # ... filtered package list
else
  # Full x86_64 package list
```

### 2. Browser Configuration Problems

#### Problem 1: Default Browser Setting
**File**: `install/config/mimetypes.sh`  
**Issue**: Hardcoded Chromium browser configuration  
**Error**: `error: could not find handler for chromium.desktop`

**Root Cause**: Chromium package not available for ARM

**Solution**: Conditional browser selection
```bash
if [[ "$OMARCHY_ARM" == "true" ]]; then
  # Use Firefox on ARM systems
  xdg-settings set default-web-browser firefox.desktop
else
  # Use Chromium on x86_64 systems  
  xdg-settings set default-web-browser chromium.desktop
fi
```

#### Problem 2: Web App Launcher
**File**: `bin/omarchy-launch-webapp`  
**Issue**: Hardcoded fallback to Chromium

**Original Code**:
```bash
case $browser in
google-chrome* | brave-browser* | microsoft-edge* | opera* | vivaldi*) ;;
*) browser="chromium.desktop" ;;
esac
```

**Solution**: ARM-aware browser selection
```bash
*) 
  if [[ "$OMARCHY_ARM" == "true" ]] && [[ -f "/usr/share/applications/firefox.desktop" ]]; then
    browser="firefox.desktop"
  else
    browser="chromium.desktop"
  fi
  ;;
```

### 3. Missing Configuration Files

#### Problem: Missing zoom.conf
**File**: Referenced in `default/hypr/aarch64_apps.conf`  
**Issue**: Configuration file doesn't exist  
**Error**: `Config error: source file not found`

**Analysis**: The ARM-specific apps configuration references `zoom.conf` but the file is missing from the repository.

**Solution**: Create minimal zoom.conf
```bash
# Zoom configuration for Hyprland
windowrulev2 = float, class:^(zoom)$
windowrulev2 = center, class:^(zoom)$
```

#### Problem: Invalid Window Rule
**File**: `default/hypr/apps/1password.conf`  
**Issue**: `noscreenshare` rule not supported  
**Error**: `invalid rulev2 noscreenshare found`

**Root Cause**: Window rule syntax not supported in Hyprland 0.49.0

**Solution**: Comment out invalid rule
```bash
# windowrule = noscreenshare, class:^(1Password)$
```

### 4. Terminal Text Effects Problem

**File**: `install.sh`  
**Issue**: `python-terminaltexteffects` not available on ARM  
**Error**: `command not found: tte`

**Root Cause**: Python package dependencies not available for ARM architecture

**Solution**: Graceful fallback
```bash
if [[ "$OMARCHY_ARM" == "true" ]] || ! command -v tte >/dev/null 2>&1; then
  # Display simple message
  cat ~/.local/share/omarchy/logo.txt
  echo "You're done! So we're ready to reboot now..."
else
  # Use fancy animations
  tte -i ~/.local/share/omarchy/logo.txt --frame-rate 920 laseretch
fi
```

### 5. Repository Configuration Issues

**Problem**: Duplicate omarchy repository entries  
**Files**: `/etc/pacman.conf`  
**Error**: `database already registered`

**Root Cause**: Previous installation attempts left orphaned repository configuration

**Solution**: Clean up before installation
```bash
sudo sed -i '/\[omarchy\]/,+2d' /etc/pacman.conf
sudo rm -f /etc/pacman.d/omarchy*
```

## ARM-Specific Considerations

### Package Manager Differences

ARM repositories have different package availability:
- Fewer proprietary applications
- Different versioning schemes  
- Some packages require compilation from source
- AUR availability varies

### Performance Considerations

ARM systems typically have:
- Different memory constraints
- Different GPU acceleration support
- Thermal throttling considerations
- Power efficiency requirements

### Browser Selection Rationale

Firefox chosen over Chromium for ARM because:
1. **Official Support**: Firefox has official ARM64 builds
2. **Repository Availability**: Available in main ARM repositories
3. **Web Standards**: Full web standards support
4. **Performance**: Optimized for ARM architecture
5. **Extension Support**: Full extension ecosystem

## Testing Methodology

### Test Environment
- **Hardware**: Apple Silicon (M1/M2) Mac
- **OS**: Arch Linux ARM
- **Architecture**: aarch64
- **Hyprland Version**: 0.49.0

### Test Procedure
1. Clean installation on fresh ARM system
2. Apply patches incrementally
3. Test each component individually
4. Verify full installation workflow
5. Test configuration reloads
6. Verify web app functionality

### Validation Steps
```bash
# Architecture detection
uname -m

# Package availability check
pacman -Ss package-name

# Configuration validation
hyprctl reload

# Browser functionality
xdg-settings get default-web-browser

# Web app launcher test
omarchy-launch-webapp https://example.com
```

## Future Improvements

### Automated Package Detection
Could implement dynamic package availability checking:
```bash
check_package_availability() {
  pacman -Ss "$1" &>/dev/null
}
```

### Better ARM Detection
More comprehensive architecture detection:
```bash
detect_architecture() {
  case "$(uname -m)" in
    aarch64|arm64) echo "arm" ;;
    x86_64|amd64) echo "x86_64" ;;
    *) echo "unknown" ;;
  esac
}
```

### Configuration Validation
Add configuration file validation before sourcing:
```bash
validate_config_file() {
  [[ -f "$1" ]] && hyprctl check-config "$1"
}
```

## Dependencies

### Required Packages (ARM)
- `firefox` - Web browser
- `hyprland` - Window manager
- `git` - Version control
- `patch` - Patch application

### Optional Packages
- `base-devel` - Development tools
- `yay` - AUR helper (manual installation required)

## Known Limitations

1. **AUR Packages**: Many AUR packages don't have ARM support
2. **Proprietary Software**: Limited availability on ARM
3. **Performance**: Some packages may have reduced performance
4. **Gaming**: Limited gaming support compared to x86_64

## Maintenance

This fix package should be updated when:
1. Omarchy upstream changes package requirements
2. ARM package availability changes
3. Hyprland configuration syntax changes
4. New ARM-specific issues are discovered
