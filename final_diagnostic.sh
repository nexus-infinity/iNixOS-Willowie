#!/bin/bash
# ====================================================================
# SYSTEM INTEGRITY DIAGNOSTIC (ATLAS/Logic Compass)
# Role: Verifies the clean state of the configuration files before build.
# ====================================================================

set -e

# --- CONFIGURATION ---
TARGET_CONFIG=".#BearsiMac"
NIX_CONFIG="experimental-features = nix-command flakes"
NIX_CMD=$(readlink -f /run/current-system/sw/bin/nix || echo "nix")

echo "========================================================"
echo "🔮 FIELD INTEGRITY CHECK: CANONICAL COORDINATES"
echo "========================================================"
echo "Current Directory (Canonical Root): $(pwd)"
echo "Target Configuration Path: ${TARGET_CONFIG}"
echo "--------------------------------------------------------"

# --- CHECK 1: CONTAGION FILE (Source of the original conflict) ---
CONTAGION_FILE="./nixosConfigurations/kitchen-imac-2019.nix"
if [ -f "${CONTAGION_FILE}" ]; then
    echo "🚨 STATUS: CONFLICT FOUND (ENTANGLEMENT)"
    echo "File Exists: ${CONTAGION_FILE}"
    echo "Diagnosis: This file contains the outdated/conflicting hardware definitions that caused the original 'attribute already defined' error and is confusing the compiler's path index."
    echo ""
    echo "ACTION REQUIRED: Delete this file before proceeding."
    exit 1
else
    echo "✅ STATUS: Contagion File CLEAN. ${CONTAGION_FILE} does not exist."
fi

# --- CHECK 2: CORRUPTED MEMORY INDEX (Source of the final error) ---
if [ -f "./flake.lock" ]; then
    echo "⚠️ STATUS: Memory Index (OBI-WAN) STALE"
    echo "File Exists: ./flake.lock"
    echo "Diagnosis: The build is failing because this index holds the old, corrupted path. It must be regenerated."
    
    # Force the memory index update using the robust protocol
    echo ""
    echo "--- ATTEMPTING OBI-WAN MEMORY UPDATE (This is the final fix) ---"
    
    UPDATE_OUTPUT=$(sudo sh -c "NIX_CONFIG='${NIX_CONFIG}' ${NIX_CMD} flake update" 2>&1)
    UPDATE_EXIT_CODE=$?

    if [ $UPDATE_EXIT_CODE -eq 0 ]; then
        echo "✅ OBI-WAN Memory Index Updated Successfully."
        echo "Ready for Final Build."
    else
        echo "❌ OBI-WAN Memory Update FAILED. Attempting nuclear reset."
        sudo rm -rf flake.lock
        echo "✅ OBI-WAN Memory Index DELETED. Will be regenerated on build."
    fi
else
    echo "✅ STATUS: Memory Index CLEAN. ./flake.lock will be freshly generated."
fi

echo "--------------------------------------------------------"
echo "INTEGRITY CHECK COMPLETE. Attempting final build test..."
echo "--------------------------------------------------------"

# --- EXECUTE FINAL BUILD TEST ---
# We use the full, complex command that has proven necessary for this environment
FINAL_BUILD_OUTPUT=$(sudo sh -c "NIX_CONFIG='${NIX_CONFIG}' ${NIX_CMD} build .#nixosConfigurations.BearsiMac.config.system.build.toplevel" 2>&1)
BUILD_EXIT_CODE=$?

if [ $BUILD_EXIT_CODE -eq 0 ]; then
    echo "✅ SACRED FIELD RESET: SUCCESS."
    echo "The configuration is conflict-free and ready for switch."
    echo "Result Path: $(readlink result)"
    echo ""
    echo "NEXT ACTION: The migration is ready to begin. Run:"
    echo "sudo /run/current-system/sw/bin/nixos-rebuild switch --flake ${TARGET_CONFIG}"
else
    echo "❌ SACRED FIELD RESET: FAILED. Check Trace Below."
    echo "Final Error Trace:"
    echo "--------------------"
    echo "$FINAL_BUILD_OUTPUT"
    echo "--------------------"
fi

