#!/usr/bin/env bash
set -euo pipefail

FILE="/etc/nixos/tools/field/field-scan-2019imac-v5.sh"
BACKUP="${FILE}.bak.$(date +%Y%m%d-%H%M%S)"
TMP="${FILE}.tmp.$$"

if [ ! -f "$FILE" ]; then
  echo "Error: $FILE not found"
  exit 1
fi

echo "Backing up original to: $BACKUP"
cp -a "$FILE" "$BACKUP"

# Use awk to rewrite only the problematic sed substitution lines.
# We replace the lines that try to inline multiline variables into sed s|...|...|g
# for the known placeholders: DUPLICATE_FS_PLACEHOLDER, TRANSIENT_DEV_PLACEHOLDER,
# BOOT_DUP_PLACEHOLDER, FR ICTION_PLACEHOLDER (FRICTION_PLACEHOLDER).
awk '
{
  # If line contains sed substitution for duplicate-fs, replace with safe block
  if ($0 ~ /s\\|DUPLICATE_FS_PLACEHOLDER\\|/) {
    print "if [ -n \"${DUPLICATE_FS}\" ]; then"
    print "  printf \"%s\\n\" \"${DUPLICATE_FS}\" | sed -e \"/DUPLICATE_FS_PLACEHOLDER/{"
    print "    r /dev/stdin"
    print "    d"
    print "  }\" -i \"${SCAN_DIR}/report.md\""
    print "else"
    print "  sed -i \"s|DUPLICATE_FS_PLACEHOLDER|✓ No duplicate filesystem declarations|g\" \"${SCAN_DIR}/report.md\""
    print "fi"
    next
  }

  # Transient devices
  if ($0 ~ /s\\|TRANSIENT_DEV_PLACEHOLDER\\|/) {
    print "if [ -n \"${TRANSIENT_DEV}\" ]; then"
    print "  printf \"%s\\n\" \"${TRANSIENT_DEV}\" | sed -e \"/TRANSIENT_DEV_PLACEHOLDER/{"
    print "    r /dev/stdin"
    print "    d"
    print "  }\" -i \"${SCAN_DIR}/report.md\""
    print "else"
    print "  sed -i \"s|TRANSIENT_DEV_PLACEHOLDER|✓ No transient devices detected|g\" \"${SCAN_DIR}/report.md\""
    print "fi"
    next
  }

  # Boot duplicates
  if ($0 ~ /s\\|BOOT_DUP_PLACEHOLDER\\|/) {
    print "if [ -n \"${BOOT_DUP}\" ]; then"
    print "  printf \"%s\\n\" \"${BOOT_DUP}\" | sed -e \"/BOOT_DUP_PLACEHOLDER/{"
    print "    r /dev/stdin"
    print "    d"
    print "  }\" -i \"${SCAN_DIR}/report.md\""
    print "else"
    print "  sed -i \"s|BOOT_DUP_PLACEHOLDER|✓ No duplicate boot loader options|g\" \"${SCAN_DIR}/report.md\""
    print "fi"
    next
  }

  # Friction report (multiline)
  if ($0 ~ /s\\|FRICTION_PLACEHOLDER\\|/) {
    print "if [ -z \"${FRICTION_REPORT}\" ]; then"
    print "  FRICTION_REPORT=\"✓ **No friction detected** - Configuration appears clean\""
    print "fi"
    print "printf \"%s\\n\" \"${FRICTION_REPORT}\" | sed -e \"/FRICTION_PLACEHOLDER/{"
    print "  r /dev/stdin"
    print "  d"
    print "}\" -i \"${SCAN_DIR}/report.md\""
    next
  }

  # Default: print the original line unchanged
  print $0
}
' "$FILE" > "$TMP"

# Validate created file at least exists and is non-empty
if [ -s "$TMP" ]; then
  mv "$TMP" "$FILE"
  chmod +x "$FILE"
  echo "Patched $FILE successfully. Original backed up at $BACKUP"
else
  echo "Patched file is empty or missing; restoring backup."
  rm -f "$TMP"
  cp -a "$BACKUP" "$FILE"
  exit 1
fi

echo "You can now re-run the scanner:"
echo "  sudo $FILE"
