#!/usr/bin/env bash

# ====================================================================
# NixOS Configuration Validator
# Role: Checks configuration structure, syntax, and known issues
#       before attempting nixos-rebuild.
# Run this script inside the chroot environment from /etc/nixos.
# ====================================================================

set -uo pipefail # Error on unset variables and command failures

# --- Configuration ---
CONFIG_DIR="/etc/nixos"
FLAKE_FILE="flake.nix"
DOT_HIVE_MODULE="dot-hive/default.nix" # Note: Renamed from flake.nix
SACRED_GEOMETRY_MODULE="sacred_geometry/metatron_cube_translator.nix"
HARDWARE_CONFIG="hardware-configuration.nix"
FLAKE_LOCK="flake.lock"

# Expected UUIDs (from previous logs)
EXPECTED_ROOT_UUID="b3ef5552-af61-4689-9cc0-9d9cace03d4e"
EXPECTED_BOOT_UUID="B907-FEC9"
EXPECTED_HOME_UUID="b4e4d862-2b5c-45c9-b944-a9796f9d1740" # Double-check this matches your hardware-config file

# --- Colors for Output ---
COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[0;31m'
COLOR_YELLOW='\033[0;33m'
COLOR_NC='\033[0m' # No Color

# --- Helper Functions ---
print_check() {
    local message="$1"
    echo -e " CHECK: ${message}"
}

print_success() {
    local message="$1"
    echo -e " ${COLOR_GREEN}✓ OK:${COLOR_NC}    ${message}"
}

print_error() {
    local message="$1"
    echo -e " ${COLOR_RED}✗ ERROR:${COLOR_NC} ${message}"
    HAS_ERRORS=1
}

print_warning() {
    local message="$1"
    echo -e " ${COLOR_YELLOW}⚠ WARN:${COLOR_NC}  ${message}"
}

# --- Main Script ---
HAS_ERRORS=0
echo "========================================================"
echo " NIXOS CONFIGURATION VALIDATOR"
echo "========================================================"

# --- Check 1: Current Directory ---
print_check "Running from the correct directory (${CONFIG_DIR})"
if [[ "$(pwd)" != "${CONFIG_DIR}" ]]; then
    print_error "Script must be run from ${CONFIG_DIR}. Current directory is $(pwd)."
    exit 1
else
    print_success "Running in ${CONFIG_DIR}."
fi
echo "--------------------------------------------------------"

# --- Check 2: Essential File Existence ---
print_check "Essential configuration files exist"
FILES_OK=1
for f in "$FLAKE_FILE" "$DOT_HIVE_MODULE" "$SACRED_GEOMETRY_MODULE" "$HARDWARE_CONFIG"; do
    if [[ ! -f "$f" ]]; then
        print_error "Essential file missing: $f"
        FILES_OK=0
    fi
done
# Check that the chakras directory exists, as it's critical for the refactored paths
if [[ ! -d "chakras" ]]; then
    print_error "Essential directory missing: chakras"
    FILES_OK=0
fi
if [[ "$FILES_OK" -eq 1 ]]; then
    print_success "All essential files/directories found."
else
    print_error "Cannot proceed without essential files/directories."
    exit 1
fi
echo "--------------------------------------------------------"

# --- Check 3: dot-hive/default.nix Structure (Post-Refactor) ---
print_check "Structure of ${DOT_HIVE_MODULE} (Aggregator Module)"
STRUCTURE_OK=1
# 3a: No inputs block
if grep -q "inputs = {" "$DOT_HIVE_MODULE"; then
    print_error "${DOT_HIVE_MODULE} should NOT contain an 'inputs = {' block after refactoring."
    STRUCTURE_OK=0
fi
# 3b: Outputs line includes specialArgs
if ! grep -q "outputs = { self, nixpkgs, specialArgs }:" "$DOT_HIVE_MODULE"; then
    print_error "${DOT_HIVE_MODULE} 'outputs' line is incorrect. Should be 'outputs = { self, nixpkgs, specialArgs }:'"
    STRUCTURE_OK=0
fi
# 3c: Module arguments include specialArgs
# Updated grep to be more flexible with spacing around commas/ellipsis
if ! grep -q "nixosModules\.default = { *config, *pkgs, *lib, *specialArgs, *\.\.\. *} *:" "$DOT_HIVE_MODULE"; then
     # Check for older style without specialArgs first
     if grep -q "nixosModules\.default = { *config, *pkgs, *lib, *\.\.\. *} *:" "$DOT_HIVE_MODULE"; then
        print_error "${DOT_HIVE_MODULE} module arguments line is missing 'specialArgs'. Should be 'nixosModules.default = { config, pkgs, lib, specialArgs, ... }:'"
        STRUCTURE_OK=0
     else # If neither matches, it's definitely wrong
        print_error "${DOT_HIVE_MODULE} module arguments line seems incorrect. Expected 'nixosModules.default = { config, pkgs, lib, specialArgs, ... }:'"
        STRUCTURE_OK=0
     fi
fi

# 3d: Imports use specialArgs, NOT ../
# Updated grep to look specifically for the start of the import path
if grep -Eq 'imports = \[' "$DOT_HIVE_MODULE" && grep -Eq '^\s*\.\.\/(sacred_geometry|chakras)' "$DOT_HIVE_MODULE"; then
    print_error "${DOT_HIVE_MODULE} still uses forbidden '../' paths at the start of its 'imports'. Should use '\${specialArgs.sacredGeometryPath}/...' and '\${specialArgs.chakrasPath}/...'."
    STRUCTURE_OK=0
fi
# Check if specialArgs paths ARE used
if ! grep -q '"${specialArgs.sacredGeometryPath}/metatron_cube_translator.nix"' "$DOT_HIVE_MODULE"; then
    print_error "${DOT_HIVE_MODULE} does not seem to use '\${specialArgs.sacredGeometryPath}' for import."
    STRUCTURE_OK=0
fi
if ! grep -q '"${specialArgs.chakrasPath}/muladhara"' "$DOT_HIVE_MODULE"; then # Check at least one chakra path
    print_error "${DOT_HIVE_MODULE} does not seem to use '\${specialArgs.chakrasPath}' for imports."
    STRUCTURE_OK=0
fi

if [[ "$STRUCTURE_OK" -eq 1 ]]; then
    print_success "${DOT_HIVE_MODULE} structure appears correct for refactored import."
else
    print_error "The structure of ${DOT_HIVE_MODULE} does not match the required refactoring. This is the likely cause of the 'No such file or directory' build error."
fi
echo "--------------------------------------------------------"

# --- Check 4: flake.nix Structure (Post-Refactor) ---
print_check "Structure of ${FLAKE_FILE} (Main Flake)"
FLAKE_STRUCTURE_OK=1
# 4a: dot-hive removed from inputs
# Updated grep to be more specific to url/path definition
if grep -Eq "^\s*dot-hive\s*\." "$FLAKE_FILE" | grep -Eq "\s*(url|path)\s*="; then
    print_error "${FLAKE_FILE} should NOT define 'dot-hive' in its 'inputs' block after refactoring."
    FLAKE_STRUCTURE_OK=0
fi
# 4b: dot-hive removed from outputs arguments
if grep -q "outputs = { *self, *nixpkgs, *dot-hive *} *:" "$FLAKE_FILE"; then
    print_error "${FLAKE_FILE} 'outputs' line should NOT include 'dot-hive' after refactoring. Should be 'outputs = { self, nixpkgs }:'."
    FLAKE_STRUCTURE_OK=0
fi
# 4c: specialArgs includes paths
# Updated grep for flexibility
if ! grep -q "specialArgs = {" "$FLAKE_FILE" || ! grep -q "sacredGeometryPath = \./sacred_geometry;" "$FLAKE_FILE" || ! grep -q "chakrasPath = \./chakras;" "$FLAKE_FILE"; then
    print_error "${FLAKE_FILE} is missing 'sacredGeometryPath = ./sacred_geometry;' or 'chakrasPath = ./chakras;' definition within 'specialArgs' for the nixosSystem."
    FLAKE_STRUCTURE_OK=0
fi
# 4d: modules list imports dot-hive/default.nix directly
if grep -q "dot-hive\.nixosModules\.default" "$FLAKE_FILE"; then
     print_error "${FLAKE_FILE} should NOT import 'dot-hive.nixosModules.default' in the 'modules' list."
     FLAKE_STRUCTURE_OK=0
fi
# Updated grep for flexibility
if ! grep -q "\./dot-hive/default\.nix" "$FLAKE_FILE"; then
    print_error "${FLAKE_FILE} should import './dot-hive/default.nix' directly in the 'modules' list."
    FLAKE_STRUCTURE_OK=0
fi
if [[ "$FLAKE_STRUCTURE_OK" -eq 1 ]]; then
    print_success "${FLAKE_FILE} structure appears correct for refactored import."
else
    print_error "The structure of ${FLAKE_FILE} does not match the required refactoring."
fi
echo "--------------------------------------------------------"

# --- Check 5: hardware-configuration.nix UUIDs ---
print_check "UUIDs in ${HARDWARE_CONFIG}"
UUID_OK=1
# Check Root UUID
if ! grep -q "device = \"/dev/disk/by-uuid/${EXPECTED_ROOT_UUID}\";" "$HARDWARE_CONFIG"; then
    print_error "Root filesystem UUID in ${HARDWARE_CONFIG} does not match expected (${EXPECTED_ROOT_UUID})."
    UUID_OK=0
fi
# Check Boot UUID
if ! grep -q "device = \"/dev/disk/by-uuid/${EXPECTED_BOOT_UUID}\";" "$HARDWARE_CONFIG"; then
    print_error "Boot filesystem UUID in ${HARDWARE_CONFIG} does not match expected (${EXPECTED_BOOT_UUID})."
    UUID_OK=0
fi
# Check Home UUID
if ! grep -q "device = \"/dev/disk/by-uuid/${EXPECTED_HOME_UUID}\";" "$HARDWARE_CONFIG"; then
    print_warning "Home filesystem UUID in ${HARDWARE_CONFIG} does not match expected (${EXPECTED_HOME_UUID}). Double-check blkid output and the file content."
    # Not treating this as a fatal error for now, but it should be correct.
fi
if [[ "$UUID_OK" -eq 1 ]]; then
    print_success "Root and Boot UUIDs seem correct."
fi
echo "--------------------------------------------------------"

# --- Check 6: flake.lock ---
print_check "Status of ${FLAKE_LOCK}"
if [[ -f "$FLAKE_LOCK" ]]; then
    print_warning "Existing ${FLAKE_LOCK} found. Recommend removing it ('rm ${FLAKE_LOCK}') before the final build to ensure inputs are fresh, especially after refactoring."
else
    print_success "${FLAKE_LOCK} not found. A new one will be generated."
fi
echo "--------------------------------------------------------"

# --- Check 7: Nix Flake Check (Syntax and Basic Evaluation) ---
print_check "Running 'nix flake check' for syntax and evaluation errors"
# Use --impure as the check itself might need to read local paths depending on Nix version/config
# Capture output to check for specific errors if needed
check_output=$(nix flake check --impure . 2>&1)
check_status=$?

if [[ "$check_status" -eq 0 ]]; then
    print_success "'nix flake check' completed without errors."
else
    print_error "'nix flake check' failed. See output below for details. Fix syntax or evaluation errors before proceeding."
    echo "--- nix flake check output ---"
    echo "$check_output"
    echo "------------------------------"
    # Exiting here as build will definitely fail
    exit 1
fi
echo "--------------------------------------------------------"


# --- Final Summary ---
echo "========================================================"
echo " VALIDATION SUMMARY"
echo "========================================================"
if [[ "$HAS_ERRORS" -eq 0 ]]; then
    print_success "All critical checks passed."
    print_warning "Remember to double-check the Home UUID in ${HARDWARE_CONFIG} if warned above."
    if [[ -f "$FLAKE_LOCK" ]]; then
      print_warning "Consider running 'rm ${FLAKE_LOCK}' before the build."
    fi
    echo ""
    echo "You can now attempt the build:"
    echo "1. Ensure TMPDIR is set:"
    echo "   export TMPDIR=/home/nixos-build-temp"
    echo "2. Run the rebuild command:"
    echo "   nixos-rebuild switch --flake .#BearsiMac --impure"
    echo ""
else
    print_error "Validation failed. Please address the ERROR messages above before attempting to build."
    exit 1
fi

exit 0

