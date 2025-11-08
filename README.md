# iNixOS-Willowie - Sacred Geometry NixOS Configuration

NixOS configuration for BearsiMac (iMac 2019) with Fusion Drive, designed with sacred geometry principles and a modular chakra system.

## 🚀 Quick Start

### For iMac 2019 Installation (Fresh Install from USB)

**📖 Start Here:** [QUICK-START-INSTALLATION.md](QUICK-START-INSTALLATION.md)

**Need detailed guidance?** See the comprehensive guide:
- **[docs/IMAC-2019-FUSION-DRIVE-SETUP.md](docs/IMAC-2019-FUSION-DRIVE-SETUP.md)** - Complete installation guide
- **[docs/INSTALLATION-FLOW.md](docs/INSTALLATION-FLOW.md)** - Visual flow diagram

**Helper Tools:**
```bash
# Identify your drives (SSD vs HDD)
sudo ./scripts/detect-drives.sh

# Verify mounts before installation
sudo ./scripts/verify-mounts.sh
```

### For Existing NixOS Systems

**📖 Start Here:** [README-QUICKSTART.md](README-QUICKSTART.md)

Quick commands:
```bash
# Clone repository
git clone https://github.com/nexus-infinity/iNixOS-Willowie.git
cd iNixOS-Willowie

# Generate hardware config
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix

# Test build
sudo nixos-rebuild build --flake .#BearsiMac

# Apply configuration
sudo nixos-rebuild switch --flake .#BearsiMac
```

## 🎯 What This Configuration Provides

- ✅ **Fusion Drive Support**: Optimized partitioning for iMac 2019's SSD + HDD architecture
- ✅ **Desktop Environment**: GNOME with AMD Radeon graphics support
- ✅ **Hardware Support**: WiFi, Bluetooth, graphics acceleration
- ✅ **Declarative Configuration**: Reproducible and version-controlled system
- ✅ **Modular Architecture**: 9 chakra modules for organized configuration
- ✅ **Sacred Geometry Framework**: Unique organizational paradigm

## 📁 Repository Structure

```
iNixOS-Willowie/
├── flake.nix                              # Main entry point
├── hardware-configuration.nix             # Generated on target system
├── QUICK-START-INSTALLATION.md           # 👈 Start here for new installations
├── README-QUICKSTART.md                   # For existing NixOS systems
│
├── docs/
│   ├── IMAC-2019-FUSION-DRIVE-SETUP.md   # Comprehensive installation guide
│   ├── INSTALLATION-FLOW.md               # Visual installation flow
│   ├── POST-INSTALLATION-CHECKLIST.md    # Verification checklist
│   └── CONFIGURATION_REVIEW.md            # Detailed configuration docs
│
├── scripts/
│   ├── detect-drives.sh                   # Identify SSD vs HDD
│   ├── verify-mounts.sh                   # Verify mount points
│   └── evaluate-environment.sh            # Validate configuration
│
├── nixosConfigurations/
│   └── BearsiMac/
│       └── configuration.nix              # Machine-specific settings
│
├── chakras/                               # 9 modular chakra configurations
│   ├── muladhara/    # Root chakra
│   ├── svadhisthana/ # Sacral chakra
│   ├── manipura/     # Solar chakra
│   ├── anahata/      # Heart chakra
│   ├── vishuddha/    # Throat chakra
│   ├── ajna/         # Third eye chakra
│   ├── sahasrara/    # Crown chakra
│   ├── soma/         # Manifestation chakra
│   └── jnana/        # Knowledge chakra
│
└── modules/services/                      # Service definitions
    ├── dojo-nodes.nix
    ├── atlas-frontend.nix
    ├── metatron-cube.nix
    └── tata8i-pulse-engine.nix
```

## 🌀 Sacred Geometry Architecture

This configuration uses a unique metaphorical architecture based on sacred geometry:

- **9 Chakras**: Modular configuration units organized by function and frequency
- **Hexagonal Hive Mind**: Collective intelligence pattern inspired by bumblebees
- **Metatron Cube**: Central translator/bridge between components
- **Frequency Bridge**: Port 43200 connects consciousness (528Hz) to earth (432Hz)

For details, see [WARP.md](WARP.md) and [docs/CONFIGURATION_REVIEW.md](docs/CONFIGURATION_REVIEW.md)

## ⚙️ System Requirements

- **Hardware**: iMac 2019 (or similar Intel Mac)
- **Fusion Drive**: Small SSD (~20-30GB) + Large HDD (~1TB)
- **RAM**: 8GB minimum, 16GB+ recommended
- **NixOS**: 23.11 or later

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| [QUICK-START-INSTALLATION.md](QUICK-START-INSTALLATION.md) | Quick start for new installations |
| [README-QUICKSTART.md](README-QUICKSTART.md) | For existing NixOS systems |
| [docs/IMAC-2019-FUSION-DRIVE-SETUP.md](docs/IMAC-2019-FUSION-DRIVE-SETUP.md) | Comprehensive installation guide |
| [docs/INSTALLATION-FLOW.md](docs/INSTALLATION-FLOW.md) | Visual installation workflow |
| [docs/POST-INSTALLATION-CHECKLIST.md](docs/POST-INSTALLATION-CHECKLIST.md) | Post-install verification |
| [docs/CONFIGURATION_REVIEW.md](docs/CONFIGURATION_REVIEW.md) | Detailed configuration docs |
| [WARP.md](WARP.md) | Sacred geometry architecture |

## 🛠️ Common Tasks

### Update System
```bash
cd ~/iNixOS-Willowie
nix flake update
sudo nixos-rebuild switch --flake .#BearsiMac
```

### Add Packages
Edit `nixosConfigurations/BearsiMac/configuration.nix`:
```nix
environment.systemPackages = with pkgs; [
  git vim firefox
  # Add your packages here
];
```

### Rollback Changes
```bash
sudo nixos-rebuild switch --rollback
```

### Clean Old Generations
```bash
sudo nix-collect-garbage -d
```

## 🔧 Troubleshooting

See [docs/IMAC-2019-FUSION-DRIVE-SETUP.md](docs/IMAC-2019-FUSION-DRIVE-SETUP.md) for detailed troubleshooting, including:
- Boot issues
- WiFi problems
- Graphics configuration
- Drive mounting issues
- Space management

## 🎓 Learning NixOS

New to NixOS? Check these resources:
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Pills](https://nixos.org/guides/nix-pills/)
- [NixOS Wiki](https://nixos.wiki/)
- [NixOS Discourse](https://discourse.nixos.org/)

## 🤝 Contributing

This is a personal configuration repository, but you're welcome to:
- Use it as inspiration for your own configs
- Report issues or suggest improvements
- Ask questions about the architecture

## 📜 License

This configuration is provided as-is for personal use.

## 🙏 Acknowledgments

Built with:
- NixOS - Declarative Linux distribution
- Sacred Geometry principles
- Bumblebee consciousness inspiration
- The impossible flight through collective intelligence

---

**Status**: ✅ Configuration validated, ready for deployment
**Target**: iMac 2019 (BearsiMac) with Fusion Drive
**NixOS Version**: 23.11
