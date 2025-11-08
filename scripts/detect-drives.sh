#!/usr/bin/env bash
#
# detect-drives.sh - iMac 2019 Drive Detection and Analysis
#
# This script helps identify SSDs and HDDs in your system and provides
# recommendations for partitioning strategy.
#
# Usage: sudo ./scripts/detect-drives.sh

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🌀 iMac 2019 Drive Detection Tool${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}❌ Please run as root (sudo ./scripts/detect-drives.sh)${NC}"
  exit 1
fi

echo -e "${GREEN}✓ Running with root privileges${NC}"
echo ""

# Function to convert bytes to human readable
human_readable() {
  local bytes=$1
  if [ "$bytes" -lt 1024 ]; then
    echo "${bytes}B"
  elif [ "$bytes" -lt 1048576 ]; then
    echo "$(( bytes / 1024 ))KB"
  elif [ "$bytes" -lt 1073741824 ]; then
    echo "$(( bytes / 1048576 ))MB"
  else
    echo "$(( bytes / 1073741824 ))GB"
  fi
}

echo -e "${YELLOW}▶ Detecting Storage Devices${NC}"
echo ""

# Detect all block devices
echo "All Block Devices:"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE,MODEL,ROTA
echo ""

# Identify SSDs vs HDDs
echo -e "${YELLOW}▶ Identifying SSDs and HDDs${NC}"
echo ""

declare -a SSDS
declare -a HDDS

while IFS= read -r line; do
  device=$(echo "$line" | awk '{print $1}')
  size=$(echo "$line" | awk '{print $2}')
  rota=$(echo "$line" | awk '{print $3}')
  model=$(echo "$line" | awk '{$1=$2=$3=""; print $0}' | xargs)
  
  if [ "$rota" = "0" ]; then
    echo -e "${GREEN}✓ SSD Detected: ${device} (${size}) - ${model}${NC}"
    SSDS+=("$device:$size:$model")
  elif [ "$rota" = "1" ]; then
    echo -e "${BLUE}✓ HDD Detected: ${device} (${size}) - ${model}${NC}"
    HDDS+=("$device:$size:$model")
  fi
done < <(lsblk -d -n -o NAME,SIZE,ROTA,MODEL | grep -v "loop\|sr")

echo ""

# Count devices
NUM_SSDS=${#SSDS[@]}
NUM_HDDS=${#HDDS[@]}

echo -e "${YELLOW}▶ Summary${NC}"
echo "  SSDs found: $NUM_SSDS"
echo "  HDDs found: $NUM_HDDS"
echo ""

# Analyze Fusion Drive setup
if [ "$NUM_SSDS" -eq 1 ] && [ "$NUM_HDDS" -eq 1 ]; then
  echo -e "${GREEN}✓ Classic Fusion Drive setup detected!${NC}"
  echo ""
  
  SSD_INFO="${SSDS[0]}"
  HDD_INFO="${HDDS[0]}"
  
  SSD_DEV=$(echo "$SSD_INFO" | cut -d: -f1)
  SSD_SIZE=$(echo "$SSD_INFO" | cut -d: -f2)
  HDD_DEV=$(echo "$HDD_INFO" | cut -d: -f1)
  HDD_SIZE=$(echo "$HDD_INFO" | cut -d: -f2)
  
  echo -e "${YELLOW}▶ Recommended Partitioning Strategy${NC}"
  echo ""
  echo "For optimal NixOS performance on Fusion Drive:"
  echo ""
  echo "═══════════════════════════════════════════════════════════"
  echo -e "${GREEN}SSD (/dev/${SSD_DEV} - ${SSD_SIZE}):${NC}"
  echo "  • /boot/efi    - 512MB  (FAT32, ESP)"
  echo "  • /            - Rest   (btrfs, root filesystem)"
  echo ""
  echo "This keeps your system fast and responsive!"
  echo ""
  echo -e "${BLUE}HDD (/dev/${HDD_DEV} - ${HDD_SIZE}):${NC}"
  echo "  • swap         - 16GB   (swap)"
  echo "  • /nix/store   - 400GB  (btrfs, packages)"
  echo "  • /home        - Rest   (btrfs, user data)"
  echo ""
  echo "This provides plenty of space for packages and data!"
  echo "═══════════════════════════════════════════════════════════"
  echo ""
  
  echo -e "${YELLOW}▶ Sample Partitioning Commands${NC}"
  echo ""
  echo "# WARNING: These commands will ERASE all data!"
  echo "# Make sure you have backups before proceeding!"
  echo ""
  echo -e "${GREEN}# For SSD (/dev/${SSD_DEV}):${NC}"
  echo "sudo parted /dev/${SSD_DEV} -- mklabel gpt"
  echo "sudo parted /dev/${SSD_DEV} -- mkpart ESP fat32 1MiB 512MiB"
  echo "sudo parted /dev/${SSD_DEV} -- set 1 esp on"
  echo "sudo parted /dev/${SSD_DEV} -- mkpart primary 512MiB 100%"
  echo ""
  echo -e "${BLUE}# For HDD (/dev/${HDD_DEV}):${NC}"
  echo "sudo parted /dev/${HDD_DEV} -- mklabel gpt"
  echo "sudo parted /dev/${HDD_DEV} -- mkpart primary 1MiB 16GiB"
  echo "sudo parted /dev/${HDD_DEV} -- mkpart primary 16GiB 416GiB"
  echo "sudo parted /dev/${HDD_DEV} -- mkpart primary 416GiB 100%"
  echo ""
  
  echo -e "${YELLOW}▶ Current Partition Table${NC}"
  echo ""
  echo -e "${GREEN}SSD (/dev/${SSD_DEV}):${NC}"
  if parted /dev/${SSD_DEV} print 2>/dev/null | grep -q "Partition Table"; then
    parted /dev/${SSD_DEV} print 2>/dev/null || echo "  (Unable to read partition table)"
  else
    echo "  No partition table (unformatted)"
  fi
  echo ""
  
  echo -e "${BLUE}HDD (/dev/${HDD_DEV}):${NC}"
  if parted /dev/${HDD_DEV} print 2>/dev/null | grep -q "Partition Table"; then
    parted /dev/${HDD_DEV} print 2>/dev/null || echo "  (Unable to read partition table)"
  else
    echo "  No partition table (unformatted)"
  fi
  echo ""
  
elif [ "$NUM_SSDS" -eq 0 ] && [ "$NUM_HDDS" -ge 1 ]; then
  echo -e "${YELLOW}⚠ No SSD detected - HDD only configuration${NC}"
  echo ""
  echo "Recommended: Use single-drive partitioning on HDD"
  echo "See: docs/IMAC-2019-FUSION-DRIVE-SETUP.md (Option B)"
  
elif [ "$NUM_SSDS" -ge 1 ] && [ "$NUM_HDDS" -eq 0 ]; then
  echo -e "${YELLOW}⚠ No HDD detected - SSD only configuration${NC}"
  echo ""
  echo "If your iMac 2019 should have a Fusion Drive, the HDD may not be detected."
  echo "Check cable connections or consider replacing the drive."
  
else
  echo -e "${YELLOW}⚠ Unusual drive configuration detected${NC}"
  echo ""
  echo "Expected: 1 SSD + 1 HDD (Fusion Drive)"
  echo "Found: $NUM_SSDS SSD(s) + $NUM_HDDS HDD(s)"
  echo ""
  echo "This may be normal if you've modified your system."
  echo "Refer to docs/IMAC-2019-FUSION-DRIVE-SETUP.md for custom setups."
fi

echo ""
echo -e "${YELLOW}▶ Current Mount Points${NC}"
echo ""
if mountpoint -q /mnt 2>/dev/null; then
  echo "Installation target is mounted:"
  mount | grep /mnt | while read line; do
    echo "  $line"
  done
else
  echo "No installation target mounted yet."
  echo "After partitioning, mount your drives to /mnt before installing."
fi

echo ""
echo -e "${YELLOW}▶ Next Steps${NC}"
echo ""
echo "1. Review the recommended partitioning strategy above"
echo "2. Backup any important data (if applicable)"
echo "3. Follow the installation guide: docs/IMAC-2019-FUSION-DRIVE-SETUP.md"
echo "4. Partition your drives (WARNING: destroys data!)"
echo "5. Mount filesystems to /mnt"
echo "6. Run: nixos-install --flake .#BearsiMac"
echo ""

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}For full installation guide, see: docs/IMAC-2019-FUSION-DRIVE-SETUP.md${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
