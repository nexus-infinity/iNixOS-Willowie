#!/usr/bin/env bash
# field-scan-2019imac-v5.sh - Deep inventory scanner for iMac 2019 NixOS
# Generates comprehensive hardware and system reports with friction detection
set -euo pipefail

# Configuration
SCAN_BASE="/var/log"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
SCAN_DIR="${SCAN_BASE}/FIELD-Scan-${TIMESTAMP}"
RAW_DIR="${SCAN_DIR}/raw"
INCLUDE_HASH=false
INCLUDE_EPHEMERAL=false

# Parse arguments
for arg in "$@"; do
  case "$arg" in
    --hash) INCLUDE_HASH=true ;;
    --include-ephemeral) INCLUDE_EPHEMERAL=true ;;
    -h|--help)
      echo "Usage: $0 [--hash] [--include-ephemeral]"
      echo "  --hash              Include file hashes (slower)"
      echo "  --include-ephemeral Include tmpfs/overlay mounts"
      exit 0
      ;;
    *) echo "Unknown option: $arg"; exit 1 ;;
  esac
done

# Create scan directories
mkdir -p "$RAW_DIR"

echo "=== FIELD Scanner v5 ==="
echo "Scan directory: $SCAN_DIR"
echo "Timestamp: $TIMESTAMP"

# Helper function to run commands and save output
run_and_save() {
  local name="$1"
  local cmd="$2"
  echo "  Collecting: $name"
  eval "$cmd" > "${RAW_DIR}/${name}.txt" 2>&1 || echo "  Warning: $name collection failed" >&2
}

# System Information
echo "Collecting system information..."
run_and_save "hostname" "hostname"
run_and_save "uname" "uname -a"
run_and_save "nixos-version" "nixos-version --json || nixos-version"
run_and_save "nix-info" "nix-shell -p nix-info --run nix-info || echo 'nix-info not available'"

# CPU Information
echo "Collecting CPU information..."
run_and_save "cpuinfo" "cat /proc/cpuinfo"
run_and_save "lscpu" "lscpu"

# Memory Information
echo "Collecting memory information..."
run_and_save "meminfo" "cat /proc/meminfo"
run_and_save "free" "free -h"

# GPU/Graphics Information
echo "Collecting GPU information..."
run_and_save "lspci-vga" "lspci -v | grep -A 20 VGA || lspci | grep VGA"
run_and_save "lspci-full" "lspci -vvv"
run_and_save "drm-devices" "ls -l /dev/dri/ 2>/dev/null || echo 'No DRM devices'"

# Storage Information
echo "Collecting storage information..."
run_and_save "lsblk" "lsblk -a -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,UUID,LABEL"
run_and_save "lsblk-json" "lsblk -J -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,UUID,LABEL"
run_and_save "blkid" "blkid"
run_and_save "df" "df -h"
run_and_save "mount" "mount"
run_and_save "btrfs-subvol-list" "btrfs subvolume list / 2>/dev/null || echo 'Not a Btrfs filesystem or not mounted'"
run_and_save "btrfs-fi-show" "btrfs filesystem show 2>/dev/null || echo 'No Btrfs filesystems'"

# USB Devices
echo "Collecting USB device information..."
run_and_save "lsusb" "lsusb -v"
run_and_save "usb-devices" "cat /sys/kernel/debug/usb/devices 2>/dev/null || lsusb -t"

# PCI Devices
echo "Collecting PCI device information..."
run_and_save "lspci-tree" "lspci -tv"

# Network Interfaces
echo "Collecting network information..."
run_and_save "ip-addr" "ip addr"
run_and_save "ip-link" "ip link"
run_and_save "ip-route" "ip route"
run_and_save "nmcli-device" "nmcli device 2>/dev/null || echo 'NetworkManager not available'"
run_and_save "nmcli-connection" "nmcli connection 2>/dev/null || echo 'NetworkManager not available'"

# Wireless
echo "Collecting wireless information..."
run_and_save "iw-dev" "iw dev 2>/dev/null || echo 'iw not available or no wireless devices'"
run_and_save "rfkill" "rfkill list 2>/dev/null || echo 'rfkill not available'"

# Bluetooth
echo "Collecting Bluetooth information..."
run_and_save "bluetoothctl" "bluetoothctl list 2>/dev/null || echo 'bluetoothctl not available'"
run_and_save "hciconfig" "hciconfig -a 2>/dev/null || echo 'hciconfig not available'"

# Thunderbolt
echo "Collecting Thunderbolt information..."
run_and_save "boltctl" "boltctl list 2>/dev/null || echo 'boltctl not available'"

# Audio
echo "Collecting audio information..."
run_and_save "aplay-list" "aplay -l 2>/dev/null || echo 'aplay not available'"
run_and_save "pactl-sinks" "pactl list sinks 2>/dev/null || echo 'PulseAudio not running'"
run_and_save "pactl-sources" "pactl list sources 2>/dev/null || echo 'PulseAudio not running'"

# Camera/Video
echo "Collecting camera/video information..."
run_and_save "v4l2-devices" "ls -l /dev/video* 2>/dev/null || echo 'No video devices'"

# EFI/Boot Information
echo "Collecting EFI/boot information..."
run_and_save "efibootmgr" "efibootmgr -v 2>/dev/null || echo 'efibootmgr not available or not UEFI'"
run_and_save "bootctl-status" "bootctl status 2>/dev/null || echo 'bootctl not available'"
run_and_save "ls-boot-efi" "ls -lR /boot/efi 2>/dev/null || ls -lR /boot 2>/dev/null || echo 'No boot partition mounted'"

# Users and Groups
echo "Collecting user information..."
run_and_save "users" "cat /etc/passwd"
run_and_save "groups" "cat /etc/group"
run_and_save "current-user" "whoami; id"

# NixOS Configuration
echo "Collecting NixOS configuration..."
run_and_save "nixos-hardware-config" "cat /etc/nixos/hardware-configuration.nix 2>/dev/null || echo 'No hardware-configuration.nix'"
run_and_save "nixos-configuration" "cat /etc/nixos/configuration.nix 2>/dev/null || echo 'No configuration.nix'"
run_and_save "nixos-flake" "cat /etc/nixos/flake.nix 2>/dev/null || echo 'No flake.nix'"
run_and_save "nix-channels" "nix-channel --list 2>/dev/null || echo 'No channels or command not available'"

# Services
echo "Collecting service information..."
run_and_save "systemctl-status" "systemctl status"
run_and_save "systemctl-failed" "systemctl --failed"

# Kernel and Modules
echo "Collecting kernel information..."
run_and_save "lsmod" "lsmod"
run_and_save "dmesg" "dmesg 2>/dev/null || echo 'dmesg not available or permission denied'"

# Filesystem analysis
echo "Analyzing filesystems..."
run_and_save "findmnt" "findmnt"
run_and_save "findmnt-json" "findmnt -J"

# File hashing (optional, slow)
if [ "$INCLUDE_HASH" = true ]; then
  echo "Computing file hashes (this may take a while)..."
  run_and_save "nixos-config-hashes" "find /etc/nixos -type f -exec sha256sum {} \; 2>/dev/null || echo 'Hash computation failed'"
fi

echo ""
echo "=== Generating Reports ==="

# Generate JSON report
echo "Generating JSON report..."
cat > "${SCAN_DIR}/report.json" <<EOF
{
  "timestamp": "${TIMESTAMP}",
  "hostname": "$(hostname)",
  "scan_dir": "${SCAN_DIR}",
  "include_hash": ${INCLUDE_HASH},
  "include_ephemeral": ${INCLUDE_EPHEMERAL},
  "system": {
    "uname": "$(uname -s -r -m)",
    "nixos_version": "$(nixos-version 2>/dev/null || echo 'unknown')"
  },
  "raw_dir": "${RAW_DIR}"
}
EOF

# Generate Markdown report
echo "Generating Markdown report..."
cat > "${SCAN_DIR}/report.md" <<'MDEOF'
# FIELD System Scan Report

**Scan Timestamp:** TIMESTAMP_PLACEHOLDER  
**Hostname:** HOSTNAME_PLACEHOLDER  
**NixOS Version:** NIXOS_VERSION_PLACEHOLDER

---

## Executive Summary

This report provides a comprehensive inventory of the system hardware, configuration, and detected friction points.

### System Overview

- **CPU:** CPU_INFO_PLACEHOLDER
- **Memory:** MEMORY_INFO_PLACEHOLDER
- **Storage:** STORAGE_INFO_PLACEHOLDER

### Friction Detection

FRICTION_PLACEHOLDER

---

## Hardware Inventory

### CPU

```
CPU_DETAILS_PLACEHOLDER
```

### Memory

```
MEMORY_DETAILS_PLACEHOLDER
```

### GPU/Graphics

```
GPU_DETAILS_PLACEHOLDER
```

### Storage Devices

```
STORAGE_DETAILS_PLACEHOLDER
```

### Block Devices

```
LSBLK_PLACEHOLDER
```

---

## Peripherals

### USB Devices

```
USB_PLACEHOLDER
```

### Network Interfaces

```
NETWORK_PLACEHOLDER
```

### Bluetooth

```
BLUETOOTH_PLACEHOLDER
```

### Audio Devices

```
AUDIO_PLACEHOLDER
```

---

## Boot Configuration

### EFI Boot Manager

```
EFI_PLACEHOLDER
```

### Boot Loader Status

```
BOOTCTL_PLACEHOLDER
```

---

## Filesystem Mounts

```
MOUNTS_PLACEHOLDER
```

---

## NixOS Configuration

### hardware-configuration.nix

```nix
HARDWARE_CONFIG_PLACEHOLDER
```

### configuration.nix (excerpt)

```nix
CONFIG_EXCERPT_PLACEHOLDER
```

---

## Analysis and Friction Detection

### Duplicate Filesystem Checks

DUPLICATE_FS_PLACEHOLDER

### Transient Device Checks

TRANSIENT_DEV_PLACEHOLDER

### Boot Loader Duplicates

BOOT_DUP_PLACEHOLDER

---

## Raw Data

All raw command outputs are available in:  
`RAW_DIR_PLACEHOLDER`

---

**Scan completed:** TIMESTAMP_PLACEHOLDER  
**Generated by:** field-scan-2019imac-v5.sh
MDEOF

# Fill in placeholders
sed -i "s|TIMESTAMP_PLACEHOLDER|${TIMESTAMP}|g" "${SCAN_DIR}/report.md"
sed -i "s|HOSTNAME_PLACEHOLDER|$(hostname)|g" "${SCAN_DIR}/report.md"
sed -i "s|NIXOS_VERSION_PLACEHOLDER|$(nixos-version 2>/dev/null || echo 'unknown')|g" "${SCAN_DIR}/report.md"
sed -i "s|RAW_DIR_PLACEHOLDER|${RAW_DIR}|g" "${SCAN_DIR}/report.md"

# CPU info
CPU_MODEL=$(grep -m 1 "model name" "${RAW_DIR}/cpuinfo.txt" 2>/dev/null | cut -d: -f2 | xargs || echo "Unknown")
CPU_CORES=$(grep -c "^processor" "${RAW_DIR}/cpuinfo.txt" 2>/dev/null || echo "Unknown")
sed -i "s|CPU_INFO_PLACEHOLDER|${CPU_MODEL} (${CPU_CORES} cores)|g" "${SCAN_DIR}/report.md"
sed -i "/CPU_DETAILS_PLACEHOLDER/r ${RAW_DIR}/lscpu.txt" "${SCAN_DIR}/report.md"
sed -i "s|CPU_DETAILS_PLACEHOLDER||g" "${SCAN_DIR}/report.md"

# Memory info
MEMORY_TOTAL=$(grep "MemTotal" "${RAW_DIR}/meminfo.txt" 2>/dev/null | awk '{print $2, $3}' || echo "Unknown")
sed -i "s|MEMORY_INFO_PLACEHOLDER|${MEMORY_TOTAL}|g" "${SCAN_DIR}/report.md"
sed -i "/MEMORY_DETAILS_PLACEHOLDER/r ${RAW_DIR}/free.txt" "${SCAN_DIR}/report.md"
sed -i "s|MEMORY_DETAILS_PLACEHOLDER||g" "${SCAN_DIR}/report.md"

# Storage info
STORAGE_SUMMARY=$(lsblk -ndo NAME,SIZE,TYPE 2>/dev/null | grep disk | head -3 || echo "Unknown")
sed -i "s|STORAGE_INFO_PLACEHOLDER|${STORAGE_SUMMARY}|g" "${SCAN_DIR}/report.md"
sed -i "/STORAGE_DETAILS_PLACEHOLDER/r ${RAW_DIR}/lsblk.txt" "${SCAN_DIR}/report.md"
sed -i "s|STORAGE_DETAILS_PLACEHOLDER||g" "${SCAN_DIR}/report.md"

# GPU info
sed -i "/GPU_DETAILS_PLACEHOLDER/r ${RAW_DIR}/lspci-vga.txt" "${SCAN_DIR}/report.md"
sed -i "s|GPU_DETAILS_PLACEHOLDER||g" "${SCAN_DIR}/report.md"

# LSBLK
sed -i "/LSBLK_PLACEHOLDER/r ${RAW_DIR}/lsblk.txt" "${SCAN_DIR}/report.md"
sed -i "s|LSBLK_PLACEHOLDER||g" "${SCAN_DIR}/report.md"

# USB
sed -i "/USB_PLACEHOLDER/r ${RAW_DIR}/lsusb.txt" "${SCAN_DIR}/report.md"
sed -i "s|USB_PLACEHOLDER||g" "${SCAN_DIR}/report.md"

# Network
sed -i "/NETWORK_PLACEHOLDER/r ${RAW_DIR}/ip-addr.txt" "${SCAN_DIR}/report.md"
sed -i "s|NETWORK_PLACEHOLDER||g" "${SCAN_DIR}/report.md"

# Bluetooth
sed -i "/BLUETOOTH_PLACEHOLDER/r ${RAW_DIR}/bluetoothctl.txt" "${SCAN_DIR}/report.md"
sed -i "s|BLUETOOTH_PLACEHOLDER||g" "${SCAN_DIR}/report.md"

# Audio
sed -i "/AUDIO_PLACEHOLDER/r ${RAW_DIR}/aplay-list.txt" "${SCAN_DIR}/report.md"
sed -i "s|AUDIO_PLACEHOLDER||g" "${SCAN_DIR}/report.md"

# EFI
sed -i "/EFI_PLACEHOLDER/r ${RAW_DIR}/efibootmgr.txt" "${SCAN_DIR}/report.md"
sed -i "s|EFI_PLACEHOLDER||g" "${SCAN_DIR}/report.md"

# Bootctl
sed -i "/BOOTCTL_PLACEHOLDER/r ${RAW_DIR}/bootctl-status.txt" "${SCAN_DIR}/report.md"
sed -i "s|BOOTCTL_PLACEHOLDER||g" "${SCAN_DIR}/report.md"

# Mounts
sed -i "/MOUNTS_PLACEHOLDER/r ${RAW_DIR}/mount.txt" "${SCAN_DIR}/report.md"
sed -i "s|MOUNTS_PLACEHOLDER||g" "${SCAN_DIR}/report.md"

# Hardware config
if [ -f "${RAW_DIR}/nixos-hardware-config.txt" ]; then
  sed -i "/HARDWARE_CONFIG_PLACEHOLDER/r ${RAW_DIR}/nixos-hardware-config.txt" "${SCAN_DIR}/report.md"
fi
sed -i "s|HARDWARE_CONFIG_PLACEHOLDER||g" "${SCAN_DIR}/report.md"

# Config excerpt (first 50 lines)
if [ -f "${RAW_DIR}/nixos-configuration.txt" ]; then
  head -50 "${RAW_DIR}/nixos-configuration.txt" > "${RAW_DIR}/nixos-configuration-excerpt.txt"
  sed -i "/CONFIG_EXCERPT_PLACEHOLDER/r ${RAW_DIR}/nixos-configuration-excerpt.txt" "${SCAN_DIR}/report.md"
fi
sed -i "s|CONFIG_EXCERPT_PLACEHOLDER||g" "${SCAN_DIR}/report.md"

# Friction detection
FRICTION_REPORT=""

# Check for duplicate fileSystems
if [ -f "${RAW_DIR}/nixos-hardware-config.txt" ]; then
  DUPLICATE_FS=$(grep -E "^\s*fileSystems\." "${RAW_DIR}/nixos-hardware-config.txt" | sort | uniq -d || true)
  if [ -n "$DUPLICATE_FS" ]; then
    FRICTION_REPORT="${FRICTION_REPORT}**⚠ Duplicate filesystem declarations detected**\n"
    sed -i "s|DUPLICATE_FS_PLACEHOLDER|⚠ **WARNING:** Duplicate filesystem declarations found:\n\`\`\`\n${DUPLICATE_FS}\n\`\`\`|g" "${SCAN_DIR}/report.md"
  else
    sed -i "s|DUPLICATE_FS_PLACEHOLDER|✓ No duplicate filesystem declarations|g" "${SCAN_DIR}/report.md"
  fi
else
  sed -i "s|DUPLICATE_FS_PLACEHOLDER|N/A - hardware-configuration.nix not found|g" "${SCAN_DIR}/report.md"
fi

# Check for transient devices
if [ -f "${RAW_DIR}/nixos-hardware-config.txt" ]; then
  TRANSIENT_DEV=$(grep -E "(overlay|/etc/nix|/nix/store)" "${RAW_DIR}/nixos-hardware-config.txt" || true)
  if [ -n "$TRANSIENT_DEV" ]; then
    FRICTION_REPORT="${FRICTION_REPORT}**⚠ Transient devices in configuration**\n"
    sed -i "s|TRANSIENT_DEV_PLACEHOLDER|⚠ **WARNING:** Transient devices found:\n\`\`\`\n${TRANSIENT_DEV}\n\`\`\`|g" "${SCAN_DIR}/report.md"
  else
    sed -i "s|TRANSIENT_DEV_PLACEHOLDER|✓ No transient devices detected|g" "${SCAN_DIR}/report.md"
  fi
else
  sed -i "s|TRANSIENT_DEV_PLACEHOLDER|N/A - hardware-configuration.nix not found|g" "${SCAN_DIR}/report.md"
fi

# Check for boot loader duplicates
if [ -f "${RAW_DIR}/nixos-configuration.txt" ]; then
  BOOT_DUP=$(grep -E "boot\.loader\.(systemd-boot|grub)\.enable" "${RAW_DIR}/nixos-configuration.txt" | sort | uniq -d || true)
  if [ -n "$BOOT_DUP" ]; then
    FRICTION_REPORT="${FRICTION_REPORT}**⚠ Duplicate boot loader options**\n"
    sed -i "s|BOOT_DUP_PLACEHOLDER|⚠ **WARNING:** Duplicate boot loader options:\n\`\`\`\n${BOOT_DUP}\n\`\`\`|g" "${SCAN_DIR}/report.md"
  else
    sed -i "s|BOOT_DUP_PLACEHOLDER|✓ No duplicate boot loader options|g" "${SCAN_DIR}/report.md"
  fi
else
  sed -i "s|BOOT_DUP_PLACEHOLDER|N/A - configuration.nix not found|g" "${SCAN_DIR}/report.md"
fi

if [ -z "$FRICTION_REPORT" ]; then
  FRICTION_REPORT="✓ **No friction detected** - Configuration appears clean"
fi

sed -i "s|FRICTION_PLACEHOLDER|${FRICTION_REPORT}|g" "${SCAN_DIR}/report.md"

# Generate HTML report
echo "Generating HTML report..."
if command -v markdown &>/dev/null; then
  markdown "${SCAN_DIR}/report.md" > "${SCAN_DIR}/report.html"
elif command -v pandoc &>/dev/null; then
  pandoc -f markdown -t html -s "${SCAN_DIR}/report.md" -o "${SCAN_DIR}/report.html"
else
  # Simple HTML wrapper
  cat > "${SCAN_DIR}/report.html" <<'HTMLEOF'
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>FIELD Scan Report</title>
  <style>
    body { font-family: sans-serif; max-width: 900px; margin: 40px auto; padding: 0 20px; }
    pre { background: #f5f5f5; padding: 15px; overflow-x: auto; border-radius: 5px; }
    code { background: #f5f5f5; padding: 2px 5px; border-radius: 3px; }
    h1, h2, h3 { color: #333; }
    hr { border: none; border-top: 2px solid #ddd; margin: 30px 0; }
  </style>
</head>
<body>
<pre>
HTMLEOF
  cat "${SCAN_DIR}/report.md" >> "${SCAN_DIR}/report.html"
  cat >> "${SCAN_DIR}/report.html" <<'HTMLEOF'
</pre>
</body>
</html>
HTMLEOF
fi

echo ""
echo "=== Scan Complete ==="
echo "Reports generated:"
echo "  Markdown: ${SCAN_DIR}/report.md"
echo "  HTML:     ${SCAN_DIR}/report.html"
echo "  JSON:     ${SCAN_DIR}/report.json"
echo "  Raw data: ${RAW_DIR}/"
echo ""
echo "To view the HTML report:"
echo "  xdg-open ${SCAN_DIR}/report.html"
echo ""
echo "To regenerate reports from this scan:"
echo "  ./tools/field/field-scan-report-v3.sh ${SCAN_DIR}"
