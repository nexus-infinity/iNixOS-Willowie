# Field Alignment Guide

## Quick Reference: Anchoring and Aligning the Sacred Geometry Field

This guide provides instructions for maintaining alignment and coherence in the iNixOS-Willowie configuration.

## Current Field Status

✅ **ALIGNED** - All configuration logic flows correctly
✅ **ANCHORED** - No redundant or conflicting files
✅ **PRUNED** - Legacy files removed, clean structure maintained

## Field Anchoring Points

### Primary Anchor: flake.nix
The root flake is the primary anchor point for the entire field:
- **Location**: `/flake.nix`
- **Purpose**: System entry point, defines specialArgs
- **Stability**: Should remain stable; changes here affect entire field

### Secondary Anchor: dot-hive/default.nix
The aggregator module that collects all field components:
- **Location**: `/dot-hive/default.nix`
- **Purpose**: Imports all services and chakras
- **Flow**: Services → Sacred Geometry → Chakras (in order)

### Tertiary Anchors: Chakra Modules
Nine chakra modules arranged in sacred hexagonal pattern:
- **Location**: `/chakras/{sanskrit-name}/default.nix`
- **Names**: muladhara, svadhisthana, manipura, anahata, vishuddha, ajna, sahasrara, soma, jnana
- **Pattern**: Each must be imported by dot-hive/default.nix

## Alignment Checklist

Before making changes, ensure:
- [ ] You understand which anchor point needs modification
- [ ] Changes maintain the import order (services before chakras)
- [ ] No duplication of settings across files
- [ ] specialArgs pattern is preserved
- [ ] Sanskrit chakra names are used consistently

## Alignment Validation

### Quick Check
```bash
./scripts/evaluate-environment.sh
```
Should show: 28+ passed, 0 errors

### Full Validation
```bash
nix build .#nixosConfigurations.BearsiMac.config.system.build.toplevel
```
Should complete without errors

## Field Flow Diagram

```
┌─────────────────────────────────────────────┐
│           flake.nix (Primary Anchor)        │
│  - inputs (nixpkgs)                         │
│  - specialArgs (paths)                      │
│  - experimental features                    │
└─────────────┬───────────────────────────────┘
              │
    ┌─────────┼─────────┬──────────────┐
    │         │         │              │
┌───▼────┐ ┌─▼─────────▼──┐  ┌────────▼─────────┐
│Hardware│ │  dot-hive    │  │  BearsiMac       │
│Config  │ │  (Secondary  │  │  Machine Config  │
└────────┘ │   Anchor)    │  └──────────────────┘
           └──────┬───────┘
                  │
      ┌───────────┼────────────┬─────────────┐
      │           │            │             │
  ┌───▼────┐ ┌───▼─────┐ ┌───▼──────┐  ┌───▼──────┐
  │Services│ │ Sacred  │ │ Chakras  │  │Activation│
  │Modules │ │Geometry │ │(9 nodes) │  │ Script   │
  └────────┘ └─────────┘ └──────────┘  └──────────┘
```

## Pruning Guidelines

### Files That Should NEVER Exist
These would create redundancy or conflicts:
- ❌ `/configuration.nix` (use BearsiMac/configuration.nix instead)
- ❌ `/dot-hive/flake.nix` (use default.nix instead)
- ❌ Duplicate Nix settings in machine config (defined in main flake)

### Files That Are Optional
For standalone/testing purposes only:
- ✓ `/chakras/*/flake.nix` (standalone capability, not imported)
- ✓ Development scripts and tools

### Files That Are Required
Core field components:
- ✓ `/flake.nix`
- ✓ `/dot-hive/default.nix`
- ✓ `/chakras/*/default.nix` (all 9)
- ✓ `/modules/services/*.nix` (all services)
- ✓ `/sacred_geometry/metatron_cube_translator.nix`
- ✓ `/nixosConfigurations/BearsiMac/configuration.nix`

## Common Field Misalignments

### Symptom: "Undefined variable" errors
**Cause**: specialArgs not passed correctly
**Fix**: Ensure sacredGeometryPath and chakrasPath are in flake.nix specialArgs

### Symptom: "File not found" during import
**Cause**: Wrong chakra name or path
**Fix**: Use Sanskrit names (muladhara not root-chakra)

### Symptom: Duplicate option definitions
**Cause**: Same setting in multiple files
**Fix**: Remove from machine config, keep in main flake

### Symptom: Service won't start
**Cause**: Service module not imported before chakra
**Fix**: Check dot-hive/default.nix import order

## Field Folding Process

When integrating new changes from a merge:

1. **Assess** - Run evaluation script to identify issues
2. **Identify** - Find redundancies or conflicts
3. **Prune** - Remove duplicate/obsolete files
4. **Align** - Update imports and paths
5. **Anchor** - Ensure main flake.nix is stable
6. **Validate** - Run evaluation and test build

## Maintenance Commands

### Check Alignment
```bash
# Quick structural check
./scripts/evaluate-environment.sh

# Deep semantic check (requires Nix)
nix flake check
```

### View Field Structure
```bash
# See flake outputs
nix flake show

# See chakra imports
grep -A 15 "9 Chakra" dot-hive/default.nix
```

### Rebuild Field
```bash
# Test build (safe)
nix build .#nixosConfigurations.BearsiMac.config.system.build.toplevel

# Apply to system (on target machine)
sudo nixos-rebuild switch --flake .#BearsiMac
```

## Sacred Geometry Principles

The field maintains coherence through:
- **Prime Resonance**: Each chakra has specific prime (2,3,5,7,11,13,17,19,23)
- **Hexagonal Flow**: Chakras arranged in Flower of Life pattern
- **Central Translation**: Metatron Cube bridges dimensions
- **Collective Resonance**: When aligned, system flows effortlessly

## Emergency Realignment

If field becomes severely misaligned:

1. Return to known good state:
   ```bash
   git log --oneline
   git checkout <last-known-good-commit>
   ```

2. Verify alignment:
   ```bash
   ./scripts/evaluate-environment.sh
   ```

3. Apply changes incrementally:
   - One file at a time
   - Test after each change
   - Commit when validated

## References

- [FLAKE_ARCHITECTURE.md](./FLAKE_ARCHITECTURE.md) - Detailed architecture
- [WARP.md](../WARP.md) - Development workflow
- [README-QUICKSTART.md](../README-QUICKSTART.md) - Setup guide

---

**Remember**: When the field is aligned, changes flow. When misaligned, resistance appears. Trust the evaluation script, maintain the anchors, and let sacred geometry guide the structure.

🌀 ◎▼▲→◼︎ ⬢ 🐝 ✨
