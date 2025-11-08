#!/usr/bin/env bash
#
# verify-mounts.sh - Verify mount points are correct for installation
#
# This script checks that all required mount points are in place before
# running nixos-install.
#
# Usage: sudo ./scripts/verify-mounts.sh

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🌀 iNixOS Mount Point Verification${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}❌ Please run as root (sudo ./scripts/verify-mounts.sh)${NC}"
  exit 1
fi

echo -e "${GREEN}✓ Running with root privileges${NC}"
echo ""

# Counters
CHECKS_PASSED=0
CHECKS_WARNING=0
CHECKS_FAILED=0

# Check function
check_mount() {
  local mountpoint=$1
  local required=$2  # "required" or "optional"
  local description=$3
  
  if mountpoint -q "$mountpoint" 2>/dev/null; then
    local device=$(findmnt -n -o SOURCE "$mountpoint")
    local fstype=$(findmnt -n -o FSTYPE "$mountpoint")
    local size=$(df -h "$mountpoint" | awk 'NR==2 {print $2}')
    echo -e "${GREEN}✓${NC} $mountpoint - ${description}"
    echo "    Device: $device | Type: $fstype | Size: $size"
    ((CHECKS_PASSED++))
    return 0
  else
    if [ "$required" = "required" ]; then
      echo -e "${RED}✗${NC} $mountpoint - ${description}"
      echo "    Status: NOT MOUNTED (REQUIRED)"
      ((CHECKS_FAILED++))
      return 1
    else
      echo -e "${YELLOW}⚠${NC} $mountpoint - ${description}"
      echo "    Status: NOT MOUNTED (optional)"
      ((CHECKS_WARNING++))
      return 0
    fi
  fi
}

echo -e "${YELLOW}▶ Checking Required Mount Points${NC}"
echo ""

# Check required mounts
check_mount "/mnt" "required" "Root filesystem"
check_mount "/mnt/boot" "required" "Boot/EFI partition"

echo ""
echo -e "${YELLOW}▶ Checking Optional Mount Points${NC}"
echo ""

# Check optional mounts
check_mount "/mnt/nix/store" "optional" "Nix store (recommended for Fusion Drive)"
check_mount "/mnt/home" "optional" "Home directory (recommended for Fusion Drive)"

echo ""
echo -e "${YELLOW}▶ Checking Swap${NC}"
echo ""

if swapon --show | grep -q .; then
  echo -e "${GREEN}✓${NC} Swap is active"
  swapon --show
  ((CHECKS_PASSED++))
else
  echo -e "${YELLOW}⚠${NC} No swap active (optional but recommended)"
  ((CHECKS_WARNING++))
fi

echo ""
echo -e "${YELLOW}▶ Verifying Filesystem Types${NC}"
echo ""

# Check root filesystem
if mountpoint -q /mnt; then
  ROOT_FS=$(findmnt -n -o FSTYPE /mnt)
  if [[ "$ROOT_FS" =~ ^(ext4|btrfs|xfs)$ ]]; then
    echo -e "${GREEN}✓${NC} Root filesystem type: $ROOT_FS (supported)"
    ((CHECKS_PASSED++))
  else
    echo -e "${YELLOW}⚠${NC} Root filesystem type: $ROOT_FS (unusual but may work)"
    ((CHECKS_WARNING++))
  fi
fi

# Check boot filesystem
if mountpoint -q /mnt/boot; then
  BOOT_FS=$(findmnt -n -o FSTYPE /mnt/boot)
  if [[ "$BOOT_FS" == "vfat" ]]; then
    echo -e "${GREEN}✓${NC} Boot filesystem type: $BOOT_FS (correct for EFI)"
    ((CHECKS_PASSED++))
  else
    echo -e "${RED}✗${NC} Boot filesystem type: $BOOT_FS (should be vfat for EFI)"
    echo "    EFI System Partition must be FAT32 (vfat)"
    ((CHECKS_FAILED++))
  fi
fi

echo ""
echo -e "${YELLOW}▶ Checking Disk Space${NC}"
echo ""

# Check root has enough space
if mountpoint -q /mnt; then
  ROOT_AVAIL=$(df -BG /mnt | awk 'NR==2 {print $4}' | sed 's/G//')
  if [ "$ROOT_AVAIL" -ge 10 ]; then
    echo -e "${GREEN}✓${NC} Root partition has ${ROOT_AVAIL}GB available (sufficient)"
    ((CHECKS_PASSED++))
  else
    echo -e "${YELLOW}⚠${NC} Root partition has only ${ROOT_AVAIL}GB available"
    echo "    Recommended: At least 10GB for basic system"
    ((CHECKS_WARNING++))
  fi
fi

# Check boot has enough space
if mountpoint -q /mnt/boot; then
  BOOT_AVAIL=$(df -BM /mnt/boot | awk 'NR==2 {print $4}' | sed 's/M//')
  if [ "$BOOT_AVAIL" -ge 200 ]; then
    echo -e "${GREEN}✓${NC} Boot partition has ${BOOT_AVAIL}MB available (sufficient)"
    ((CHECKS_PASSED++))
  else
    echo -e "${YELLOW}⚠${NC} Boot partition has only ${BOOT_AVAIL}MB available"
    echo "    Recommended: At least 200MB for multiple kernel versions"
    ((CHECKS_WARNING++))
  fi
fi

echo ""
echo -e "${YELLOW}▶ Checking for Hardware Configuration${NC}"
echo ""

# Check if hardware-configuration.nix will be generated correctly
if [ -d "/mnt/etc/nixos" ]; then
  echo -e "${GREEN}✓${NC} /mnt/etc/nixos directory exists"
  ((CHECKS_PASSED++))
  
  if [ -f "/mnt/etc/nixos/hardware-configuration.nix" ]; then
    echo -e "${GREEN}✓${NC} hardware-configuration.nix already exists"
    echo "    Preview:"
    head -20 /mnt/etc/nixos/hardware-configuration.nix | sed 's/^/    /'
    ((CHECKS_PASSED++))
  else
    echo -e "${YELLOW}⚠${NC} hardware-configuration.nix not yet generated"
    echo "    Run: nixos-generate-config --root /mnt"
    ((CHECKS_WARNING++))
  fi
else
  echo -e "${YELLOW}⚠${NC} /mnt/etc/nixos does not exist yet"
  echo "    Will be created by nixos-generate-config"
  ((CHECKS_WARNING++))
fi

echo ""
echo -e "${YELLOW}▶ All Mounts Summary${NC}"
echo ""
mount | grep /mnt | while read line; do
  echo "  $line"
done

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Verification Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${GREEN}Passed:${NC}   $CHECKS_PASSED"
echo -e "  ${YELLOW}Warnings:${NC} $CHECKS_WARNING"
echo -e "  ${RED}Failed:${NC}   $CHECKS_FAILED"
echo ""

if [ $CHECKS_FAILED -eq 0 ]; then
  echo -e "${GREEN}✓ All critical checks passed!${NC}"
  echo ""
  echo "Ready to proceed with installation:"
  echo "  1. Generate config: nixos-generate-config --root /mnt"
  echo "  2. Copy hardware-configuration.nix to your flake repo"
  echo "  3. Install: nixos-install --flake .#BearsiMac --root /mnt"
  echo ""
  exit 0
else
  echo -e "${RED}✗ Some critical checks failed${NC}"
  echo ""
  echo "Please fix the issues above before proceeding with installation."
  echo ""
  echo "Common fixes:"
  echo "  • Mount root: sudo mount /dev/disk/by-label/nixos /mnt"
  echo "  • Mount boot: sudo mount /dev/disk/by-label/BOOT /mnt/boot"
  echo "  • Format boot: sudo mkfs.fat -F 32 -n BOOT /dev/sdX1"
  echo ""
  exit 1
fi
