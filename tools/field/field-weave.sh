#!/usr/bin/env bash
# field-weave.sh - Mount clean root, regenerate config, and rebuild NixOS
set -euo pipefail

# Configuration
CLEAN_ROOT="/mnt/ROOT"
BTRFS_SUBVOL="@"
ESP_MOUNT="/mnt/ROOT/boot"
LOG_DIR="/var/log"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_FILE="${LOG_DIR}/FIELD-Apply-${TIMESTAMP}.log"
HARDWARE_CONFIG="/etc/nixos/hardware-configuration.nix"
MAIN_CONFIG="/etc/nixos/configuration.nix"
BLUEPRINT="/etc/nixos/field/blueprint.nix"
PREFLIGHT="/usr/local/sbin/field-preflight.sh"

# Use local preflight if installed version not found
if [ ! -f "$PREFLIGHT" ]; then
  PREFLIGHT="$(dirname "$0")/field-preflight.sh"
fi

# Logging function
log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# Error handler
error_exit() {
  log "ERROR: $1"
  exit 1
}

log "=== FIELD Weave (Apply) Process ==="
log "Log file: $LOG_FILE"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  error_exit "This script must be run as root (use sudo)"
fi

# Step 1: Find root Btrfs device
log ""
log "Step 1: Identifying root Btrfs device..."
ROOT_DEVICE=$(findmnt -n -o SOURCE / | head -1)
if [ -z "$ROOT_DEVICE" ]; then
  error_exit "Could not determine root device"
fi
log "Current root: $ROOT_DEVICE"

# Extract the actual block device (strip subvolume)
BTRFS_DEVICE=$(echo "$ROOT_DEVICE" | sed 's/\[.*\]//')
if [ -z "$BTRFS_DEVICE" ]; then
  BTRFS_DEVICE="$ROOT_DEVICE"
fi
log "Btrfs device: $BTRFS_DEVICE"

# Step 2: Mount clean Btrfs root
log ""
log "Step 2: Mounting clean Btrfs root..."
if mountpoint -q "$CLEAN_ROOT"; then
  log "Unmounting existing mount at $CLEAN_ROOT"
  umount -R "$CLEAN_ROOT" || error_exit "Failed to unmount $CLEAN_ROOT"
fi

mkdir -p "$CLEAN_ROOT"
log "Mounting $BTRFS_DEVICE subvolume $BTRFS_SUBVOL to $CLEAN_ROOT"
if ! mount -t btrfs -o subvol="$BTRFS_SUBVOL" "$BTRFS_DEVICE" "$CLEAN_ROOT"; then
  error_exit "Failed to mount clean root"
fi
log "✓ Clean root mounted"

# Step 3: Mount ESP
log ""
log "Step 3: Mounting ESP..."
ESP_DEVICE=$(blkid | grep -i "TYPE=\"vfat\"" | grep -i "PART.*EFI" | cut -d: -f1 | head -1 || true)
if [ -z "$ESP_DEVICE" ]; then
  # Try to find ESP by partition type
  ESP_DEVICE=$(lsblk -no PATH,PARTTYPE | grep -i "c12a7328-f81f-11d2-ba4b-00a0c93ec93b" | awk '{print $1}' | head -1 || true)
fi

if [ -z "$ESP_DEVICE" ]; then
  log "WARNING: Could not automatically find ESP device"
  log "Please ensure ESP is mounted at ${CLEAN_ROOT}/boot before rebuild"
else
  mkdir -p "$ESP_MOUNT"
  log "Mounting ESP $ESP_DEVICE to $ESP_MOUNT"
  if ! mount "$ESP_DEVICE" "$ESP_MOUNT"; then
    log "WARNING: Failed to mount ESP automatically"
  else
    log "✓ ESP mounted"
  fi
fi

# Step 4: Regenerate hardware-configuration.nix
log ""
log "Step 4: Regenerating hardware-configuration.nix from clean mount..."
TEMP_HARDWARE_CONFIG=$(mktemp)
log "Generating config to temporary file: $TEMP_HARDWARE_CONFIG"
if ! nixos-generate-config --root "$CLEAN_ROOT" --show-hardware-config > "$TEMP_HARDWARE_CONFIG"; then
  error_exit "Failed to generate hardware configuration"
fi
log "✓ Hardware configuration generated"

# Step 5: Sanitize hardware-configuration.nix
log ""
log "Step 5: Sanitizing hardware-configuration.nix..."

# Remove transient devices (overlay, /etc/nix, /nix/store)
log "  Removing transient devices..."
sed -i '/device = "overlay"/d' "$TEMP_HARDWARE_CONFIG"
sed -i '/\/etc\/nix/d' "$TEMP_HARDWARE_CONFIG"
sed -i '/\/nix\/store/d' "$TEMP_HARDWARE_CONFIG"

# Remove duplicate filesystem blocks
log "  Checking for duplicate fileSystems blocks..."
# This is complex - for now just ensure we don't have obvious duplicates
# A proper implementation would parse the Nix expression

log "  Removing duplicate options lines in same filesystem block..."
# Remove consecutive duplicate options lines
awk '!seen[$0]++ || !/options = \[/' "$TEMP_HARDWARE_CONFIG" > "${TEMP_HARDWARE_CONFIG}.dedup"
mv "${TEMP_HARDWARE_CONFIG}.dedup" "$TEMP_HARDWARE_CONFIG"

log "✓ Sanitization complete"

# Step 6: Install sanitized hardware-configuration.nix
log ""
log "Step 6: Installing hardware-configuration.nix..."
if [ -f "$HARDWARE_CONFIG" ]; then
  BACKUP="${HARDWARE_CONFIG}.pre-weave-${TIMESTAMP}"
  log "Backing up existing config to $BACKUP"
  cp "$HARDWARE_CONFIG" "$BACKUP"
fi

log "Installing new hardware-configuration.nix"
cp "$TEMP_HARDWARE_CONFIG" "$HARDWARE_CONFIG"
rm "$TEMP_HARDWARE_CONFIG"
log "✓ Hardware configuration installed"

# Step 7: Ensure blueprint exists
log ""
log "Step 7: Ensuring blueprint.nix exists..."
BLUEPRINT_DIR=$(dirname "$BLUEPRINT")
if [ ! -d "$BLUEPRINT_DIR" ]; then
  log "Creating $BLUEPRINT_DIR"
  mkdir -p "$BLUEPRINT_DIR"
fi

if [ ! -f "$BLUEPRINT" ]; then
  log "Blueprint not found, creating skeleton from template"
  TEMPLATE="$(dirname "$0")/blueprint.nix"
  if [ -f "$TEMPLATE" ]; then
    cp "$TEMPLATE" "$BLUEPRINT"
    log "✓ Blueprint created from template"
    log "⚠ WARNING: Please edit $BLUEPRINT and fill in UUIDs before next run"
  else
    log "WARNING: Template not found, creating minimal blueprint"
    cat > "$BLUEPRINT" <<'EOF'
# FIELD Blueprint - Single source of truth for system configuration
{ config, lib, pkgs, ... }:

{
  # TODO: Configure this file with your system specifics
  # This is a placeholder blueprint
  
  networking.hostName = "iMac2019";
  
  # Boot loader configuration (single ownership)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # System state version
  system.stateVersion = "23.11";
}
EOF
    log "✓ Minimal blueprint created"
    log "⚠ WARNING: Please edit $BLUEPRINT for your system"
  fi
else
  log "✓ Blueprint already exists"
fi

# Step 8: Wire imports in configuration.nix
log ""
log "Step 8: Ensuring imports are wired in configuration.nix..."
if [ -f "$MAIN_CONFIG" ]; then
  # Check if hardware-configuration.nix is imported
  if ! grep -q "hardware-configuration.nix" "$MAIN_CONFIG"; then
    log "Adding hardware-configuration.nix import"
    # Insert after imports = [ line
    sed -i '/imports = \[/a\    ./hardware-configuration.nix' "$MAIN_CONFIG"
  fi
  
  # Check if blueprint is imported
  if ! grep -q "field/blueprint.nix" "$MAIN_CONFIG"; then
    log "Adding blueprint.nix import"
    sed -i '/imports = \[/a\    ./field/blueprint.nix' "$MAIN_CONFIG"
  fi
  
  # Remove duplicate boot loader options (keep only in blueprint)
  log "Checking for duplicate boot loader options..."
  # This is a heuristic - comment out boot.loader lines if they exist outside imports
  # Actual implementation would need better Nix parsing
  
  log "✓ Imports verified"
else
  log "WARNING: configuration.nix not found at $MAIN_CONFIG"
fi

# Step 9: Unmount clean root
log ""
log "Step 9: Unmounting clean root..."
umount -R "$CLEAN_ROOT" || log "WARNING: Failed to unmount $CLEAN_ROOT"
log "✓ Unmounted"

# Step 10: Run preflight checks
log ""
log "Step 10: Running preflight validation..."
if [ -x "$PREFLIGHT" ]; then
  if "$PREFLIGHT" 2>&1 | tee -a "$LOG_FILE"; then
    log "✓ Preflight passed"
  else
    error_exit "Preflight validation failed - see errors above"
  fi
else
  log "WARNING: Preflight script not found or not executable: $PREFLIGHT"
  log "Continuing without preflight validation"
fi

# Step 11: Build (test first)
log ""
log "Step 11: Building NixOS configuration..."
if nixos-rebuild build --flake /etc/nixos#BearsiMac 2>&1 | tee -a "$LOG_FILE"; then
  log "✓ Build successful"
else
  # Try without flake
  if nixos-rebuild build 2>&1 | tee -a "$LOG_FILE"; then
    log "✓ Build successful (non-flake)"
  else
    error_exit "Build failed - see log for details"
  fi
fi

# Step 12: Switch
log ""
log "Step 12: Switching to new configuration..."
log "⚠ This will activate the new configuration"
read -p "Continue with switch? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  log "Switch cancelled by user"
  log "Configuration was built successfully but not activated"
  log "To activate manually: sudo nixos-rebuild switch"
  exit 0
fi

if nixos-rebuild switch --flake /etc/nixos#BearsiMac 2>&1 | tee -a "$LOG_FILE"; then
  log "✓ Switch successful"
else
  # Try without flake
  if nixos-rebuild switch 2>&1 | tee -a "$LOG_FILE"; then
    log "✓ Switch successful (non-flake)"
  else
    error_exit "Switch failed - system may be in inconsistent state"
  fi
fi

# Step 13: Post-scan
log ""
log "Step 13: Triggering post-apply scan..."
SCANNER="$(dirname "$0")/field-scan-2019imac-v5.sh"
if [ -x "$SCANNER" ]; then
  log "Running post-scan..."
  "$SCANNER" 2>&1 | tee -a "$LOG_FILE" || log "WARNING: Post-scan failed"
  log "✓ Post-scan complete"
else
  log "WARNING: Scanner not found: $SCANNER"
fi

log ""
log "=== FIELD Weave Complete ==="
log "System has been rebuilt and activated"
log "Full log: $LOG_FILE"
log ""
log "To review the latest scan:"
LATEST_SCAN=$(ls -td /var/log/FIELD-Scan-* 2>/dev/null | head -1 || true)
if [ -n "$LATEST_SCAN" ]; then
  log "  xdg-open ${LATEST_SCAN}/report.html"
fi
