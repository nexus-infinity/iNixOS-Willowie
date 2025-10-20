#!/usr/bin/env bash
set -euo pipefail

# FIELD Diagnostic Capture Script
# Captures mountinfo, findmnt, dmesg, and system state to /var/log/iNixos-Hive/diag-*

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_DIR="/var/log/iNixos-Hive"
DIAG_PREFIX="diag-$TIMESTAMP"

usage() {
  cat <<EOF
Usage: $0 [options]

Capture system diagnostic information for FIELD troubleshooting.

Options:
  --output-dir DIR  Specify output directory (default: $LOG_DIR)
  --prefix PREFIX   Set filename prefix (default: diag-TIMESTAMP)
  --verbose         Show verbose output
  --help           Show this help message

Captures:
  - /proc/self/mountinfo (mount namespace information)
  - findmnt output (filesystem tree)
  - dmesg (kernel ring buffer)
  - systemctl status (systemd state)
  - FIELD chakra service status
  - Network configuration
  - Disk usage

Output files:
  $LOG_DIR/$DIAG_PREFIX-mountinfo.txt
  $LOG_DIR/$DIAG_PREFIX-findmnt.txt
  $LOG_DIR/$DIAG_PREFIX-dmesg.txt
  $LOG_DIR/$DIAG_PREFIX-systemd.txt
  $LOG_DIR/$DIAG_PREFIX-chakra.txt
  $LOG_DIR/$DIAG_PREFIX-network.txt
  $LOG_DIR/$DIAG_PREFIX-disk.txt
  $LOG_DIR/$DIAG_PREFIX-summary.txt

Examples:
  sudo $0
  sudo $0 --output-dir /tmp/diagnostics --verbose

EOF
}

VERBOSE=false

# Parse arguments
while [ $# -gt 0 ]; do
  case "$1" in
    --output-dir)
      LOG_DIR="$2"
      shift 2
      ;;
    --prefix)
      DIAG_PREFIX="$2"
      shift 2
      ;;
    --verbose)
      VERBOSE=true
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Error: Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

log() {
  if [ "$VERBOSE" = true ]; then
    echo "[diag-capture] $*"
  fi
}

# Check for root/sudo
if [ "$EUID" -ne 0 ]; then
  echo "Warning: Running without root privileges. Some diagnostics may be incomplete."
  echo "Run with sudo for full diagnostic capture."
fi

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

log "Starting diagnostic capture..."
log "Output directory: $LOG_DIR"
log "Filename prefix: $DIAG_PREFIX"

# Capture mountinfo
log "Capturing mountinfo..."
MOUNTINFO_FILE="$LOG_DIR/$DIAG_PREFIX-mountinfo.txt"
{
  echo "=== /proc/self/mountinfo ==="
  echo "Timestamp: $(date -Iseconds)"
  echo ""
  cat /proc/self/mountinfo 2>/dev/null || echo "Error: Unable to read /proc/self/mountinfo"
} > "$MOUNTINFO_FILE"
log "Created: $MOUNTINFO_FILE"

# Capture findmnt
log "Capturing findmnt output..."
FINDMNT_FILE="$LOG_DIR/$DIAG_PREFIX-findmnt.txt"
{
  echo "=== findmnt (filesystem tree) ==="
  echo "Timestamp: $(date -Iseconds)"
  echo ""
  findmnt 2>/dev/null || echo "Error: findmnt command not available"
  echo ""
  echo "=== findmnt --json ==="
  findmnt --json 2>/dev/null || echo "Error: findmnt --json failed"
} > "$FINDMNT_FILE"
log "Created: $FINDMNT_FILE"

# Capture dmesg
log "Capturing dmesg..."
DMESG_FILE="$LOG_DIR/$DIAG_PREFIX-dmesg.txt"
{
  echo "=== dmesg (kernel ring buffer) ==="
  echo "Timestamp: $(date -Iseconds)"
  echo ""
  dmesg -T 2>/dev/null || dmesg 2>/dev/null || echo "Error: Unable to read dmesg (try with sudo)"
} > "$DMESG_FILE"
log "Created: $DMESG_FILE"

# Capture systemd status
log "Capturing systemd status..."
SYSTEMD_FILE="$LOG_DIR/$DIAG_PREFIX-systemd.txt"
{
  echo "=== systemctl status ==="
  echo "Timestamp: $(date -Iseconds)"
  echo ""
  systemctl status 2>/dev/null || echo "Error: systemctl status failed"
  echo ""
  echo "=== systemctl list-units --failed ==="
  systemctl list-units --failed 2>/dev/null || echo "Error: systemctl list-units failed"
  echo ""
  echo "=== systemctl list-units --type=service --state=running ==="
  systemctl list-units --type=service --state=running 2>/dev/null || echo "Error: systemctl list-units failed"
} > "$SYSTEMD_FILE"
log "Created: $SYSTEMD_FILE"

# Capture FIELD chakra service status
log "Capturing FIELD chakra status..."
CHAKRA_FILE="$LOG_DIR/$DIAG_PREFIX-chakra.txt"
{
  echo "=== FIELD Chakra Services ==="
  echo "Timestamp: $(date -Iseconds)"
  echo ""
  
  # List all chakra services
  echo "=== Chakra Services (by pattern *-chakra.service) ==="
  systemctl list-units '*-chakra.service' --all 2>/dev/null || echo "No chakra services found"
  echo ""
  
  # Check specific known chakras
  for chakra in muladhara svadhisthana manipura anahata vishuddha ajna sahasrara soma jnana; do
    SERVICE="${chakra}-chakra.service"
    if systemctl list-units --full --all | grep -q "$SERVICE"; then
      echo "=== $SERVICE ==="
      systemctl status "$SERVICE" 2>/dev/null || echo "Service exists but status unavailable"
      echo ""
    fi
  done
  
  # Check translator service
  echo "=== field-translator.service ==="
  systemctl status field-translator.service 2>/dev/null || echo "field-translator.service not found or inactive"
  echo ""
  
  # Check audit logs if accessible
  echo "=== FIELD Audit Logs ==="
  if [ -d "$LOG_DIR" ]; then
    ls -lh "$LOG_DIR"/chakra-*.log 2>/dev/null || echo "No chakra audit logs found"
    echo ""
    ls -lh "$LOG_DIR"/translator.log 2>/dev/null || echo "No translator logs found"
  fi
} > "$CHAKRA_FILE"
log "Created: $CHAKRA_FILE"

# Capture network configuration
log "Capturing network configuration..."
NETWORK_FILE="$LOG_DIR/$DIAG_PREFIX-network.txt"
{
  echo "=== Network Configuration ==="
  echo "Timestamp: $(date -Iseconds)"
  echo ""
  
  echo "=== ip addr ==="
  ip addr 2>/dev/null || echo "Error: ip command not available"
  echo ""
  
  echo "=== ip route ==="
  ip route 2>/dev/null || echo "Error: ip route failed"
  echo ""
  
  echo "=== /etc/resolv.conf ==="
  cat /etc/resolv.conf 2>/dev/null || echo "Error: Unable to read /etc/resolv.conf"
  echo ""
  
  echo "=== ss -tuln (listening sockets) ==="
  ss -tuln 2>/dev/null || netstat -tuln 2>/dev/null || echo "Error: Unable to list sockets"
} > "$NETWORK_FILE"
log "Created: $NETWORK_FILE"

# Capture disk usage
log "Capturing disk usage..."
DISK_FILE="$LOG_DIR/$DIAG_PREFIX-disk.txt"
{
  echo "=== Disk Usage ==="
  echo "Timestamp: $(date -Iseconds)"
  echo ""
  
  echo "=== df -h ==="
  df -h 2>/dev/null || echo "Error: df command failed"
  echo ""
  
  echo "=== Nix Store Usage ==="
  du -sh /nix/store 2>/dev/null || echo "Error: Unable to check /nix/store"
  echo ""
  
  echo "=== /var/log Usage ==="
  du -sh /var/log/* 2>/dev/null | sort -h || echo "Error: Unable to check /var/log"
  echo ""
  
  echo "=== $LOG_DIR Usage ==="
  du -sh "$LOG_DIR"/* 2>/dev/null | sort -h || echo "Log directory empty or inaccessible"
} > "$DISK_FILE"
log "Created: $DISK_FILE"

# Create summary
log "Creating summary..."
SUMMARY_FILE="$LOG_DIR/$DIAG_PREFIX-summary.txt"
{
  echo "=== FIELD Diagnostic Capture Summary ==="
  echo "Timestamp: $(date -Iseconds)"
  echo "Captured by: $(whoami)@$(hostname)"
  echo ""
  
  echo "Files created:"
  ls -lh "$LOG_DIR/$DIAG_PREFIX"-*.txt 2>/dev/null || echo "Error listing files"
  echo ""
  
  echo "=== Quick Health Check ==="
  echo ""
  
  echo "Failed systemd units:"
  systemctl list-units --failed --no-pager 2>/dev/null || echo "Unable to check"
  echo ""
  
  echo "Disk space:"
  df -h / /nix 2>/dev/null | grep -v "^Filesystem" || echo "Unable to check"
  echo ""
  
  echo "Active chakra services:"
  systemctl list-units '*-chakra.service' --state=active --no-pager 2>/dev/null || echo "None or unable to check"
  echo ""
  
  echo "Recent kernel messages (last 20 lines):"
  dmesg -T 2>/dev/null | tail -20 || echo "Unable to access dmesg"
} > "$SUMMARY_FILE"
log "Created: $SUMMARY_FILE"

# Final output
echo "✨ Diagnostic capture complete!"
echo ""
echo "Summary: $SUMMARY_FILE"
echo ""
echo "All diagnostic files:"
ls -lh "$LOG_DIR/$DIAG_PREFIX"-*.txt
echo ""
echo "To view summary:"
echo "  cat $SUMMARY_FILE"
echo ""
echo "To view specific diagnostic:"
echo "  cat $LOG_DIR/$DIAG_PREFIX-<type>.txt"
