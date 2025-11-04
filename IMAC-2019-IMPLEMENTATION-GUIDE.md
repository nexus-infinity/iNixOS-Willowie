# iMac 2019 Implementation Guide for iNixOS-Willowie

## Current Situation Assessment

You are logged in as **root** on your iMac 2019 running NixOS at the terminal prompt. This guide will walk you through implementing the iNixOS-Willowie configuration on your system.

## Overview

The iNixOS-Willowie repository provides a sophisticated NixOS configuration based on sacred geometry principles with 9 modular "chakra" systems. This is a **flake-based NixOS configuration** designed specifically for your iMac 2019 (hostname: BearsiMac).

## Prerequisites Status Check

Before proceeding, verify your current environment:

### 1. Check Nix Version
```bash
nix --version
```
Expected: Nix 2.x or higher with flakes support

### 2. Check NixOS Version
```bash
nixos-version
```
The configuration targets NixOS 23.11

### 3. Check Current Location
```bash
pwd
```

### 4. Check if Repository Exists
```bash
ls -la ~/iNixOS-Willowie/
```

---

## Implementation Path Selection

Choose the appropriate path based on your situation:

### Path A: Fresh Installation (Repository Not Present)
If `~/iNixOS-Willowie/` doesn't exist, you need to clone it first.

### Path B: Repository Already Present
If `~/iNixOS-Willowie/` exists, proceed with configuration.

---

## STEP 1: Get the Repository

### If Cloning from GitHub:
```bash
# Navigate to home directory
cd ~

# Clone the repository (replace with actual GitHub URL)
git clone https://github.com/nexus-infinity/iNixOS-Willowie.git

# Navigate into repository
cd iNixOS-Willowie

# Switch to the designated development branch
git checkout claude/evaluate-repository-011CUoePZDnh6krsFQ6CMLD9
```

### If Repository Already Exists:
```bash
cd ~/iNixOS-Willowie
git status
git pull origin main  # or your current branch
```

---

## STEP 2: Enable Experimental Features

Nix flakes require experimental features to be enabled.

### Check Current Configuration:
```bash
cat /etc/nix/nix.conf
```

### If "experimental-features" is NOT present, add it:
```bash
# Backup existing config
cp /etc/nix/nix.conf /etc/nix/nix.conf.backup

# Add experimental features
echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf

# Restart Nix daemon
systemctl restart nix-daemon.service
```

### Verify:
```bash
nix flake --help
```
Should show flake commands without errors.

---

## STEP 3: Generate Hardware Configuration

This is **critical** - the hardware configuration must match your iMac 2019's actual hardware.

```bash
# Navigate to repository root
cd ~/iNixOS-Willowie

# Generate hardware configuration
nixos-generate-config --show-hardware-config > hardware-configuration.nix

# Review what was generated
cat hardware-configuration.nix
```

**Important Hardware Notes for iMac 2019:**
- Should detect Intel CPU (likely i5/i7/i9 8th/9th gen)
- Should include boot.initrd.kernelModules
- Should have filesystem mounts for / and /boot
- May include AMD Radeon graphics configuration

---

## STEP 4: Run Environment Evaluation

The repository includes a comprehensive validation script:

```bash
# Make script executable
chmod +x scripts/evaluate-environment.sh

# Run evaluation
./scripts/evaluate-environment.sh
```

**Expected Output:**
- ✓ Passed checks: 20-25
- ⚠ Warnings: 5-10 (mostly about stub services)
- ✗ Errors: Should be 0

**If you see errors**, review them carefully before proceeding. Most warnings are acceptable.

---

## STEP 5: Test Build (Non-Destructive)

**CRITICAL**: Always test before switching to new configuration!

### Method 1: Direct Nix Build
```bash
nix build .#nixosConfigurations.BearsiMac.config.system.build.toplevel --show-trace
```

### Method 2: Using nixos-rebuild
```bash
nixos-rebuild build --flake .#BearsiMac --show-trace
```

**What This Does:**
- Evaluates the entire configuration
- Downloads all required packages
- Builds the system closure
- Creates a `./result` symlink
- **DOES NOT** modify your running system

**Expected Time**: 5-30 minutes depending on network speed and what needs to be downloaded.

**If Build Succeeds:**
```bash
# Check the result
ls -la result/
readlink result
```

**If Build Fails:**
- Read error messages carefully
- Check `--show-trace` output
- Common issues:
  - Missing hardware-configuration.nix
  - Syntax errors in .nix files
  - Missing dependencies
  - Flake lock issues

---

## STEP 6: Review Configuration Before Switching

Before applying the configuration, review what will change:

```bash
# Show what the new system will include
nix flake show

# Review the BearsiMac-specific configuration
cat nixosConfigurations/BearsiMac/configuration.nix

# Check what services will be enabled
grep -r "enable = true" nixosConfigurations/BearsiMac/
```

**Key Configuration Elements:**
- Hostname: BearsiMac
- User: jbear (with wheel, networkmanager groups)
- Shell: zsh
- Network: WiFi "Willowie" via NetworkManager
- Services: SSH, GNOME (if X11 enabled), custom chakra services (stubs)

---

## STEP 7: Apply Configuration (The Moment of Truth)

**⚠️ WARNING**: This will rebuild your system and switch to the new configuration.

### Create a Backup First:
```bash
# List current system generation
nixos-rebuild list-generations

# Note the current generation number
```

### Apply the Configuration:
```bash
nixos-rebuild switch --flake .#BearsiMac
```

**What Happens:**
1. Builds the new system configuration
2. Switches systemd to new services
3. Updates bootloader with new entry
4. Activates new system immediately

**Expected Time**: 2-10 minutes

### If Switch Succeeds:
```bash
# Verify new system is active
nixos-version

# Check if services are running
systemctl status

# Verify user configuration
id jbear
```

### If Something Goes Wrong:
```bash
# Rollback to previous generation
nixos-rebuild switch --rollback

# Or reboot and select previous generation from bootloader menu
reboot
```

---

## STEP 8: Post-Installation Verification

### Check Chakra Configuration Status:
```bash
# Check if DOJO services are defined (they're stubs, so warnings are expected)
systemctl status dojo-nodes 2>/dev/null || echo "Service not yet implemented (expected)"

# Verify flake is properly registered
nix flake metadata ~/iNixOS-Willowie
```

### Verify Network Configuration:
```bash
# Check hostname
hostname

# Check network
nmcli device status
nmcli connection show

# Test internet
ping -c 3 nixos.org
```

### Verify User Setup:
```bash
# Switch to jbear user
su - jbear

# Check shell
echo $SHELL  # Should be /run/current-system/sw/bin/zsh

# Check groups
groups  # Should include wheel, networkmanager

# Exit back to root
exit
```

---

## STEP 9: Configure User Password

If user jbear doesn't have a password yet:

```bash
passwd jbear
```

---

## STEP 10: Optional - GUI Setup

If you want to enable the GNOME desktop environment:

### Edit Configuration:
The repository configuration includes X11 and GNOME settings in `configuration.nix`:
- services.xserver.enable = true
- services.xserver.displayManager.gdm.enable = true
- services.xserver.desktopManager.gnome.enable = true

These are already in the base config template but may need to be enabled in BearsiMac/configuration.nix.

### To enable GUI:
```bash
# Edit the BearsiMac configuration
vim nixosConfigurations/BearsiMac/configuration.nix

# Rebuild and switch
nixos-rebuild switch --flake .#BearsiMac

# Reboot for display manager
reboot
```

---

## Troubleshooting Common Issues

### Issue 1: "experimental-features not enabled"
```bash
# Add to /etc/nix/nix.conf
echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf
systemctl restart nix-daemon.service
```

### Issue 2: "hardware-configuration.nix not found"
```bash
cd ~/iNixOS-Willowie
nixos-generate-config --show-hardware-config > hardware-configuration.nix
```

### Issue 3: "evaluation aborted" during build
```bash
# Add --show-trace for detailed error
nix build .#nixosConfigurations.BearsiMac.config.system.build.toplevel --show-trace
```

### Issue 4: Build fails with "attribute already defined"
This usually means duplicate imports. Check:
```bash
# Look for duplicate module imports
grep -r "imports =" flake.nix dot-hive/ nixosConfigurations/
```

### Issue 5: Network issues after switch
```bash
# Restart NetworkManager
systemctl restart NetworkManager

# Reconnect to Willowie WiFi
nmcli device wifi connect Willowie
```

### Issue 6: Can't access flake from ~/iNixOS-Willowie
```bash
# Ensure you're in the right directory
cd ~/iNixOS-Willowie

# Check flake.nix exists
ls -la flake.nix

# Try rebuilding flake lock
nix flake update
```

---

## Understanding the Sacred Geometry Architecture

This configuration uses a unique metaphorical architecture:

### The 9 Chakras (Modular Configuration Units):
1. **muladhara** (root - prime 2, 108Hz) - Foundation/Security
2. **svadhisthana** (sacral - prime 3, 216Hz) - Creativity/Flow
3. **manipura** (solar - prime 5, 432Hz) - Power/Transformation
4. **anahata** (heart - prime 7, 528Hz) - Heart/Balance
5. **vishuddha** (throat - prime 11, 639Hz) - Communication
6. **ajna** (third eye - prime 13, 741Hz) - Insight/Awareness
7. **sahasrara** (crown - prime 17, 963Hz) - Unity/Transcendence
8. **soma** (manifestation - prime 19, 1080Hz) - Materialization
9. **jnana** (universal knowledge - prime 23) - Knowledge/Truth

### Current Implementation Status:
- ✅ **Configuration Structure**: Complete and working
- ✅ **Module Definitions**: All 9 chakras defined
- ⚠️ **Service Implementation**: Stubs only (warnings expected)
- 📋 **Future Work**: Actual systemd services, LLaMA models, APIs

---

## Next Steps After Successful Installation

### 1. Explore the Configuration:
```bash
# Show flake structure
nix flake show ~/iNixOS-Willowie

# List all chakra modules
ls -la ~/iNixOS-Willowie/chakras/

# Read documentation
cat ~/iNixOS-Willowie/README-QUICKSTART.md
```

### 2. Customize Your System:
```bash
# Edit machine-specific config
vim ~/iNixOS-Willowie/nixosConfigurations/BearsiMac/configuration.nix

# Add packages to environment.systemPackages
# Adjust service configurations
# Modify user settings
```

### 3. Make Updates:
```bash
cd ~/iNixOS-Willowie

# Make changes to configuration
# ...

# Test build
nixos-rebuild build --flake .#BearsiMac

# Apply changes
nixos-rebuild switch --flake .#BearsiMac
```

### 4. Keep Configuration in Sync:
```bash
# Commit changes
git add .
git commit -m "Customize BearsiMac configuration"

# Push to GitHub
git push origin claude/evaluate-repository-011CUoePZDnh6krsFQ6CMLD9
```

---

## Quick Reference Commands

### Essential Commands:
```bash
# Check current generation
nixos-rebuild list-generations

# Test build
nixos-rebuild build --flake .#BearsiMac

# Apply configuration
nixos-rebuild switch --flake .#BearsiMac

# Rollback
nixos-rebuild switch --rollback

# Update flake inputs
nix flake update

# Clean old generations
nix-collect-garbage -d
```

### Debugging Commands:
```bash
# Show flake outputs
nix flake show

# Check flake metadata
nix flake metadata .

# Evaluate configuration
nix eval .#nixosConfigurations.BearsiMac.config.system.build.toplevel

# Check syntax of specific file
nix-instantiate --parse file.nix
```

---

## Support Resources

### Documentation in Repository:
- `README-QUICKSTART.md` - Quick start guide
- `WARP.md` - Architecture overview for Warp terminal
- `docs/CONFIGURATION_REVIEW.md` - Comprehensive configuration review
- `docs/chakras.md` - Chakra system documentation

### NixOS Resources:
- NixOS Manual: https://nixos.org/manual/nixos/stable/
- Nix Pills: https://nixos.org/guides/nix-pills/
- NixOS Wiki: https://nixos.wiki/
- NixOS Discourse: https://discourse.nixos.org/

---

## Safety Notes

1. **Always test build before switch**: Use `nixos-rebuild build` first
2. **Hardware config is critical**: Never commit hardware-configuration.nix to git
3. **Rollback is available**: You can always revert to previous generation
4. **Backup important data**: Before major system changes
5. **Understand the configuration**: Review .nix files before applying

---

## Status Indicators

When running commands, look for these indicators:

- ✅ **Success**: Command completed without errors
- ⚠️ **Warning**: Non-critical issues (often expected with stub services)
- ✗ **Error**: Critical failure requiring attention
- ℹ️ **Info**: Informational messages

---

## Final Checklist

Before considering implementation complete:

- [ ] Experimental features enabled in /etc/nix/nix.conf
- [ ] hardware-configuration.nix generated for iMac 2019
- [ ] Environment evaluation script passes (0 errors)
- [ ] Test build succeeds
- [ ] Configuration switched successfully
- [ ] System boots and is stable
- [ ] User jbear exists and can log in
- [ ] Network connectivity works
- [ ] SSH access configured (if needed)
- [ ] Basic packages installed and accessible

---

## Conclusion

The iNixOS-Willowie configuration provides a sophisticated, modular NixOS system for your iMac 2019. While the "chakra" terminology is metaphorical, the underlying NixOS configuration is solid and production-ready.

The stub service implementations allow the configuration to build and deploy successfully while documenting future enhancements. As you become more familiar with the system, you can extend the chakra services with actual implementations.

**Remember**: NixOS's declarative nature means you can always rebuild, rollback, and experiment safely. The worst case scenario is rebooting and selecting a previous generation from the bootloader menu.

Good luck with your implementation! 🌀
