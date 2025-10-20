#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/nexus-infinity/iNixOS-Willowie.git"
TARGET_DIR="/etc/nixos"
BACKUP_DIR="/etc/nixos.pre-repo"
BRANCH="main"
FLAKE=".#BearsiMac"

usage() {
  cat <<EOF
Usage: sudo bash scripts/deploy-safe.sh [--apply] [--switch]

By default this script performs a safe one-shot backup, clones the repository into /etc/nixos\nand runs non-destructive validation (nix flake show and a build with --show-trace).\n
Options:
  --apply    Perform destructive cleaning of untracked files (git clean -fdx) before building
  --switch   If build succeeds, perform 'sudo nixos-rebuild switch --flake .${FLAKE}'
EOF
}

APPLY=false
SWITCH=false
for arg in "$@"; do
  case "$arg" in
    --apply) APPLY=true ;;
    --switch) SWITCH=true ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $arg"; usage; exit 2 ;;
  esac
done

# Ensure script is run from a writable directory (not required, but helpful)
CURR_DIR=$(pwd)

echo "[deploy-safe] Starting safe deploy script..."

# One-shot backup of existing /etc/nixos
if [ -d "$TARGET_DIR" ]; then
  echo "[deploy-safe] Backing up existing $TARGET_DIR -> $BACKUP_DIR"
  sudo rm -rf "$BACKUP_DIR" || true
  sudo mv "$TARGET_DIR" "$BACKUP_DIR"
else
  echo "[deploy-safe] No existing $TARGET_DIR found; continuing"
fi

# Clone the repo into /etc/nixos
echo "[deploy-safe] Cloning $REPO_URL into $TARGET_DIR"
sudo git clone "$REPO_URL" "$TARGET_DIR"

# Ensure correct branch and state
cd "$TARGET_DIR"
sudo git fetch origin
sudo git checkout "$BRANCH"
sudo git reset --hard "origin/$BRANCH"

# Sync submodules (if any)
sudo git submodule sync --recursive || true
sudo git submodule update --init --recursive --force || true

# Optionally clean untracked files
if [ "$APPLY" = true ]; then
  echo "[deploy-safe] Performing destructive clean of untracked files"
  sudo git clean -fdx
else
  echo "[deploy-safe] Skipping destructive git clean (use --apply to enable)"
  sudo git clean -fdn || true
fi

# Show flake outputs
echo "[deploy-safe] Showing flake outputs"
sudo nix flake show .# || true

# Enter devshell advice (not interactive here)
echo "[deploy-safe] To inspect a dev shell, run: nix develop .#x86_64-linux"

# Attempt a non-switch build (capture log)
BUILD_LOG="/tmp/nixos-build.log"
echo "[deploy-safe] Building (non-switch) with: nixos-rebuild build --flake .${FLAKE} --show-trace"
if sudo nixos-rebuild build --flake ".${FLAKE}" --show-trace 2>&1 | sudo tee "$BUILD_LOG"; then
  echo "[deploy-safe] Build succeeded. Log: $BUILD_LOG"
  if [ "$SWITCH" = true ]; then
    echo "[deploy-safe] Switching system now with: sudo nixos-rebuild switch --flake .${FLAKE}"
    sudo nixos-rebuild switch --flake ".${FLAKE}"
  else
    echo "[deploy-safe] Not switching (run with --switch to activate)",
    echo "[deploy-safe] If you want to switch now: sudo nixos-rebuild switch --flake .${FLAKE}"
  fi
  exit 0
else
  echo "[deploy-safe] Build FAILED. See $BUILD_LOG for details. Restoring backup not automatic." >&2
  echo "[deploy-safe] To restore previous config: sudo rm -rf $TARGET_DIR && sudo mv $BACKUP_DIR $TARGET_DIR" >&2
  exit 1
fi
