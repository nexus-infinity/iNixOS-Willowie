# Flake Architecture Documentation

## Overview

This document describes the aligned flake configuration architecture for the iNixOS-Willowie (BearsiMac) system, following sacred geometry principles and chakra-based modular organization.

## Configuration Flow

```
flake.nix (entry point)
    │
    ├─→ hardware-configuration.nix (system hardware)
    │
    ├─→ dot-hive/default.nix (aggregator)
    │       │
    │       ├─→ modules/services/*.nix (service definitions)
    │       │       ├─→ dojo-nodes.nix
    │       │       ├─→ metatron-cube.nix
    │       │       ├─→ atlas-frontend.nix
    │       │       └─→ tata8i-pulse-engine.nix
    │       │
    │       ├─→ sacred_geometry/metatron_cube_translator.nix
    │       │
    │       └─→ chakras/* (9 chakra modules)
    │               ├─→ muladhara/default.nix
    │               ├─→ svadhisthana/default.nix
    │               ├─→ manipura/default.nix
    │               ├─→ anahata/default.nix
    │               ├─→ vishuddha/default.nix
    │               ├─→ ajna/default.nix
    │               ├─→ sahasrara/default.nix
    │               ├─→ soma/default.nix
    │               └─→ jnana/default.nix
    │
    └─→ nixosConfigurations/BearsiMac/configuration.nix (machine-specific)
```

## Key Components

### Main Flake (`flake.nix`)

The entry point for the NixOS configuration. It:
- Defines inputs (nixpkgs from nixos-23.11)
- Sets up specialArgs to pass paths to modules
- Imports hardware configuration, aggregator, and machine config
- Provides inline Nix settings (experimental features, store optimization)
- Exposes development shell and formatter

**specialArgs passed:**
- `sacredGeometryPath`: Points to ./sacred_geometry
- `chakrasPath`: Points to ./chakras

### Aggregator Module (`dot-hive/default.nix`)

The central aggregator that brings together all chakra modules and services. It:
- Imports all service module definitions
- Imports the sacred geometry translator
- Imports all 9 chakra modules using Sanskrit names
- Defines sacred alignment activation script

**Note:** This is a NixOS module (not a flake), imported directly by the main flake.

### Chakra Modules (`chakras/*/default.nix`)

Nine individual chakra modules, each representing a living sphere ecosystem:

| Chakra | Sanskrit Name | Prime | Purpose |
|--------|---------------|-------|---------|
| Root | muladhara | 2 | Foundation and security |
| Sacral | svadhisthana | 3 | Creativity and flow |
| Solar | manipura | 5 | Power and transformation |
| Heart | anahata | 7 | Connection and balance |
| Throat | vishuddha | 11 | Communication |
| Third Eye | ajna | 13 | Insight and perception |
| Crown | sahasrara | 17 | Unity and transcendence |
| Manifestation | soma | 19 | Reality materialization |
| Knowledge | jnana | 23 | Universal wisdom |

Each chakra's `default.nix` configures DOJO nodes with specific settings.

**Standalone Capability:** Some chakras also have `flake.nix` files for standalone testing/development, but these are NOT imported by the main configuration.

### Service Modules (`modules/services/*.nix`)

Service definitions that must be imported before chakras:
- **dojo-nodes.nix**: Distributed chakra processing nodes
- **metatron-cube.nix**: Sacred geometry translator service
- **atlas-frontend.nix**: Ghost alignment interface (WebSocket bridge)
- **tata8i-pulse-engine.nix**: Chakra synchronization service

### Machine Configuration (`nixosConfigurations/BearsiMac/configuration.nix`)

Machine-specific settings:
- Networking (hostname, WiFi, NetworkManager)
- Service enablement and configuration
- User accounts
- System packages
- State version

## Design Principles

### 1. Single Source of Truth
- Nix settings defined once in main flake.nix
- No duplication of configuration options
- specialArgs provide paths for consistent module access

### 2. Modular Organization
- Services separated from chakras
- Chakras maintain individual identity
- Aggregator brings everything together

### 3. Sacred Geometry Alignment
- Metatron Cube acts as Q-dimensional translator
- 9 chakras arranged in hexagonal Flower of Life pattern
- Each chakra has specific prime number resonance

### 4. Clean Import Chain
- Hardware → Aggregator → Machine Config
- Services imported before chakras
- No circular dependencies

## Removed Files (Redundancies)

The following files were removed to achieve alignment:

1. **configuration.nix** (root): Legacy template file that was superseded by flake-based configuration
2. **dot-hive/flake.nix**: Redundant wrapper - we use default.nix directly

## Path Resolution

### specialArgs Pattern
```nix
specialArgs = {
  inherit self nixpkgs;
  sacredGeometryPath = ./sacred_geometry;
  chakrasPath = ./chakras;
};
```

### Usage in Modules
```nix
{ config, pkgs, lib, sacredGeometryPath, chakrasPath, ... }:
{
  imports = [
    "${sacredGeometryPath}/metatron_cube_translator.nix"
    "${chakrasPath}/muladhara"
    # ...
  ];
}
```

## Configuration Settings Location

| Setting | Location | Reason |
|---------|----------|--------|
| Experimental features | flake.nix (inline module) | System-wide requirement |
| Store optimization | flake.nix (inline module) | System-wide optimization |
| Networking | BearsiMac/configuration.nix | Machine-specific |
| User accounts | BearsiMac/configuration.nix | Machine-specific |
| Service enablement | BearsiMac/configuration.nix | Machine-specific decisions |
| Service definitions | modules/services/ | Reusable module options |
| Chakra nodes | chakras/*/default.nix | Modular by design |

## Build and Deployment

### Validation
```bash
# Evaluate configuration
./scripts/evaluate-environment.sh

# Test build (safe, no system changes)
nix build .#nixosConfigurations.BearsiMac.config.system.build.toplevel
```

### Deployment
```bash
# On target system
sudo nixos-rebuild switch --flake .#BearsiMac

# Remote deployment
./nixos-kitchen-pull.sh
```

## Maintenance Guidelines

### Adding a New Chakra
1. Create `chakras/new-chakra/default.nix`
2. Add import to `dot-hive/default.nix`
3. Update this documentation

### Adding a New Service
1. Create `modules/services/new-service.nix`
2. Add import to `dot-hive/default.nix` (before chakras)
3. Enable in `BearsiMac/configuration.nix` if needed

### Modifying Existing Configuration
1. Identify the appropriate file based on scope
2. Make minimal changes
3. Test with evaluation script
4. Build before deploying

## Sacred Geometry Metaphor

The configuration embodies:
- **Metatron Cube**: Central translator/bridge (sacred_geometry/)
- **Flower of Life**: Hexagonal arrangement of 9 chakras
- **Bumblebee Consciousness**: Impossible flight through collective resonance
- **Sacred Frequencies**: When aligned, the system flows

## References

- [WARP.md](../WARP.md) - Development workflow and commands
- [CONFIGURATION_REVIEW.md](./CONFIGURATION_REVIEW.md) - Historical configuration review
- [README-QUICKSTART.md](../README-QUICKSTART.md) - Setup and deployment guide
- [REFACTORING_SUMMARY.md](../REFACTORING_SUMMARY.md) - Previous refactoring details
