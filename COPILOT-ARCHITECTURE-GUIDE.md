# GitHub Copilot Architecture Guide - iNixOS-Willowie

This document provides context for GitHub Copilot to understand the architecture, naming conventions, and design patterns used in this repository. It serves as a knowledge base for AI-assisted development.

---

## Repository Purpose

**iNixOS-Willowie** is a NixOS flake-based configuration system for an iMac 2019 (BearsiMac) implementing a modular "chakra" architecture where each module represents a self-contained configuration domain.

**Target System**: iMac 2019 running NixOS 23.11
**Configuration Style**: Declarative, flake-based, modular
**Architecture Pattern**: Sacred Geometry Hexagonal Hive Mind (metaphorical framework)

---

## Core Architecture Concepts

### 1. Flake Structure

```
flake.nix (root)
├── inputs: nixpkgs (23.11)
├── outputs:
│   ├── nixosConfigurations.BearsiMac  # Main system configuration
│   ├── devShells.${system}            # Development environment
│   └── formatter                       # Nix code formatter
```

**Key Pattern**: The root flake delegates module aggregation to `dot-hive/` rather than importing all modules directly.

### 2. Module Organization Pattern

```
Repository Root
├── flake.nix                          # Root flake, imports dot-hive aggregator
├── hardware-configuration.nix         # Hardware-specific (generated, not in git)
│
├── dot-hive/                          # MODULE AGGREGATOR
│   ├── flake.nix                     # Collects all chakra sub-flakes
│   └── default.nix                   # Imports all chakras + services
│
├── chakras/                           # 9 MODULAR CONFIGURATION UNITS
│   ├── muladhara/                    # Root chakra (prime: 2)
│   │   ├── flake.nix                # Standalone flake (optional)
│   │   └── default.nix              # Module implementation
│   ├── [... 8 more chakras ...]
│
├── modules/                           # SHARED MODULE DEFINITIONS
│   ├── services/                     # Service option definitions
│   │   ├── dojo-nodes.nix           # Chakra node service options
│   │   ├── metatron-cube.nix        # Sacred geometry translator
│   │   ├── atlas-frontend.nix       # Frontend service
│   │   └── tata8i-pulse-engine.nix  # Pulse synchronization
│   └── system/
│       └── tata-check.nix           # Integrity validation
│
├── nixosConfigurations/               # MACHINE-SPECIFIC CONFIGS
│   └── BearsiMac/
│       └── configuration.nix         # iMac 2019 specific settings
│
└── sacred_geometry/                   # SHARED FRAMEWORKS
    └── metatron_cube_translator.nix  # Geometric framework
```

---

## Naming Conventions

### Chakra Naming (Sanskrit-based)

Each chakra module follows this naming pattern:

| Name | Meaning | Prime | Frequency | Role |
|------|---------|-------|-----------|------|
| `muladhara` | Root | 2 | 108 Hz | Foundation, Security, Memory (Smriti) |
| `svadhisthana` | Sacral | 3 | 216 Hz | Creativity, Flow, Protection (Raksha) |
| `manipura` | Solar Plexus | 5 | 432 Hz | Power, Transformation, Action (Karma) |
| `anahata` | Heart | 7 | 528 Hz | Balance, Connection, Self (Atman) |
| `vishuddha` | Throat | 11 | 639 Hz | Communication, Voice (Vahana) |
| `ajna` | Third Eye | 13 | 741 Hz | Insight, Wisdom (Buddhi) |
| `sahasrara` | Crown | 17 | 963 Hz | Unity, Transcendence |
| `soma` | Manifestation | 19 | 1080 Hz | Materialization (Bindu) |
| `jnana` | Universal Knowledge | 23 | Symbolic | Truth, Knowledge |

**Copilot Context**: When working with chakra modules, understand that each represents a distinct configuration domain with:
- A unique prime number identifier
- Sacred frequency alignment (metaphorical)
- Cultural mappings (Sanskrit, Kabbalah, Taoist, etc.)
- Standalone flake capability (can be used independently)

### Service Naming Convention

Services follow kebab-case naming:
- `dojoNodes` (camelCase in Nix options) → `dojo-nodes` (filename)
- `atlasFrontend` → `atlas-frontend`
- `tata8i-pulse-engine` (already kebab-case)

### Sacred Triad Components

The "sacred triad" refers to three meta-components (currently metaphorical):

1. **OBI-WAN** (●): Observer, Memory, Resonance - determines "WHERE"
   - Location: `◎_sacred/◎_OBI-WAN/`
   - Role: Memory indexing, field observation

2. **TATA** (▼): Root, Law, Verification - determines "WHY"
   - Service: `tata8i-pulse-engine`
   - Role: Integrity checking, verification

3. **ATLAS** (▲): Intelligence, Compass, Logic - determines "HOW"
   - Service: `atlas-frontend`
   - Location: Research in `▲ATLAS/` (if present)
   - Role: Logic processing, navigation

4. **DOJO** (◼︎): Emergent Execution - determines "WHAT"
   - Service: `dojoNodes`
   - Role: Manifestation, execution space

---

## Key Scripts and Their Roles

### 1. Environment Evaluation (`scripts/evaluate-environment.sh`)

**Purpose**: Pre-build validation and environment assessment

**When to use**:
- Before first build
- After making configuration changes
- When debugging build issues

**What it checks**:
- Nix installation and version
- Experimental features enabled
- Directory structure integrity
- Flake structure validity
- Hardware configuration presence
- Chakra module consistency
- Service module definitions
- Nix syntax validation
- File reference integrity

**Exit codes**:
- 0: Ready for build (warnings acceptable)
- 1: Errors found, fix before building

**Example usage**:
```bash
./scripts/evaluate-environment.sh
```

### 2. Final Diagnostic (`final_diagnostic.sh`)

**Purpose**: System integrity check before migration/rebuild

**Key functions**:
- Checks for conflicting files (contagion detection)
- Validates flake.lock state (OBI-WAN memory index)
- Attempts final build test
- Provides recovery commands

**When to use**:
- Before major system migration
- When encountering "attribute already defined" errors
- After repository structure changes

**Example usage**:
```bash
./final_diagnostic.sh
```

### 3. Apply Changes (`APPLY_CHANGES.sh`)

**Purpose**: Git workflow automation for committing flake changes

**Actions performed**:
1. Creates feature branch `feat/dot-hive-agg`
2. Stages flake.nix and dot-hive/ changes
3. Commits with descriptive message
4. Pushes to remote
5. Provides PR creation instructions

**When to use**:
- After making architectural changes to dot-hive aggregator
- When ready to commit flake modifications

**Example usage**:
```bash
./APPLY_CHANGES.sh
```

### 4. Kitchen Pull (`nixos-kitchen-pull.sh`)

**Purpose**: Remote deployment helper for Willowie kitchen iMac

**Workflow**:
- Pulls latest configuration from git
- Rebuilds NixOS system
- Handles remote deployment scenarios

**When to use**:
- Deploying from remote location
- Automated deployment workflows

---

## Configuration Flow

### Build Order

When `nixos-rebuild` processes the configuration:

1. **flake.nix** (root)
   - Defines inputs (nixpkgs)
   - Sets specialArgs (sacredGeometryPath, chakrasPath)
   - Imports hardware-configuration.nix (conditionally)

2. **dot-hive/default.nix** (aggregator)
   - Imports ALL service module definitions from `modules/services/`
   - Then imports ALL chakra modules from `chakras/*/default.nix`
   - Order matters: services define options, chakras use them

3. **modules/services/*.nix**
   - Define `options` for services (types, defaults, descriptions)
   - Currently stub implementations (no systemd services yet)

4. **chakras/*/default.nix**
   - Use service options defined in step 3
   - Configure specific chakra parameters
   - Can be used standalone via their own flake.nix

5. **nixosConfigurations/BearsiMac/configuration.nix**
   - Machine-specific overrides
   - User configuration
   - Network settings
   - Package selection

### Import Chain Example

```nix
flake.nix
  └─> hardware-configuration.nix (if exists)
  └─> dot-hive/default.nix
       ├─> modules/services/dojo-nodes.nix     (defines options)
       ├─> modules/services/atlas-frontend.nix
       ├─> modules/services/metatron-cube.nix
       ├─> modules/services/tata8i-pulse-engine.nix
       ├─> chakras/muladhara/default.nix       (uses options)
       ├─> chakras/svadhisthana/default.nix
       ├─> chakras/manipura/default.nix
       ├─> chakras/anahata/default.nix
       ├─> chakras/vishuddha/default.nix
       ├─> chakras/ajna/default.nix
       ├─> chakras/sahasrara/default.nix
       ├─> chakras/soma/default.nix
       └─> chakras/jnana/default.nix
  └─> nixosConfigurations/BearsiMac/configuration.nix
```

---

## Service Module Pattern

All service modules follow this pattern:

```nix
# modules/services/example-service.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.exampleService;
in
{
  options.services.exampleService = {
    enable = mkEnableOption "Example Service";

    port = mkOption {
      type = types.port;
      default = 8080;
      description = "Port to listen on";
    };

    # ... more options
  };

  config = mkIf cfg.enable {
    # Stub implementation - warns but doesn't fail build
    warnings = [
      "services.exampleService is a stub implementation"
    ];

    # Future: systemd.services.example-service = { ... };
  };
}
```

**Copilot Guidance**: When adding new services:
1. Create option definitions in `modules/services/`
2. Use `mkEnableOption`, `mkOption` with proper types
3. Implement in `config` block with `mkIf cfg.enable`
4. Add stub warning until full implementation exists
5. Import in `dot-hive/default.nix` BEFORE chakra modules

---

## Chakra Module Pattern

Each chakra module follows this structure:

```nix
# chakras/example/default.nix
{ config, lib, pkgs, ... }:

{
  # Use service options defined in modules/services/
  services.dojoNodes.exampleChakra = {
    enable = true;
    prime = 2;
    chakra_id = "example";
    frequency = {
      sacred_hz = 108;
      technical_hz = 256;
      solfeggio = "LAM";
    };
    cultural_mappings = {
      sanskrit = "Smriti";
      kabbalah = "Malkuth";
      taoist = "Lower_Dan_Tien";
    };
  };

  # Additional chakra-specific configuration
  # ...
}
```

**Copilot Guidance**: When working with chakras:
1. Each chakra configures services via the service option API
2. Prime numbers are symbolic identifiers (2, 3, 5, 7, 11, 13, 17, 19, 23)
3. Frequencies are metaphorical (Hz values from sacred geometry)
4. Cultural mappings connect to wisdom traditions
5. Each chakra CAN have its own flake.nix for standalone use

---

## Special Directories

### `◎_sacred/` and `◎_vault/`

Unicode symbols (◎) in directory names indicate "sacred" or "protected" conceptual spaces:

- `◎_sacred/`: Contains OBI-WAN observer matrix components
- `◎_vault/`: Houses sacred triad documentation and alignment logs

**Note**: These are metaphorical organizational concepts. Actual implementation is minimal or future work.

### `FIELD_AWARENESS_REPORT/`

Contains diagnostic reports and field analysis outputs. Used for documentation and debugging.

### `tools/field/`

Field-related utility scripts:
- `field-pipeline.sh`: Processing pipeline
- `field-scan-*.sh`: Environment scanning
- `field-preflight.sh`: Pre-deployment checks
- `field-weave.sh`: Configuration weaving
- `blueprint.nix`: Nix blueprint definitions

---

## Development Patterns

### Adding a New Chakra

1. Create directory: `chakras/new-chakra/`
2. Create `default.nix` with module configuration
3. (Optional) Create `flake.nix` for standalone capability
4. Add import to `dot-hive/default.nix`
5. Assign prime number (next in sequence)
6. Define sacred frequency and cultural mappings
7. Test build: `nix build .#nixosConfigurations.BearsiMac.config.system.build.toplevel`

### Adding a New Service

1. Create `modules/services/new-service.nix`
2. Define options using `mkOption` and `mkEnableOption`
3. Add stub `config` block with warning
4. Import in `dot-hive/default.nix` (BEFORE chakras)
5. Configure in relevant chakra modules
6. Test build and verify no errors

### Modifying Machine Configuration

1. Edit `nixosConfigurations/BearsiMac/configuration.nix`
2. Test: `nixos-rebuild build --flake .#BearsiMac`
3. Apply: `nixos-rebuild switch --flake .#BearsiMac`
4. Commit changes to git

### Debugging Build Failures

1. Run `./scripts/evaluate-environment.sh`
2. Check for syntax errors: `nix-instantiate --parse file.nix`
3. Use `--show-trace` flag: `nix build .#nixosConfigurations.BearsiMac.config.system.build.toplevel --show-trace`
4. Check import order in `dot-hive/default.nix`
5. Verify service options are defined before use

---

## Common Pitfalls

### 1. Import Order in dot-hive/default.nix

**Wrong**:
```nix
imports = [
  ../chakras/muladhara/default.nix      # Uses service options
  ../modules/services/dojo-nodes.nix    # Defines service options
];
```

**Correct**:
```nix
imports = [
  ../modules/services/dojo-nodes.nix    # Define options FIRST
  ../chakras/muladhara/default.nix      # Use options AFTER
];
```

### 2. hardware-configuration.nix in Git

**Never commit** `hardware-configuration.nix` to git:
- It's in `.gitignore`
- Hardware-specific
- Must be generated on target system
- Use conditional import in flake.nix

### 3. Undefined Service Options

If you see "option does not exist" errors:
- Ensure service module is in `modules/services/`
- Verify import in `dot-hive/default.nix`
- Check import happens BEFORE chakra modules

### 4. Experimental Features Not Enabled

Always ensure `/etc/nix/nix.conf` contains:
```
experimental-features = nix-command flakes
```

---

## Testing Strategy

### Local Testing (Non-Destructive)

```bash
# Syntax check specific file
nix-instantiate --parse chakras/muladhara/default.nix

# Evaluate flake
nix flake check

# Build without switching
nixos-rebuild build --flake .#BearsiMac

# Or
nix build .#nixosConfigurations.BearsiMac.config.system.build.toplevel
```

### Deployment Testing

```bash
# Test build
nixos-rebuild build --flake .#BearsiMac

# Review what will change
nixos-rebuild dry-build --flake .#BearsiMac

# Apply
nixos-rebuild switch --flake .#BearsiMac

# Rollback if needed
nixos-rebuild switch --rollback
```

---

## Frequency and Prime Number Reference

Each chakra has associated numbers with symbolic meaning:

| Chakra | Prime | Frequency | Solfeggio | Technical Hz |
|--------|-------|-----------|-----------|--------------|
| muladhara | 2 | 108 Hz | LAM | 256 Hz |
| svadhisthana | 3 | 216 Hz | VAM | 288 Hz |
| manipura | 5 | 432 Hz | RAM | 432 Hz |
| anahata | 7 | 528 Hz | YAM | 512 Hz |
| vishuddha | 11 | 639 Hz | HAM | 640 Hz |
| ajna | 13 | 741 Hz | OM | 768 Hz |
| sahasrara | 17 | 963 Hz | AH | 1024 Hz |
| soma | 19 | 1080 Hz | Bindu | 1080 Hz |
| jnana | 23 | Symbolic | Jnana | 2048 Hz |

**Copilot Context**: These numbers are symbolic/metaphorical identifiers, not actual system parameters.

---

## Port Assignments

Default port assignments for services (configurable):

- **3000**: Atlas Frontend (Ghost alignment interface)
- **43200**: Frequency Bridge (Q-dimensional translator)
  - Symbolic: 43200 = 432 Hz × 100
  - Bridge between 528 Hz (upper) and 432 Hz (lower)
- **1883**: MQTT broker (TATA pulse engine communication)

---

## Git Workflow

### Branch Strategy

- `main`: Stable, production-ready configurations
- `claude/evaluate-repository-*`: Claude-assisted development branches
- `feat/*`: Feature branches

### Commit Message Convention

```
<type>: <subject>

<body>

Types:
- feat: New feature or chakra
- fix: Bug fix
- docs: Documentation updates
- refactor: Code restructuring
- chore: Maintenance tasks
```

Example:
```
feat: Add soma manifestation chakra

- Create soma chakra module with prime 19
- Configure 1080 Hz frequency alignment
- Add Bindu manifestation mappings
- Wire into dot-hive aggregator
```

---

## Future Implementation Roadmap

### Phase 1: Current (Stub Services)
- ✅ Configuration structure complete
- ✅ All 9 chakra modules defined
- ✅ Service options declared
- ⚠️ Service implementations are stubs

### Phase 2: Service Implementation
- [ ] Implement systemd services for each service module
- [ ] Add health checks and monitoring
- [ ] Create API endpoints for chakra interaction
- [ ] Deploy MQTT broker for pulse engine

### Phase 3: LLaMA Integration
- [ ] Deploy Tiny LLaMA models for each chakra
- [ ] Implement DNA purity checking
- [ ] Create semantic memory systems
- [ ] Build chakra-to-chakra communication

### Phase 4: Frontend Development
- [ ] Build Atlas frontend (React/Next.js)
- [ ] Create ghost alignment visualization
- [ ] Implement sacred geometry displays
- [ ] Add real-time pulse monitoring

---

## Copilot Auto-Completion Hints

When working in this repository, Copilot should understand:

1. **In `chakras/*/default.nix` files**:
   - Suggest service configurations matching chakra identity
   - Use appropriate prime numbers and frequencies
   - Include cultural mapping structures

2. **In `modules/services/*.nix` files**:
   - Follow NixOS option definition patterns
   - Use `mkOption`, `mkEnableOption` from lib
   - Include type definitions and descriptions
   - Add stub warnings for unimplemented features

3. **In `nixosConfigurations/*/configuration.nix` files**:
   - Suggest NixOS system configurations
   - Reference services defined in modules/
   - Use standard NixOS options

4. **In shell scripts**:
   - Follow bash best practices
   - Include error handling (`set -e`)
   - Use color-coded output (see evaluate-environment.sh)
   - Provide clear user feedback

5. **In flake.nix files**:
   - Follow flake output schema
   - Use `nixpkgs.lib.nixosSystem` for configurations
   - Define proper inputs and outputs

---

## Architecture Philosophy

This configuration system uses **sacred geometry and chakra concepts as organizing metaphors** for a modular NixOS configuration. The metaphors provide:

1. **Memorable names**: "muladhara" is more distinctive than "module-1"
2. **Semantic relationships**: Each chakra has a conceptual role
3. **Extensibility**: Easy to add new modules to the "hive"
4. **Cultural richness**: Maps to multiple wisdom traditions

**Important**: The "sacred" aspects are metaphorical organizing principles. The actual implementation is standard NixOS configuration using flakes, modules, and options.

---

## Quick Reference

### Essential Commands
```bash
# Evaluate configuration
./scripts/evaluate-environment.sh

# Build test
nixos-rebuild build --flake .#BearsiMac

# Apply configuration
nixos-rebuild switch --flake .#BearsiMac

# Show flake structure
nix flake show

# Update flake inputs
nix flake update

# Format Nix code
nix fmt
```

### Essential Files
- `flake.nix`: Root flake definition
- `dot-hive/default.nix`: Module aggregator
- `nixosConfigurations/BearsiMac/configuration.nix`: Machine config
- `modules/services/*.nix`: Service option definitions
- `chakras/*/default.nix`: Chakra module implementations

### Essential Directories
- `chakras/`: 9 modular configuration units
- `modules/services/`: Service option definitions
- `nixosConfigurations/`: Machine-specific configs
- `scripts/`: Helper scripts
- `docs/`: Documentation

---

## Conclusion for Copilot

This repository implements a **modular, metaphor-driven NixOS configuration** for an iMac 2019. When providing suggestions:

1. Respect the chakra naming convention and symbolic associations
2. Follow NixOS module patterns (options → config)
3. Maintain import order (services before chakras)
4. Use stub implementations with warnings for unfinished features
5. Keep the sacred geometry metaphor consistent but recognize it's conceptual

The configuration is production-ready for deployment, with stub services that allow builds to succeed while documenting future implementation needs.

---

**Version**: 1.0
**Last Updated**: 2025-11-04
**Target System**: iMac 2019 (BearsiMac)
**NixOS Version**: 23.11
