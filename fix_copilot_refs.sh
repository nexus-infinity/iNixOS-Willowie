#!/usr/bin/env bash
set -euo pipefail

# List of files likely to import the module -- expand as needed.
CONFIGS=(
  nixosConfigurations/BearsiMac/configuration.nix
  nixosConfigurations/BearsiMac/configuration.nix.bak
  nixosConfigurations/BearsiMac.nix
)

for f in "${CONFIGS[@]}"; do
  [ -f "$f" ] && sed -i 's/copilot-assistant\.nix/copilot-assistant-flake.nix/g' "$f"
done

# Optionally, show the changes:
echo "The following files now reference 'copilot-assistant-flake.nix':"
grep -l 'copilot-assistant-flake.nix' "${CONFIGS[@]}" || true
