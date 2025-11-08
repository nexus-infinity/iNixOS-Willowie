# Quick Start - iMac 2019 Installation

## You Are Here Because...

You have an iMac 2019 with a Fusion Drive (small SSD + large HDD) and you need to:
- Install NixOS from USB
- Boot natively from internal drives (no USB needed)
- Have a working desktop environment
- Be able to update your system via GitHub

## Three Simple Steps to Get Started

### Step 1: Boot from USB and Identify Your Drives

```bash
# Boot from NixOS USB installer (hold Option/Alt during startup)
# Once at the terminal, run:

sudo ./scripts/detect-drives.sh
```

This will show you:
- Which device is your SSD (fast, small ~20-30GB)
- Which device is your HDD (slower, large ~1TB)
- Recommended partitioning strategy

**Write down your device names** (e.g., `/dev/nvme0n1` for SSD, `/dev/sda` for HDD)

### Step 2: Follow the Installation Guide

Open the comprehensive guide:

📖 **[docs/IMAC-2019-FUSION-DRIVE-SETUP.md](docs/IMAC-2019-FUSION-DRIVE-SETUP.md)**

This guide walks you through:
1. Partitioning your drives (WARNING: backs up first!)
2. Mounting filesystems
3. Installing NixOS
4. Configuring for first boot

**Recommended approach:** Option A (SSD for system, HDD for storage)

### Step 3: Verify Everything Works

After installation and first boot:

```bash
# Check you're on internal drives (not USB)
df -h

# Verify all mounts are correct
lsblk -f

# Test rebuild
cd ~/iNixOS-Willowie
sudo nixos-rebuild test --flake .#BearsiMac

# If test passes, make it permanent
sudo nixos-rebuild switch --flake .#BearsiMac
```

Then review: **[docs/POST-INSTALLATION-CHECKLIST.md](docs/POST-INSTALLATION-CHECKLIST.md)**

## Important Files and Locations

| What | Where | Purpose |
|------|-------|---------|
| **Installation Guide** | `docs/IMAC-2019-FUSION-DRIVE-SETUP.md` | Complete installation instructions |
| **Drive Detection** | `scripts/detect-drives.sh` | Identify SSD vs HDD |
| **Mount Verification** | `scripts/verify-mounts.sh` | Check mounts before install |
| **Configuration** | `nixosConfigurations/BearsiMac/configuration.nix` | Your system settings |
| **Hardware Config** | `hardware-configuration.nix` | Generated on your system |
| **Post-Install Check** | `docs/POST-INSTALLATION-CHECKLIST.md` | Verify everything works |

## Common Questions

**Q: Which partitioning strategy should I use?**
A: Option A (SSD for system, HDD for storage) gives the best performance.

**Q: Will I lose my data?**
A: Yes, installation will erase drives. Backup first!

**Q: How do I boot from internal drive after installation?**
A: Remove USB and reboot. System should boot from internal drive automatically.

**Q: What if something goes wrong?**
A: NixOS allows rollback. Boot previous generation from boot menu, or use USB to fix.

**Q: How do I update the system later?**
A: Edit configuration files, commit to git, then run `sudo nixos-rebuild switch --flake .#BearsiMac`

## Troubleshooting

**Can't boot from internal drive:**
- Check boot order in boot menu (hold Option/Alt during startup)
- Verify EFI partition is properly configured

**WiFi not working:**
- Firmware should be enabled in configuration
- Try `sudo systemctl restart NetworkManager`

**Desktop environment not loading:**
- Check `services.xserver.enable = true` in configuration.nix
- Check graphics drivers are loaded

**Running out of space on SSD:**
- `/nix/store` should be on HDD, not SSD
- Run `df -h` to verify mount points
- Regenerate hardware-configuration.nix if needed

## Next Steps After Successful Installation

1. ✅ Change initial password: `passwd`
2. ✅ Connect to WiFi
3. ✅ Update system: `sudo nixos-rebuild switch --flake .#BearsiMac`
4. ✅ Install additional software by editing `environment.systemPackages`
5. ✅ Commit changes to git
6. ✅ Set up backups for `/home`

## Getting Help

- **NixOS Manual**: https://nixos.org/manual/nixos/stable/
- **NixOS Wiki**: https://nixos.wiki/
- **NixOS Discourse**: https://discourse.nixos.org/
- **This Repository**: File an issue on GitHub

## Checklist for Today

- [ ] Boot from USB installer
- [ ] Run `sudo ./scripts/detect-drives.sh` to identify drives
- [ ] Follow installation guide: `docs/IMAC-2019-FUSION-DRIVE-SETUP.md`
- [ ] Complete partitioning and mounting
- [ ] Install NixOS
- [ ] Reboot and verify it boots from internal drive
- [ ] Complete post-installation checklist: `docs/POST-INSTALLATION-CHECKLIST.md`

---

**Remember:** Take your time, read the guides thoroughly, and backup any important data before starting. NixOS installation is declarative and reproducible, so even if something goes wrong, you can always reinstall or rollback.

Good luck! 🌀
