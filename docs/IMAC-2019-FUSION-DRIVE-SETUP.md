# iMac 2019 Fusion Drive - NixOS Installation Guide

## Understanding Your iMac 2019 Fusion Drive Architecture

Your iMac 2019 has a **Fusion Drive** consisting of:
- **Small SSD**: ~20-30GB (fast, for OS and frequently accessed files)
- **Large HDD**: ~1TB (slower, for bulk storage)

Apple's Fusion Drive typically presents these as a single logical volume, but for NixOS installation, we'll use them strategically.

## Current Problem Analysis

You mentioned:
- Currently logging in via USB (booting from USB installer)
- Confusion about how to mount the real drives
- Need to boot natively from internal drives
- Want smooth startup and shutdown after installation

## Recommended Partitioning Strategy

### Option A: SSD for System, HDD for /home and /nix/store (RECOMMENDED)

This is the optimal approach for NixOS on Fusion Drive hardware:

**SSD (20-30GB):**
- `/boot/efi` - 512MB (EFI System Partition)
- `/` (root) - Remaining space (~19-29GB)

**HDD (~1TB):**
- `/nix/store` - 300-400GB (NixOS packages and generations)
- `/home` - Remaining space (user data)
- swap - 16-32GB (optional, depends on RAM)

**Benefits:**
- Fast boot and system responsiveness (OS on SSD)
- Plenty of space for Nix store (which grows with each generation)
- User data safely on large HDD
- System and data separation for easier backup/recovery

### Option B: Everything on HDD (Simpler but Slower)

If SSD is too small or problematic:

**HDD only:**
- `/boot/efi` - 512MB
- swap - 16-32GB
- `/` (root) - Remaining space

**Benefits:**
- Simpler partitioning
- More space for everything
- No confusion about drive allocation

**Drawbacks:**
- Slower boot times
- Less responsive system overall

## Step-by-Step Installation Process

### Phase 1: Boot from USB and Assess Current State

1. **Boot from NixOS USB installer**
   - Hold `Option/Alt` key during startup
   - Select USB drive from boot menu

2. **Once booted to NixOS installer, identify your drives:**
   ```bash
   # List all block devices
   lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE,MODEL
   
   # More detailed info
   sudo fdisk -l
   
   # Find SSDs vs HDDs
   lsblk -d -o NAME,SIZE,ROTA,MODEL
   # ROTA=0 means SSD, ROTA=1 means HDD
   ```

3. **Document your drive layout:**
   ```bash
   # Save this information
   lsblk > /tmp/drive-layout.txt
   cat /tmp/drive-layout.txt
   ```

Expected output will look something like:
```
NAME        SIZE  ROTA  MODEL
nvme0n1     28G   0     APPLE SSD AP0032J
sda         1TB   1     ST1000DM003
```

### Phase 2: Partition the Drives

**⚠️ WARNING: This will ERASE all data. Backup first!**

#### For Option A (Recommended - SSD + HDD split):

```bash
# Identify your drives (replace nvme0n1 and sda with your actual device names)
SSD_DEVICE="/dev/nvme0n1"  # or /dev/sda if your SSD is SATA
HDD_DEVICE="/dev/sda"      # adjust based on lsblk output

# Partition the SSD
sudo parted $SSD_DEVICE -- mklabel gpt
sudo parted $SSD_DEVICE -- mkpart ESP fat32 1MiB 512MiB
sudo parted $SSD_DEVICE -- set 1 esp on
sudo parted $SSD_DEVICE -- mkpart primary 512MiB 100%

# Partition the HDD
sudo parted $HDD_DEVICE -- mklabel gpt
sudo parted $HDD_DEVICE -- mkpart primary 1MiB 16GiB      # swap (adjust size)
sudo parted $HDD_DEVICE -- mkpart primary 16GiB 416GiB    # nix store (400GB)
sudo parted $HDD_DEVICE -- mkpart primary 416GiB 100%     # home

# Format the filesystems
# SSD partitions
sudo mkfs.fat -F 32 -n BOOT ${SSD_DEVICE}p1  # or ${SSD_DEVICE}1 for SATA
sudo mkfs.btrfs -L nixos ${SSD_DEVICE}p2

# HDD partitions  
sudo mkswap -L swap ${HDD_DEVICE}1
sudo mkfs.btrfs -L nixstore ${HDD_DEVICE}2
sudo mkfs.btrfs -L home ${HDD_DEVICE}3
```

#### For Option B (HDD only):

```bash
HDD_DEVICE="/dev/sda"  # adjust based on lsblk output

# Partition the HDD
sudo parted $HDD_DEVICE -- mklabel gpt
sudo parted $HDD_DEVICE -- mkpart ESP fat32 1MiB 512MiB
sudo parted $HDD_DEVICE -- set 1 esp on
sudo parted $HDD_DEVICE -- mkpart primary 512MiB 16GiB     # swap
sudo parted $HDD_DEVICE -- mkpart primary 16GiB 100%       # root

# Format filesystems
sudo mkfs.fat -F 32 -n BOOT ${HDD_DEVICE}1
sudo mkswap -L swap ${HDD_DEVICE}2
sudo mkfs.btrfs -L nixos ${HDD_DEVICE}3
```

### Phase 3: Mount the Filesystems

#### For Option A:

```bash
# Mount root on SSD
sudo mount /dev/disk/by-label/nixos /mnt

# Create mount points
sudo mkdir -p /mnt/boot
sudo mkdir -p /mnt/nix/store
sudo mkdir -p /mnt/home

# Mount everything
sudo mount /dev/disk/by-label/BOOT /mnt/boot
sudo mount /dev/disk/by-label/nixstore /mnt/nix/store
sudo mount /dev/disk/by-label/home /mnt/home

# Enable swap
sudo swapon /dev/disk/by-label/swap

# Verify mounts
df -h
mount | grep /mnt
```

#### For Option B:

```bash
# Mount root on HDD
sudo mount /dev/disk/by-label/nixos /mnt

# Create boot mount point
sudo mkdir -p /mnt/boot

# Mount boot
sudo mount /dev/disk/by-label/BOOT /mnt/boot

# Enable swap
sudo swapon /dev/disk/by-label/swap

# Verify mounts
df -h
mount | grep /mnt
```

### Phase 4: Install NixOS Base System

1. **Generate initial hardware configuration:**
   ```bash
   sudo nixos-generate-config --root /mnt
   ```

2. **Review the generated hardware config:**
   ```bash
   cat /mnt/etc/nixos/hardware-configuration.nix
   ```

   Verify it includes:
   - All your mount points (`/`, `/boot`, `/nix/store`, `/home` if using Option A)
   - Correct UUIDs (not labels, though labels work too)
   - Proper filesystem types (btrfs, vfat)
   - Boot loader configuration

3. **Clone the iNixOS-Willowie repository to the new system:**
   ```bash
   # Install git if not available
   nix-shell -p git
   
   # Clone to /mnt/etc/nixos (or another location)
   cd /mnt/etc/nixos
   sudo git clone https://github.com/nexus-infinity/iNixOS-Willowie.git
   cd iNixOS-Willowie
   
   # Or if you prefer /mnt/home/jbear location:
   sudo mkdir -p /mnt/home/jbear
   cd /mnt/home/jbear
   sudo git clone https://github.com/nexus-infinity/iNixOS-Willowie.git
   ```

4. **Copy generated hardware config to repository:**
   ```bash
   cd /mnt/home/jbear/iNixOS-Willowie  # or wherever you cloned it
   sudo cp /mnt/etc/nixos/hardware-configuration.nix .
   ```

5. **Review and adjust the hardware configuration if needed:**
   ```bash
   # Edit if you need to add specific kernel modules or options
   sudo nano hardware-configuration.nix
   ```

   **Important additions for iMac 2019:**
   - Ensure `boot.loader.systemd-boot.enable = true;` is set (or in configuration.nix)
   - Ensure `boot.loader.efi.canTouchEfiVariables = true;` is set
   - For WiFi: May need `boot.kernelModules = [ "brcmfmac" ];` if using Broadcom WiFi

### Phase 5: Customize Configuration for iMac 2019

Edit the BearsiMac configuration:

```bash
cd /mnt/home/jbear/iNixOS-Willowie
sudo nano nixosConfigurations/BearsiMac/configuration.nix
```

**Essential additions for iMac 2019:**

```nix
{ config, lib, pkgs, ... }:
{
  # Basic system configuration
  networking = {
    hostName = "BearsiMac";
    networkmanager.enable = true;
    # Remove wireless.enable if using NetworkManager
    # wireless.enable is incompatible with NetworkManager
  };

  # Boot loader configuration
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 5;  # Seconds to show boot menu
  };

  # For iMac's Broadcom WiFi (if needed)
  hardware.enableRedistributableFirmware = true;
  
  # For better graphics support
  hardware.opengl = {
    enable = true;
    driSupport = true;
  };

  # For iMac's Radeon graphics (common in 2019 models)
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Enable GNOME desktop (or your preferred DE)
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  # User configuration
  users.users.jbear = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
    # Set initial password (change after first login)
    initialPassword = "changeme";
  };

  # Essential packages
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    zsh
    htop
    firefox
  ];

  # Enable important services
  services = {
    openssh.enable = true;
  };

  # System state version
  system.stateVersion = "23.11";
}
```

**Remove the wireless.enable section** if you're using NetworkManager, as they conflict.

### Phase 6: Install NixOS

1. **Test the configuration first:**
   ```bash
   cd /mnt/home/jbear/iNixOS-Willowie
   
   # This validates but doesn't install
   sudo nixos-install --flake .#BearsiMac --no-root-passwd --dry-run
   ```

2. **If validation succeeds, install:**
   ```bash
   sudo nixos-install --flake .#BearsiMac --root /mnt
   ```

   This will:
   - Build the entire system
   - Download all required packages
   - Install bootloader
   - Set up systemd services

3. **Set root password when prompted** (or skip with `--no-root-passwd`)

4. **Set user password:**
   ```bash
   sudo nixos-enter --root /mnt
   passwd jbear
   exit
   ```

### Phase 7: First Boot

1. **Unmount and reboot:**
   ```bash
   sudo umount -R /mnt
   sudo reboot
   ```

2. **Remove USB drive** and let system boot from internal drive

3. **Select NixOS from boot menu** if multiple options appear

4. **Log in as jbear** (or root if you set root password)

### Phase 8: Post-Installation Verification

Once logged into your new NixOS system:

```bash
# Verify you're on the internal drive, not USB
df -h
mount | grep -E '(nvme|sda)'

# Check all mounts are correct
lsblk -f

# Verify NixOS version
nixos-version

# Test internet connectivity
ping -c 3 google.com

# Navigate to your config (adjust path if different)
cd /home/jbear/iNixOS-Willowie  # or /etc/nixos/iNixOS-Willowie

# Verify flake works
nix flake show

# Test rebuild (this should be fast since you just built)
sudo nixos-rebuild test --flake .#BearsiMac

# If test succeeds, switch to make it permanent
sudo nixos-rebuild switch --flake .#BearsiMac
```

## Troubleshooting Common Issues

### Issue 1: System boots to USB instead of internal drive

**Solution:**
```bash
# Reboot and hold Option/Alt key
# Select "EFI Boot" or your SSD/HDD from menu
# Or from running system:
sudo efibootmgr  # List boot entries
sudo efibootmgr -o 0001,0002,0003  # Reorder boot entries (adjust numbers)
```

### Issue 2: WiFi not working

**Solution:**
```bash
# Check if firmware is loaded
dmesg | grep -i firmware

# If Broadcom WiFi needs firmware:
# Edit configuration.nix:
hardware.enableRedistributableFirmware = true;

# Rebuild
sudo nixos-rebuild switch --flake .#BearsiMac
```

### Issue 3: Graphics not working properly

**Solution:**
```bash
# For AMD Radeon (common in iMac 2019):
# Add to configuration.nix:
services.xserver.videoDrivers = [ "amdgpu" ];
hardware.opengl.enable = true;

# Rebuild
sudo nixos-rebuild switch --flake .#BearsiMac
```

### Issue 4: Can't mount /nix/store or /home

**Solution:**
```bash
# Check UUIDs are correct
sudo blkid

# Compare with /etc/nixos/hardware-configuration.nix
cat /etc/nixos/hardware-configuration.nix

# If UUIDs don't match, regenerate:
sudo nixos-generate-config
# Then copy hardware-configuration.nix to your iNixOS-Willowie repo
```

### Issue 5: System fills up SSD quickly

**Solution:**
This means `/nix/store` is on SSD instead of HDD. Fix:

```bash
# Check where /nix/store is mounted
df -h /nix/store

# If it's on the root partition instead of separate:
# You need to remount. From a live USB:
# 1. Mount root
# 2. Create /mnt/nix/store directory
# 3. Add mount in hardware-configuration.nix
# 4. Reinstall or rsync /nix/store contents
```

### Issue 6: "wireless and networkmanager conflict"

**Solution:**
```bash
# Edit configuration.nix and remove wireless.enable section:
# Comment out or delete:
#   networking.wireless.enable = true;

# Keep only:
networking.networkmanager.enable = true;

# Rebuild
sudo nixos-rebuild switch --flake .#BearsiMac
```

## Monitoring Drive Usage

Keep an eye on your drives, especially the small SSD:

```bash
# Overall usage
df -h

# Which directories are largest
sudo du -h --max-depth=1 / | sort -h

# Check /nix/store size
du -sh /nix/store

# Clean old generations (frees space)
sudo nix-collect-garbage -d

# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Delete specific old generations
sudo nix-env --delete-generations 1 2 3 --profile /nix/var/nix/profiles/system
sudo nixos-rebuild switch  # Removes them from bootloader too
```

## Updating Your System

```bash
cd /home/jbear/iNixOS-Willowie

# Update flake inputs (updates nixpkgs)
nix flake update

# Test the update
sudo nixos-rebuild test --flake .#BearsiMac

# If good, switch to it
sudo nixos-rebuild switch --flake .#BearsiMac

# Commit the flake.lock changes
git add flake.lock
git commit -m "Update nixpkgs"
git push
```

## Backup Strategy

Since your system and data are split across drives:

1. **System (SSD):** Can be recreated from your GitHub repo
2. **/nix/store (HDD):** Can be rebuilt (will take time)
3. **/home (HDD):** **MUST BE BACKED UP** - contains your actual data

```bash
# Backup /home to external drive
sudo rsync -avh --progress /home/ /mnt/external-drive/home-backup/

# Or use a proper backup tool
# Install restic or borg via environment.systemPackages
```

## Performance Tips

1. **Enable TRIM for SSD:**
   ```nix
   # In configuration.nix:
   services.fstrim.enable = true;
   ```

2. **Use compression on HDD (saves space):**
   ```nix
   # In hardware-configuration.nix, add to btrfs mounts:
   options = [ "compress=zstd" "noatime" ];
   ```

3. **Optimize Nix store:**
   ```bash
   # Enable in configuration.nix:
   nix.settings.auto-optimise-store = true;
   
   # Or run manually:
   nix-store --optimise
   ```

## Summary: Quick Reference

**Your final drive layout (Option A - Recommended):**
```
SSD (nvme0n1 or sda): 20-30GB
├── /boot/efi (512MB, FAT32)
└── / (root, ~19-29GB, btrfs)

HDD (sda or sdb): ~1TB
├── swap (16GB)
├── /nix/store (400GB, btrfs)
└── /home (remaining, btrfs)
```

**Essential commands:**
- `df -h` - Check disk usage
- `lsblk -f` - See all partitions and mounts
- `sudo nixos-rebuild switch --flake .#BearsiMac` - Apply config changes
- `sudo nix-collect-garbage -d` - Free up space
- `nixos-rebuild list-generations` - See all system generations
- `sudo nixos-rebuild switch --rollback` - Revert to previous generation

**Configuration location:**
- `/home/jbear/iNixOS-Willowie/` - Your flake repo
- `hardware-configuration.nix` - Generated hardware config (in repo root)
- `nixosConfigurations/BearsiMac/configuration.nix` - Your machine-specific config

**After installation, you should:**
1. ✅ Be able to boot from internal drives (no USB needed)
2. ✅ Have fast system on SSD
3. ✅ Have plenty of space on HDD
4. ✅ Be able to update by editing configs and running nixos-rebuild
5. ✅ Be able to roll back if something breaks

---

## Next Steps After Successful Installation

1. **Customize your desktop environment**
2. **Install additional packages** (add to `environment.systemPackages`)
3. **Set up the Atlas frontend** and chakra services (currently stubs)
4. **Configure automatic backups** of /home
5. **Set up remote access** (SSH, VPN, etc.)
6. **Explore the chakra system** architecture

Your iMac 2019 is now running a fully functional NixOS system with the iNixOS-Willowie sacred geometry configuration! 🌀
