#!/usr/bin/env bash
# field-pipeline.sh - End-to-end FIELD pipeline orchestrator
set -euo pipefail

# Configuration
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
SCANNER="${SCRIPT_DIR}/field-scan-2019imac-v5.sh"
REPORTER="${SCRIPT_DIR}/field-scan-report-v3.sh"
WEAVER="${SCRIPT_DIR}/field-weave.sh"
BLUEPRINT="/etc/nixos/field/blueprint.nix"
BLUEPRINT_TEMPLATE="${SCRIPT_DIR}/blueprint.nix"

# Options
OPEN_REPORTS=true
SERVE_PORT=""

show_usage() {
  cat <<EOF
Usage: $0 [--no-open] [--serve PORT]

Runs the complete FIELD pipeline:
  1. Baseline scan
  2. Report generation
  3. Blueprint verification
  4. Weave (regenerate config and rebuild)
  5. Post-scan
  6. Delta summary

Options:
  --no-open      Don't automatically open reports in browser
  --serve PORT   Serve reports on HTTP port after completion
  -h, --help     Show this help message

Examples:
  $0
  $0 --no-open
  $0 --serve 8080
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      show_usage
      exit 0
      ;;
    --no-open)
      OPEN_REPORTS=false
      shift
      ;;
    --serve)
      SERVE_PORT="$2"
      shift 2
      ;;
    *)
      echo "Error: Unknown argument '$1'" >&2
      show_usage
      exit 1
      ;;
  esac
done

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Error: This script must be run as root (use sudo)" >&2
  exit 1
fi

# Validate required scripts exist
for script in "$SCANNER" "$REPORTER" "$WEAVER"; do
  if [ ! -x "$script" ]; then
    echo "Error: Required script not found or not executable: $script" >&2
    exit 1
  fi
done

echo "╔════════════════════════════════════════════════════════════╗"
echo "║         FIELD Pipeline - Complete Workflow                 ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Stage 1: Baseline Scan
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Stage 1: Baseline Scan"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "Running baseline system scan..."
"$SCANNER"

BASELINE_SCAN=$(ls -td /var/log/FIELD-Scan-* | head -1)
echo ""
echo "✓ Baseline scan complete: $BASELINE_SCAN"
echo ""

# Stage 2: Report Generation
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Stage 2: Baseline Report"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

REPORT_ARGS=("$BASELINE_SCAN")
if [ "$OPEN_REPORTS" = true ]; then
  REPORT_ARGS+=("--open")
fi

"$REPORTER" "${REPORT_ARGS[@]}"
echo ""
echo "✓ Baseline report generated"
echo ""

# Stage 3: Blueprint Verification
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Stage 3: Blueprint Verification"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

BLUEPRINT_DIR=$(dirname "$BLUEPRINT")
if [ ! -d "$BLUEPRINT_DIR" ]; then
  echo "Creating blueprint directory: $BLUEPRINT_DIR"
  mkdir -p "$BLUEPRINT_DIR"
fi

if [ ! -f "$BLUEPRINT" ]; then
  echo "Blueprint not found. Creating from template..."
  if [ -f "$BLUEPRINT_TEMPLATE" ]; then
    cp "$BLUEPRINT_TEMPLATE" "$BLUEPRINT"
    echo "✓ Blueprint created: $BLUEPRINT"
    echo ""
    echo "⚠ IMPORTANT: Please review and edit the blueprint before proceeding:"
    echo "  - Fill in correct UUIDs for filesystems"
    echo "  - Set hostname and other system-specific values"
    echo "  - Configure boot loader preferences"
    echo ""
    echo "Edit with: sudo ${EDITOR:-nano} $BLUEPRINT"
    echo ""
    read -p "Press Enter after editing blueprint to continue, or Ctrl+C to abort..."
  else
    echo "⚠ WARNING: Blueprint template not found: $BLUEPRINT_TEMPLATE"
    echo "Creating minimal placeholder blueprint..."
    cat > "$BLUEPRINT" <<'EOF'
# FIELD Blueprint - Single source of truth for system configuration
{ config, lib, pkgs, ... }:

{
  networking.hostName = "iMac2019";
  
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  system.stateVersion = "23.11";
}
EOF
    echo "✓ Minimal blueprint created"
    echo "⚠ Please customize $BLUEPRINT for your system"
    echo ""
    read -p "Press Enter to continue, or Ctrl+C to abort..."
  fi
else
  echo "✓ Blueprint exists: $BLUEPRINT"
  
  # Quick syntax check
  if nix-instantiate --parse "$BLUEPRINT" &>/dev/null; then
    echo "✓ Blueprint syntax is valid"
  else
    echo "✗ ERROR: Blueprint has syntax errors"
    nix-instantiate --parse "$BLUEPRINT" 2>&1 | head -20
    echo ""
    echo "Please fix blueprint syntax before continuing"
    exit 1
  fi
fi
echo ""

# Stage 4: Weave (Apply)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Stage 4: Weave (Regenerate Config & Rebuild)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "About to run the weaver, which will:"
echo "  1. Mount clean Btrfs root"
echo "  2. Regenerate hardware-configuration.nix"
echo "  3. Sanitize configuration"
echo "  4. Run preflight validation"
echo "  5. Build NixOS configuration"
echo "  6. Switch to new configuration (with confirmation)"
echo "  7. Run post-scan"
echo ""
read -p "Continue with weave? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Pipeline aborted by user at weave stage"
  echo "You can run the weaver separately: sudo $WEAVER"
  exit 0
fi

"$WEAVER"
echo ""
echo "✓ Weave complete"
echo ""

# Stage 5: Post-Scan
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Stage 5: Post-Apply Scan"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Find the most recent scan (should be from weaver's post-scan)
POST_SCAN=$(ls -td /var/log/FIELD-Scan-* | head -1)

if [ "$POST_SCAN" = "$BASELINE_SCAN" ]; then
  echo "⚠ WARNING: No new scan found after weave"
  echo "This might indicate the post-scan in the weaver failed"
  echo "Running manual post-scan..."
  "$SCANNER"
  POST_SCAN=$(ls -td /var/log/FIELD-Scan-* | head -1)
fi

echo "Generating post-scan report..."
POST_REPORT_ARGS=("$POST_SCAN")
if [ "$OPEN_REPORTS" = true ]; then
  POST_REPORT_ARGS+=("--open")
fi

"$REPORTER" "${POST_REPORT_ARGS[@]}"
echo ""
echo "✓ Post-scan complete: $POST_SCAN"
echo ""

# Stage 6: Delta Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Stage 6: Delta Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "Comparing baseline vs. post-apply state..."
echo ""

# Compare mounts
echo "Mount Changes:"
echo "──────────────"
BASELINE_MOUNTS="${BASELINE_SCAN}/raw/mount.txt"
POST_MOUNTS="${POST_SCAN}/raw/mount.txt"

if [ -f "$BASELINE_MOUNTS" ] && [ -f "$POST_MOUNTS" ]; then
  MOUNT_DIFF=$(diff -u "$BASELINE_MOUNTS" "$POST_MOUNTS" || true)
  if [ -z "$MOUNT_DIFF" ]; then
    echo "✓ No mount changes"
  else
    echo "$MOUNT_DIFF" | grep "^[+-]" | grep -v "^[+-][+-][+-]" | head -20
  fi
else
  echo "⚠ Could not compare mounts (missing data)"
fi
echo ""

# Compare boot entries
echo "Boot Loader Changes:"
echo "────────────────────"
BASELINE_BOOT="${BASELINE_SCAN}/raw/efibootmgr.txt"
POST_BOOT="${POST_SCAN}/raw/efibootmgr.txt"

if [ -f "$BASELINE_BOOT" ] && [ -f "$POST_BOOT" ]; then
  BOOT_DIFF=$(diff -u "$BASELINE_BOOT" "$POST_BOOT" || true)
  if [ -z "$BOOT_DIFF" ]; then
    echo "✓ No boot loader changes"
  else
    echo "$BOOT_DIFF" | grep "^[+-]" | grep -v "^[+-][+-][+-]" | head -20
  fi
else
  echo "⚠ Could not compare boot entries (missing data)"
fi
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Pipeline Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Baseline scan:  $BASELINE_SCAN"
echo "Post-scan:      $POST_SCAN"
echo ""
echo "Reports:"
echo "  Baseline: ${BASELINE_SCAN}/report.html"
echo "  Post:     ${POST_SCAN}/report.html"
echo ""

# Serve reports if requested
if [ -n "$SERVE_PORT" ]; then
  echo "Starting HTTP server to serve reports..."
  echo ""
  echo "Access reports at:"
  echo "  Baseline: http://localhost:${SERVE_PORT}/baseline/report.html"
  echo "  Post:     http://localhost:${SERVE_PORT}/post/report.html"
  echo ""
  echo "Press Ctrl+C to stop server"
  echo ""
  
  # Create temporary directory structure for serving
  SERVE_DIR=$(mktemp -d)
  ln -s "$BASELINE_SCAN" "${SERVE_DIR}/baseline"
  ln -s "$POST_SCAN" "${SERVE_DIR}/post"
  
  cd "$SERVE_DIR"
  if command -v python3 &>/dev/null; then
    python3 -m http.server "$SERVE_PORT"
  elif command -v python &>/dev/null; then
    python -m SimpleHTTPServer "$SERVE_PORT"
  else
    echo "Error: Python not found, cannot start HTTP server" >&2
    rm -rf "$SERVE_DIR"
    exit 1
  fi
  
  rm -rf "$SERVE_DIR"
fi

echo "✓ FIELD pipeline completed successfully"
