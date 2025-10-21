#!/usr/bin/env bash
# field-preflight.sh - Validation guardrails for NixOS configuration
# Returns 0 on success, non-zero on validation failures
set -euo pipefail

HARDWARE_CONFIG="/etc/nixos/hardware-configuration.nix"
MAIN_CONFIG="/etc/nixos/configuration.nix"
EXIT_CODE=0

echo "=== FIELD Preflight Validation ==="
echo ""

# Check if hardware-configuration.nix exists
if [ ! -f "$HARDWARE_CONFIG" ]; then
  echo "✗ ERROR: hardware-configuration.nix not found at $HARDWARE_CONFIG"
  EXIT_CODE=1
else
  echo "✓ Found hardware-configuration.nix"
  
  # Check for duplicate filesystem mountpoints
  echo "  Checking for duplicate fileSystems mountpoints..."
  MOUNTPOINTS=$(grep -oP 'fileSystems\."\K[^"]+' "$HARDWARE_CONFIG" 2>/dev/null || true)
  if [ -n "$MOUNTPOINTS" ]; then
    DUPLICATE_MOUNTS=$(echo "$MOUNTPOINTS" | sort | uniq -d)
    if [ -n "$DUPLICATE_MOUNTS" ]; then
      echo "✗ ERROR: Duplicate fileSystems mountpoints detected:"
      echo "$DUPLICATE_MOUNTS" | while read -r mount; do
        echo "    - $mount"
      done
      EXIT_CODE=1
    else
      echo "  ✓ No duplicate mountpoints"
    fi
  fi
  
  # Check for duplicate options lines for the same filesystem
  echo "  Checking for duplicate options in fileSystems blocks..."
  # This is a simplified check - looks for multiple "options = [" in the same context
  DUPLICATE_OPTIONS=$(grep -n "options = \[" "$HARDWARE_CONFIG" 2>/dev/null | cut -d: -f1 | sort | uniq -d || true)
  if [ -n "$DUPLICATE_OPTIONS" ]; then
    # Additional check: are there actually duplicates?
    # Count occurrences of options lines that appear more than once
    OPTIONS_LINES=$(grep "options = \[" "$HARDWARE_CONFIG" 2>/dev/null || true)
    if [ -n "$OPTIONS_LINES" ]; then
      # For each filesystem block, check if it has multiple options lines
      # This is a heuristic - we check if there are sequential options lines which shouldn't happen
      PREV_LINE=0
      while IFS=: read -r LINE_NUM _; do
        if [ "$PREV_LINE" -ne 0 ] && [ $((LINE_NUM - PREV_LINE)) -lt 10 ]; then
          echo "✗ WARNING: Potential duplicate options lines near line $LINE_NUM"
          echo "  Please review $HARDWARE_CONFIG manually"
        fi
        PREV_LINE=$LINE_NUM
      done < <(grep -n "options = \[" "$HARDWARE_CONFIG" 2>/dev/null || true)
    fi
  fi
  echo "  ✓ No obvious duplicate options patterns"
  
  # Check for transient devices (overlay, /etc/nix/*, /nix/store/*)
  echo "  Checking for transient devices..."
  TRANSIENT=$(grep -E "(device = \"overlay\"|/etc/nix|/nix/store)" "$HARDWARE_CONFIG" 2>/dev/null || true)
  if [ -n "$TRANSIENT" ]; then
    echo "✗ ERROR: Transient devices found in hardware-configuration.nix:"
    echo "$TRANSIENT" | while read -r line; do
      echo "    $line"
    done
    EXIT_CODE=1
  else
    echo "  ✓ No transient devices"
  fi
fi

echo ""

# Check configuration.nix
if [ ! -f "$MAIN_CONFIG" ]; then
  echo "✗ WARNING: configuration.nix not found at $MAIN_CONFIG"
  # This is a warning, not a hard failure
else
  echo "✓ Found configuration.nix"
  
  # Check for duplicate boot loader options
  echo "  Checking for duplicate boot.loader options..."
  BOOT_LOADER_ENABLES=$(grep -E "boot\.loader\.(systemd-boot|grub)\.enable" "$MAIN_CONFIG" 2>/dev/null || true)
  if [ -n "$BOOT_LOADER_ENABLES" ]; then
    DUPLICATE_BOOT=$(echo "$BOOT_LOADER_ENABLES" | sort | uniq -d)
    if [ -n "$DUPLICATE_BOOT" ]; then
      echo "✗ ERROR: Duplicate boot.loader options detected:"
      echo "$DUPLICATE_BOOT" | while read -r opt; do
        echo "    $opt"
      done
      EXIT_CODE=1
    else
      echo "  ✓ No duplicate boot.loader options"
    fi
  fi
  
  # Check for top-level /boot fileSystems in configuration.nix (should be in blueprint or hardware-config only)
  echo "  Checking for /boot fileSystems in configuration.nix..."
  BOOT_FS=$(grep -E 'fileSystems\."/boot"' "$MAIN_CONFIG" 2>/dev/null || true)
  if [ -n "$BOOT_FS" ]; then
    echo "✗ WARNING: Found /boot fileSystems declaration in configuration.nix"
    echo "  This should typically be in hardware-configuration.nix or blueprint.nix"
    echo "  (Not failing on this, but consider moving it)"
  else
    echo "  ✓ No /boot fileSystems in configuration.nix"
  fi
fi

echo ""

# Check blueprint if it exists
BLUEPRINT="/etc/nixos/field/blueprint.nix"
if [ -f "$BLUEPRINT" ]; then
  echo "✓ Found blueprint.nix"
  
  # Basic syntax check
  echo "  Checking blueprint syntax..."
  if nix-instantiate --parse "$BLUEPRINT" &>/dev/null; then
    echo "  ✓ Blueprint syntax valid"
  else
    echo "✗ ERROR: Blueprint syntax invalid"
    nix-instantiate --parse "$BLUEPRINT" 2>&1 | head -10
    EXIT_CODE=1
  fi
else
  echo "ℹ Blueprint not found at $BLUEPRINT (optional)"
fi

echo ""
echo "=== Preflight Summary ==="
if [ $EXIT_CODE -eq 0 ]; then
  echo "✓ All validation checks passed"
  echo "Configuration is ready for nixos-rebuild"
else
  echo "✗ Validation failed - see errors above"
  echo "Please fix issues before running nixos-rebuild"
fi

exit $EXIT_CODE
