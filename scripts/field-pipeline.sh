#!/bin/bash
# ====================================================================
# FIELD Awareness Pipeline (The Weave)
# Role: Performs validation, stability checks, memory updates, and build.
# This version enforces modern Nix commands to bypass legacy executables.
# ====================================================================

set -euo pipefail

# --- CONFIGURATION ---
TARGET_CONFIG=".#BearsiMac"
REPORT_DIR="./FIELD_AWARENESS_REPORT"

# The most robust way to enable flakes and nix-command on older systems.
# Must be passed using sudo sh -c 'NIX_CONFIG=...'
NIX_CONFIG="experimental-features = nix-command flakes"

# Explicitly find the modern nix executable path, bypassing outdated versions in $PATH
NIX_CMD=$(readlink -f /run/current-system/sw/bin/nix || echo "nix")

# --- FUNCTIONS ---

# Function to run commands with the correct NIX_CONFIG environment
run_nix_command() {
    # We use sudo sh -c '...' to ensure NIX_CONFIG is correctly passed to the root shell
    sudo sh -c "NIX_CONFIG='${NIX_CONFIG}' ${NIX_CMD} $*" 2>&1
}

# --- STEP 0: PRE-FLIGHT CHECK ---
echo "🔮 Initiating Field Awareness Pipeline (The Weave)..."
echo "Target Configuration: ${TARGET_CONFIG}"

# Temporal Anchor Check (Ensure we are in the Flake root)
if [[ ! -d ./.git ]] || [[ ! -f ./flake.nix ]]; then
    echo "🚨 ERROR (Temporal Anchor Failure): This script must be run from the root directory of the iNixOS Flake (where .git and flake.nix reside)."
    echo "Please navigate to the repository root and re-run."
    exit 1
fi
echo "✅ Temporal Anchor Confirmed: Operating from Flake Root."


# --- STEP 1: CREATE REPORT DIRECTORY ---
echo "--- 1. Creating FIELD Awareness Report Directory ---"
mkdir -p "$REPORT_DIR"
echo "Report will be stored in: ${REPORT_DIR}"


# --- CRITICAL EXCLUSIVE STEP: MEMORY UPDATE (Only runs with --update-only) ---
if [ "$1" == "--update-only" ]; then
    echo "--- FORCING OBI-WAN MEMORY UPDATE (nix flake update) ---"
    echo "This will reset the flake.lock file and re-index local paths."

    # Force the memory index update using the modern NIX_CMD and NIX_CONFIG
    UPDATE_OUTPUT=$(run_nix_command flake update)
    UPDATE_EXIT_CODE=$?

    if [ $UPDATE_EXIT_CODE -eq 0 ]; then
        echo "✅ OBI-WAN Memory Index Updated Successfully."
        echo "Ready for Clean Build."
    else
        echo "❌ OBI-WAN Memory Update FAILED. Output:"
        echo "$UPDATE_OUTPUT" | tee "${REPORT_DIR}/update_log.txt"
        exit 1
    fi
    exit 0
fi


# --- STEP 2: GENERATING SANITY REPORT ---
echo "--- 2. Generating Hardware and Config Sanity Report ---"

# Flake Integrity Check
echo "Capturing Flake Structure (Flake Integrity Check)..."
FLAKE_SHOW_OUTPUT=$(run_nix_command flake show) || true
echo "$FLAKE_SHOW_OUTPUT" > "${REPORT_DIR}/flake_structure.txt"
if [[ $FLAKE_SHOW_OUTPUT != *"error"* ]]; then
    echo "✅ Flake structure captured successfully."
else
    echo "Flake show failed (check ${REPORT_DIR}/flake_structure.txt for details)."
fi

# Git Status (Canonical State)
echo "Capturing Canonical State (Git Status)..."
sudo git status > "${REPORT_DIR}/config_status.txt"
echo "System awareness data captured."


# --- STEP 3: RUN CONFLICT-FREE BUILD ---
echo "--- 3. Running Conflict-Free Build (nixos-rebuild build) ---"
echo "Starting build process with Flake Command enabled. Output is piped to console and log file: ${REPORT_DIR}/rebuild_switch_log.txt"

# Run the non-switch build using the robust run_nix_command wrapper
BUILD_OUTPUT=$(run_nix_command build ".#${TARGET_CONFIG}" --no-build-output)
BUILD_EXIT_CODE=$?

# Log all output
echo "$BUILD_OUTPUT" | tee "${REPORT_DIR}/rebuild_switch_log.txt"

if [ $BUILD_EXIT_CODE -eq 0 ]; then
    echo "✅ BUILD STATUS: SUCCESS. The configuration is conflict-free and ready for switch."
    echo "Next Action: sudo nixos-rebuild switch --flake ${TARGET_CONFIG}"
else
    echo "❌ BUILD STATUS: FAILED. Check ${REPORT_DIR}/rebuild_switch_log.txt for trace details."
    exit 1
fi
