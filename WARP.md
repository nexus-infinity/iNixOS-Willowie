# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Architecture Overview

This is a NixOS configuration repository for "BearsiMac" (an iMac in Willowie kitchen) built on a unique "chakra-based" modular architecture:

### Core Structure
- **Main flake** (`flake.nix`): Defines the BearsiMac NixOS configuration using nixos-23.11
- **Aggregator flake** (`dot-hive/flake.nix`): Collects chakra sub-flakes into a unified module set
- **Chakra modules** (`chakras/*/`): Seven modular NixOS configurations, each representing a chakra:
  - `muladhara` (root) - Foundation and security (prime: 2)
  - `svadhisthana` (sacral) - Creativity and flow (prime: 3)  
  - `manipura` (solar) - Power and transformation (prime: 5)
  - `anahata` (heart) - Connection and balance (prime: 7)
  - `vishuddha` (throat) - Communication (prime: 11)
  - `ajna` (third eye) - Insight and perception (prime: 13)
  - `sahasrara` (crown) - Unity and transcendence (prime: 17)

### Sacred Components
- **◎_sacred/**: Contains OBI-WAN observer matrix components
- **◎_vault/**: Houses sacred triad alignment documentation and pulse logs
- Each chakra configures `services.dojoNodes` with unique prime numbers and energy settings

## Development Commands

### Build and Test
```bash
# Build configuration without switching (safe)
nixos-rebuild build --flake .#BearsiMac

# Build system toplevel directly
nix build .#nixosConfigurations.BearsiMac.config.system.build.toplevel

# Enter development shell (x86_64-linux)
nix develop .#x86_64-linux
```

### Flake Operations
```bash
# Inspect flake outputs
nix flake show
nix flake show .#
nix flake show ./dot-hive

# Format Nix files
nix fmt
```

### Apply Configuration (on target NixOS machine)
```bash
# Switch to new configuration
sudo nixos-rebuild switch --flake .#BearsiMac

# Use kitchen pull script for remote deployment
./nixos-kitchen-pull.sh
```

## Key Configuration Details

### Target System
- **Hostname**: BearsiMac
- **Architecture**: x86_64-linux  
- **NixOS Version**: 23.11
- **Network**: Willowie WiFi with NetworkManager

### Services Architecture
- **Atlas Frontend**: Ghost alignment interface (port 3000)
- **TATA 8i Pulse Engine**: Chakra synchronization service
- **DOJO Nodes**: Distributed chakra processing nodes with transaction optimization
- **SSH**: Enabled for remote access

### User Configuration
- **Primary user**: jbear (wheel, networkmanager groups, zsh shell)

## Development Workflow

1. **Modify chakra configurations** in `chakras/*/flake.nix` for specific functionality
2. **Update aggregator** in `dot-hive/flake.nix` if adding new chakras
3. **Test locally** with `nixos-rebuild build --flake .#BearsiMac`
4. **Use development shell** for non-destructive validation
5. **Apply to target system** using rebuild switch or deployment scripts

## Special Considerations

- **Sacred triad alignment**: OBI-WAN, TATA, and Atlas components maintain specific geometric relationships
- **Chakra prime numbers**: Each chakra uses a specific prime for mathematical resonance
- **Energy breath settings**: Configure perception thresholds and stability parameters
- **Cultural localization**: Domain-specific focus areas for each chakra node

## Migration Support

See `MIGRATION.md` for categorization of:
- system-config: Critical system configurations  
- user-data: Personal user data
- app-data: Application configurations
- dev-environments: Development setup