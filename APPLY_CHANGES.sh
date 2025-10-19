#!/bin/bash
# Exact commands to apply the dot-hive aggregator changes

set -e

echo "=== Creating feature branch ==="
git checkout -b feat/dot-hive-agg

echo "=== Staging changes ==="
git add flake.nix dot-hive/

echo "=== Committing changes ==="
git commit -m "Wire top-level flake to dot-hive aggregator and add devShell"

echo "=== Pushing branch ==="
git push origin feat/dot-hive-agg

echo ""
echo "=== Next steps ==="
echo "1. Open a PR on GitHub from feat/dot-hive-agg → main"
echo "2. Or use: gh pr create --fill"
echo ""
echo "=== Validation commands (run these after switching to NixOS) ==="
echo "nix flake show"
echo "nix flake show .#"
echo "nix flake show ./dot-hive"
echo "nix develop .#x86_64-linux"
echo "nixos-rebuild build --flake .#BearsiMac"
echo ""
echo "Repository is ready!"