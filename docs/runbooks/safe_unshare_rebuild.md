# Safe Unshare → Bind → Chroot → NixOS Rebuild Flow

## Overview

This runbook describes the safe procedure for performing NixOS system rebuilds using namespace isolation via `unshare`, followed by bind mounts and chroot. This approach provides an additional safety layer for testing configuration changes before applying them to the running system.

## Purpose

- **Isolation**: Test configuration changes in an isolated namespace
- **Safety**: Prevent accidental damage to running system
- **Validation**: Verify build success before activation
- **Rollback**: Easy recovery if issues are detected

## Prerequisites

- Root access or sudo privileges
- Current NixOS system with working configuration
- Sufficient disk space in `/tmp` or designated work directory
- Basic understanding of Linux namespaces and chroot

## Procedure

### Step 1: Prepare Isolated Environment

Create a namespace-isolated environment using `unshare`:

```bash
# Create work directory
WORK_DIR="/tmp/nixos-rebuild-safe"
mkdir -p "$WORK_DIR"

# Enter isolated namespace (mount, PID, network, user)
# Note: This creates isolation but maintains access to host filesystem
sudo unshare --mount --pid --net --fork --mount-proc bash
```

**What this does**:
- `--mount`: Isolates mount namespace (changes won't affect host)
- `--pid`: Isolates process IDs
- `--net`: Isolates network (prevents unintended network changes)
- `--fork`: Forks process before entering namespace
- `--mount-proc`: Mounts new /proc in the namespace

### Step 2: Set Up Bind Mounts

Within the isolated namespace, prepare bind mounts for the chroot environment:

```bash
# Inside the unshared namespace

# Create chroot directory structure
CHROOT_DIR="/tmp/nixos-chroot"
mkdir -p "$CHROOT_DIR"/{nix,etc,var,run,tmp,proc,sys,dev}

# Bind mount essential directories (read-only where possible)
mount --bind /nix "$CHROOT_DIR/nix"
mount --bind /etc/nixos "$CHROOT_DIR/etc/nixos"
mount --bind /var "$CHROOT_DIR/var"

# Mount virtual filesystems
mount -t proc proc "$CHROOT_DIR/proc"
mount -t sysfs sys "$CHROOT_DIR/sys"
mount -t devtmpfs dev "$CHROOT_DIR/dev"
mount -t tmpfs tmpfs "$CHROOT_DIR/tmp"

# Optional: bind mount /run if needed for systemd socket communication
mount --bind /run "$CHROOT_DIR/run"
```

**What this does**:
- Creates minimal root filesystem for chroot
- Provides access to Nix store (required for builds)
- Mounts virtual filesystems needed by build tools
- Isolates changes to /tmp and other writable areas

### Step 3: Enter Chroot and Validate Configuration

```bash
# Still inside the unshared namespace
# Enter the chroot environment
chroot "$CHROOT_DIR" /bin/bash

# Inside chroot, verify we can access nix tools
which nix-build
which nixos-rebuild

# Validate the configuration syntax
cd /etc/nixos
nix-instantiate --eval -E 'let cfg = import ./configuration.nix; in cfg'

# Or use nixos-rebuild dry-build for more thorough validation
nixos-rebuild dry-build --flake .#BearsiMac
```

**What this does**:
- Enters isolated root filesystem
- Confirms Nix tools are accessible
- Validates NixOS configuration without building
- Provides early error detection

### Step 4: Perform Test Build

Still inside the chroot, attempt a full build:

```bash
# Inside chroot
# Perform build (not activation)
nixos-rebuild build --flake .#BearsiMac

# This creates a 'result' symlink to the built system
# Inspect what was built
ls -la result/
readlink result

# Check for FIELD chakra modules in the built system
grep -r "field.chakra" result/etc/ || echo "No FIELD chakra config found"

# Optionally inspect the built system's systemd units
ls result/etc/systemd/system/*-chakra.service || echo "No chakra services"
```

**What this does**:
- Builds complete NixOS system without activating
- Creates `result` symlink to built system closure
- Allows inspection of what will be activated
- Validates all dependencies can be built

### Step 5: Exit and Cleanup (If Test Successful)

If the build succeeded and inspection looks good:

```bash
# Exit chroot
exit

# Exit the unshared namespace
exit

# Clean up chroot environment
sudo umount -R /tmp/nixos-chroot/proc
sudo umount -R /tmp/nixos-chroot/sys
sudo umount -R /tmp/nixos-chroot/dev
sudo umount -R /tmp/nixos-chroot/run
sudo umount -R /tmp/nixos-chroot/tmp
sudo umount -R /tmp/nixos-chroot/var
sudo umount -R /tmp/nixos-chroot/etc
sudo umount -R /tmp/nixos-chroot/nix
sudo rm -rf /tmp/nixos-chroot
```

### Step 6: Apply to Live System (If Validated)

Only after successful validation in the isolated environment:

```bash
# On the live system (outside namespace/chroot)
cd /etc/nixos

# Perform the actual rebuild
sudo nixos-rebuild switch --flake .#BearsiMac

# Monitor for issues
sudo journalctl -f
```

**What this does**:
- Applies the validated configuration to the running system
- Activates new systemd services (including chakra services)
- Monitors system logs for activation issues

### Step 7: Verify Activation

```bash
# Check that FIELD chakra services are active (if enabled)
systemctl status muladhara-chakra.service
systemctl status field-translator.service

# Check audit logs
tail -f /var/log/iNixos-Hive/chakra-muladhara.log
tail -f /var/log/iNixos-Hive/translator.log

# Verify system activation scripts ran
journalctl -b | grep "FIELD Chakra Ecosystem"
```

## Emergency Rollback

If issues are detected after activation:

```bash
# List available generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# Or switch to specific generation
sudo /nix/var/nix/profiles/system-<number>-link/bin/switch-to-configuration switch
```

## Safety Checklist

Before proceeding with live activation:

- [ ] Configuration builds successfully in isolated environment
- [ ] All expected services are defined in result closure
- [ ] No obvious errors in build output
- [ ] Disk space sufficient (check with `df -h`)
- [ ] Backup of current configuration exists
- [ ] Know how to rollback (see above)
- [ ] Observer has captured pre-change baseline
- [ ] Off-hours or maintenance window if possible

## Common Issues and Solutions

### Issue: "Permission denied" when entering namespace

**Solution**: Ensure you're running with sudo/root privileges. Some systems require additional kernel parameters for unprivileged namespaces.

```bash
# Check if user namespaces are enabled
cat /proc/sys/kernel/unprivileged_userns_clone
# Should return 1 (enabled)

# If disabled, run with full sudo
sudo unshare [options] bash
```

### Issue: Build fails due to missing /run/systemd

**Solution**: Ensure /run is bind-mounted in the chroot if systemd integration is needed.

```bash
mount --bind /run "$CHROOT_DIR/run"
```

### Issue: "No space left on device" during build

**Solution**: Use a work directory on a partition with more space, or clean up old Nix store entries.

```bash
# Clean up old generations
sudo nix-collect-garbage -d

# Or specify different temp directory
export TMPDIR=/var/tmp
```

### Issue: Chroot environment can't access network

**Solution**: This is intentional for safety. If network is required for build (e.g., fetching dependencies), omit `--net` from unshare or use a different isolation approach.

```bash
# Unshare without network isolation
sudo unshare --mount --pid --fork --mount-proc bash
```

## Automation Script Template

```bash
#!/usr/bin/env bash
set -euo pipefail

CHROOT_DIR="/tmp/nixos-chroot"
FLAKE=".#BearsiMac"

cleanup() {
  echo "Cleaning up..."
  sudo umount -R "$CHROOT_DIR"/{proc,sys,dev,run,tmp,var,etc,nix} 2>/dev/null || true
  sudo rm -rf "$CHROOT_DIR"
}

trap cleanup EXIT

# Create and prepare chroot
sudo unshare --mount --pid --fork --mount-proc bash -c "
  mkdir -p '$CHROOT_DIR'/{nix,etc/nixos,var,run,tmp,proc,sys,dev}
  
  mount --bind /nix '$CHROOT_DIR/nix'
  mount --bind /etc/nixos '$CHROOT_DIR/etc/nixos'
  mount --bind /var '$CHROOT_DIR/var'
  mount -t proc proc '$CHROOT_DIR/proc'
  mount -t sysfs sys '$CHROOT_DIR/sys'
  mount -t devtmpfs dev '$CHROOT_DIR/dev'
  mount -t tmpfs tmpfs '$CHROOT_DIR/tmp'
  mount --bind /run '$CHROOT_DIR/run'
  
  # Run build in chroot
  chroot '$CHROOT_DIR' nixos-rebuild build --flake '$FLAKE'
"

echo "Build successful in isolated environment"
echo "Ready to apply to live system with: sudo nixos-rebuild switch --flake $FLAKE"
```

## References

- `man unshare` - Linux namespace isolation
- `man chroot` - Change root directory
- `man mount` - Mount filesystems
- NixOS manual: https://nixos.org/manual/nixos/stable/
- [docs/runbooks/field-governance.md](field-governance.md) - Governance procedures
