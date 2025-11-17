#!/usr/bin/env bash
set -euo pipefail

echo "== Flake entrypoints (flake.nix: nixosConfigurations) =="
if [ ! -f flake.nix ]; then
  echo "[ERROR] No flake.nix in current dir! Run from your flake root."
  exit 2
fi
grep -E 'nixosConfigurations\.' flake.nix | grep -v '#' | sed 's/^/  /'

echo; echo "== Checking imported modules in all configuration files =="

find nixosConfigurations -name "*.nix" | while read file; do
  echo "-- $file"
  grep "imports" "$file" || echo "  (No imports block found)"
done

echo; echo "== Searching for forbidden absolute imports =="
grep -r 'imports = \[\s*\/' nixosConfigurations modules 2>/dev/null && echo "[ERROR] Found absolute import(s)!" && exit 1 || echo "No absolute imports detected!"

echo; echo "== Checking Copilot Assistant import path alignment =="

find nixosConfigurations -name "*.nix" | while read file; do
  if grep -q 'copilot-assistant' "$file"; then
    echo "-- $file includes Copilot Assistant:"
    cat "$file" | grep "copilot-assistant"
  fi
done

echo; echo "== Verifying Copilot Assistant module exists and is tracked =="
if [ ! -f modules/services/copilot-assistant.nix ]; then
  echo "[ERROR] modules/services/copilot-assistant.nix is not present!"
  exit 2
fi
git ls-files --error-unmatch modules/services/copilot-assistant.nix >/dev/null && echo "  ...copilot-assistant.nix is tracked" || (echo "[ERROR] copilot-assistant.nix not tracked in git!"; exit 3)

echo; echo "== Git status (all config and modules must be committed) =="
git status

echo; echo "== TEST: NixOS can see Copilot Assistant option =="
nixos-option services.copilot-assistant.enable && echo "  ...Option found!" || echo "[WARN] services.copilot-assistant.* not visible via nixos-option"

echo; echo "== TEST: Systemd status of Copilot Assistant =="
if systemctl status copilot-assistant.service 2>/dev/null | grep -q active; then
  echo "[PASS] copilot-assistant.service is active"
else
  echo "[FAIL] copilot-assistant.service not found or not running"
fi

echo; echo "== TEST: HTTP port =="
if curl -s http://localhost:8765/ | grep -iq "copilot"; then
  echo "[PASS] Copilot API is responding on port 8765"
else
  echo "[FAIL] Nothing found at http://localhost:8765/ -- check service config"
fi

echo
echo "=== SUMMARY ==="
echo "If you see any [ERROR], fix those before proceeding. If all [PASS], your flake and config are correctly aligned!"
