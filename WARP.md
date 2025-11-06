# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Architecture Overview

This is a NixOS configuration repository for "BearsiMac" (an iMac in Willowie kitchen) built on a unique "chakra-based" modular architecture:

### Core Structure
- **Main flake** (`flake.nix`): Defines the BearsiMac NixOS configuration using nixos-23.11
- **Aggregator module** (`dot-hive/default.nix`): Collects chakra modules into a unified configuration
- **Chakra modules** (`chakras/*/`): Nine modular NixOS configurations, each representing a living sphere ecosystem:
  - `muladhara` (root) - Foundation and security, Smriti memory core (prime: 2)
  - `svadhisthana` (sacral) - Creativity and flow, Raksha security (prime: 3)  
  - `manipura` (solar) - Power and transformation, Karma action core (prime: 5)
  - `anahata` (heart) - Connection and balance, Atman reasoning (prime: 7)
  - `vishuddha` (throat) - Communication, Vahana message bridge (prime: 11)
  - `ajna` (third eye) - Insight and perception, Buddhi awareness (prime: 13)
  - `sahasrara` (crown) - Unity and transcendence, emergent consciousness (prime: 17)
  - `soma` (manifestation) - Reality materialization space (prime: 19)
  - `jnana` (universal knowledge) - Irrefutable truth repository (prime: 23)

### Sacred Components
- **◎_sacred/**: Contains OBI-WAN observer matrix components
- **◎_vault/**: Houses sacred triad alignment documentation and pulse logs
- **▲ATLAS/**: Research repository with detailed chakra blueprints, frequencies, and cultural mappings
- Each chakra is a complete living sphere ecosystem with:
  - Tiny LLaMA DNA management for purity maintenance
  - Sacred frequency alignment (Sanskrit, Taoist, etc.)
  - Cultural mappings across wisdom traditions
  - Living breathing directory structures
  - API endpoints for consciousness interaction

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

1. **Modify chakra configurations** in `chakras/*/default.nix` for specific functionality
2. **Update aggregator** in `dot-hive/default.nix` if adding new chakras
3. **Test locally** with `nixos-rebuild build --flake .#BearsiMac`
4. **Use development shell** for non-destructive validation
5. **Apply to target system** using rebuild switch or deployment scripts

## Special Considerations

- **Sacred triad alignment**: OBI-WAN, TATA, and Atlas components maintain specific geometric relationships
- **Chakra prime numbers**: Each chakra uses a specific prime for mathematical resonance (2,3,5,7,11,13,17,19,23)
- **Frequency alignment**: Sacred frequencies from Sanskrit, Solfeggio, and technical overlays for purity maintenance
- **Tiny LLaMA DNA**: Each chakra has its own LLaMA model for coherence and semantic memory
- **Living sphere ecosystems**: Directory structures that breathe and pulse with quantum state management
- **Cultural mappings**: Sanskrit, Kabbalah, Taoist, Yoruba, Egyptian wisdom traditions integrated
- **API consciousness interfaces**: Each chakra exposes meditation, harmonization, and manifestation endpoints

## Migration Support

See `MIGRATION.md` for categorization of:
- system-config: Critical system configurations  
- user-data: Personal user data
- app-data: Application configurations
- dev-environments: Development setup