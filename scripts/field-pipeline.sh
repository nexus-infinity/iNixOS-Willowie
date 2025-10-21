#!/usr/bin/env bash
# ========================================================
# File: field-pipeline.sh
# Role: Field Awareness Pipeline (The Weave)
# Function: Scans the host system, generates a report, 
#           and executes a conflict-free configuration build.
# ========================================================
set -euo pipefail

# --- Configuration Constants ---
FLAKE_REF=".#BearsiMac"
REPORT_DIR="./FIELD_AWARENESS_REPORT"
LOG_FILE="${REPORT_DIR}/rebuild_switch_log.txt"
# NEW FIX: Define the required experimental features string
# This string will be passed via NIX_CONFIG for robust execution under sudo.
# NOTE: Removed double quotes around the value to prevent nested quote confusion during sudo sh -c.
NIX_FEATURES="extra-experimental-features = nix-command flakes"

echo "🔮 Initiating Field Awareness Pipeline (The Weave)..."
echo "Target Configuration: ${FLAKE_REF}"

# --- Temporal Anchor (Git Check) and Directory Alignment ---
# Enforce that the script is run from the canonical repository root to satisfy the 'git status' command.
if [ ! -d .git ] && [ ! -f flake.nix ]; then
    echo "🚨 ERROR (Temporal Anchor Failure): This script must be run from the root directory of the iNixOS Flake (where .git and flake.nix reside)." >&2
    echo "Please navigate to the repository root and re-run." >&2
    exit 1
fi
echo "✅ Temporal Anchor Confirmed: Operating from Flake Root."


# --- Step 1: Initialize Report Directory ---
echo "--- 1. Creating FIELD Awareness Report Directory ---"
mkdir -p "${REPORT_DIR}"
echo "Report will be stored in: ${REPORT_DIR}"

# --- Step 2: System Sanity Check (Generate Report) ---
echo "--- 2. Generating Hardware and Config Sanity Report ---"
echo "Capturing Flake Structure (Flake Integrity Check)..."
# Use 'nix' command with the features passed via NIX_CONFIG for robustness
# NOTE: The simplest, most direct way to pass a config string is preferred here.
NIX_CONFIG="${NIX_FEATURES}" nix flake show .# > "${REPORT_DIR}/flake_structure.txt" || echo "Flake show failed (expected if uncommitted changes exist)."

echo "Capturing Canonical State (Git Status)..."
git status >> "${REPORT_DIR}/config_status.txt"
echo "System awareness data captured."

# --- Step 3: Conflict-Free Build (The Test) ---
echo "--- 3. Running Conflict-Free Build (nixos-rebuild build) ---"
echo "Starting build process with Flake Command enabled. Output is piped to console and log file: ${LOG_FILE}"

# NEW FIX: Use 'sudo sh -c' for reliable environment variable passing, preventing shell expansion errors.
NIX_BUILD_CMD="nixos-rebuild build --flake \"${FLAKE_REF}\" --show-trace"

# The command is wrapped in single quotes for sh -c, which correctly preserves the internal NIX_CONFIG assignment.
if sudo sh -c "NIX_CONFIG='${NIX_FEATURES}' ${NIX_BUILD_CMD}" 2>&1 | tee "${LOG_FILE}"; then
    BUILD_STATUS="SUCCESS"
    echo "✅ BUILD STATUS: SUCCESS. The new configuration compiled conflict-free."
else
    BUILD_STATUS="FAILED"
    echo "❌ BUILD STATUS: FAILED. Check ${LOG_FILE} for trace details." >&2
    exit 1
fi

# --- Step 4: Finalize and Switch (The Alignment) ---
if [ "$BUILD_STATUS" = "SUCCESS" ]; then
    echo "--- 4. Executing Sacred Field Reset (nixos-rebuild switch) ---"
    echo "This action commits the new geometric state to the system's core."
    
    # NEW FIX: Use 'sudo sh -c' for reliable switch command execution.
    NIX_SWITCH_CMD="nixos-rebuild switch --flake \"${FLAKE_REF}\""

    if sudo sh -c "NIX_CONFIG='${NIX_FEATURES}' ${NIX_SWITCH_CMD}" 2>&1 | tee -a "${LOG_FILE}"; then
        echo "🎉 Sacred Field Reset COMPLETE."
        echo "The NixOS DOJO Mirror is now sovereign on BearsiMac."
        echo "Next step: Initiate migration of Living Portals (macOS Apps)."
    else
        echo "🚨 SWITCH FAILED. The build succeeded, but deployment failed. System state is unknown. Check logs." >&2
        exit 1
    fi
fi
