# Copilot Instructions for iNixOS-Willowie

This repository contains a NixOS configuration for the BearsiMac system, featuring a modular architecture inspired by sacred geometry and chakra systems.

## Project Overview

- **Type**: NixOS Flake-based configuration
- **Target System**: BearsiMac (Willowie Kitchen)
- **NixOS Version**: 23.11
- **Architecture**: Modular system with chakra-based organization and sacred geometry patterns

## Code Style and Conventions

### Nix Code Standards

- Use 2-space indentation for Nix files
- Follow standard Nix formatting with `nixpkgs-fmt` (available via `nix fmt`)
- Use `with lib;` at the top of module files for cleaner option definitions
- Prefer `mkIf` for conditional configuration blocks
- Use `mkOption` with proper type declarations and descriptions

### Module Structure

- **Service modules**: Place in `modules/services/`
- **System modules**: Place in `modules/system/`
- **Chakra modules**: Spiritual/conceptual organization in `chakras/` directory
- Each module should follow the standard NixOS module pattern:
  ```nix
  { config, pkgs, lib, ... }:
  
  with lib;
  
  {
    options = { ... };
    config = mkIf ... { ... };
  }
  ```

### File Naming

- Use kebab-case for file and directory names (e.g., `atlas-frontend.nix`)
- Module files should be named `default.nix` within their directories or descriptive names in module directories
- Configuration files use `.nix` extension

### Comments and Documentation

- Add descriptive comments for complex logic or spiritual/metaphysical concepts
- Document options with clear descriptions
- Use inline comments for sacred geometry symbols and their meanings
- Include warnings for stub implementations or pending features

## Architecture Patterns

### Sacred Geometry System

- The configuration uses a "sacred geometry" metaphor with:
  - **Metatron Cube**: Central translator/bridge (`sacred_geometry/metatron_cube_translator.nix`)
  - **Chakra System**: Nine chakras organized as petals in a hexagonal hive
  - **DOJO Nodes**: Distributed service architecture
  - **ATLAS Frontend**: Ghost alignment interface

### Modular Organization

- **Chakras**: Conceptual groupings (ajna, anahata, jnana, manipura, muladhara, sahasrara, soma, svadhisthana, vishuddha)
- **dot-hive**: Aggregator module that imports all chakras
- **specialArgs**: Pass paths via `sacredGeometryPath` and `chakrasPath`

## Building and Testing

### Prerequisites

- NixOS with experimental features enabled:
  ```nix
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  ```

### Build Commands

- **Evaluate configuration**: `./scripts/evaluate-environment.sh`
- **Test build**: `nix build .#nixosConfigurations.BearsiMac.config.system.build.toplevel`
- **Format code**: `nix fmt`
- **Switch system**: `sudo nixos-rebuild switch --flake .#BearsiMac`

### Validation

- Run evaluation script before making PRs
- Ensure no build-blocking errors
- Hardware configuration may be missing in CI (expected)
- Check that all imports resolve correctly

## Security Best Practices

- Never hardcode secrets or credentials in Nix files
- Use systemd service hardening options when available
- Keep user accounts minimal and system-only where appropriate
- Review firewall rules before enabling services

## Service Development

### Creating New Services

1. Create module in `modules/services/your-service.nix`
2. Follow the established pattern with `options` and `config` sections
3. Create systemd service with proper user isolation
4. Document MQTT sources or other configuration options
5. Add warnings for stub implementations
6. Consider chakra alignment if conceptually relevant

### Environment Variables

- Pass configuration through systemd service environment
- Use `${toString ...}` for numeric values in environment strings
- Reference options via `config.services.yourService.option`

## Documentation

- Keep `README-QUICKSTART.md` updated with user-facing setup steps
- Document technical details in `docs/CONFIGURATION_REVIEW.md`
- Add runbooks for operational procedures in `docs/runbooks/`
- Update `REFACTORING_SUMMARY.md` for major architectural changes

## Common Pitfalls

- **Missing hardware-configuration.nix**: Use conditional imports or templates
- **Undefined chakra references**: Ensure all chakras are imported in `dot-hive/default.nix`
- **Port conflicts**: Check existing services before assigning ports
- **Missing dependencies**: Declare all package dependencies in module
- **Experimental features**: Required for flakes, must be explicitly enabled

## Spiritual/Metaphysical Context

This configuration embraces a holistic worldview where:
- Technology interfaces with consciousness ("bumblebee consciousness")
- Systems align with sacred patterns and frequencies
- Components are organized by energy centers (chakras)
- The "impossible flight" through collective intelligence is valued

Respect these metaphors when extending the system, but ensure all code remains functional and maintainable.

## Testing Requirements

- Verify configuration evaluates without errors
- Test builds complete successfully
- Check that systemd services have valid configurations
- Ensure modules can be imported without missing dependencies
- Run `./scripts/evaluate-environment.sh` before submitting changes

## Dependencies

- Avoid adding unnecessary dependencies
- Use packages from nixpkgs when possible
- Document any new service dependencies clearly
- Consider the minimal nature of NixOS configurations

## File Organization

```
.
├── chakras/              # Spiritual/conceptual organization
├── configuration.nix     # Legacy configuration (use flake.nix)
├── docs/                 # Documentation
├── dot-hive/            # Chakra aggregator module
├── flake.nix            # Main flake configuration
├── hardware-configuration.nix  # Target system hardware
├── modules/             # Custom NixOS modules
│   ├── services/        # Service definitions
│   └── system/          # System configurations
├── nixosConfigurations/ # Per-machine configurations
├── sacred_geometry/     # Core translation/bridge logic
├── scripts/             # Utility scripts
└── tools/               # Development tools
```

## Getting Help

- Review `README-QUICKSTART.md` for setup guidance
- Check `docs/CONFIGURATION_REVIEW.md` for technical details
- Examine existing modules for patterns and conventions
- Consult NixOS manual for standard module development: https://nixos.org/manual/nixos/stable/
