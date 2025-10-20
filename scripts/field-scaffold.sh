#!/usr/bin/env bash
set -euo pipefail

# FIELD Chakra Scaffold Script
# Helper to create new chakra module directories with template structure

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
FIELD_DIR="$REPO_ROOT/FIELD"
TEMPLATE_PATH="$FIELD_DIR/chakra/template/module.nix"

usage() {
  cat <<EOF
Usage: $0 <chakra-name> [options]

Create a new FIELD chakra module from template.

Arguments:
  chakra-name       Name of the chakra (e.g., svadhisthana, manipura)

Options:
  --frequency HZ    Set default vibrational frequency (default: 256)
  --prime NUM       Set prime number for chakra identity (default: 2)
  --geometric PAT   Set geometric anchor pattern (default: cube)
  --focus PURPOSE   Set service focus description (default: chakra_purpose)
  --help           Show this help message

Examples:
  $0 svadhisthana --frequency 417 --prime 3 --geometric vesica_piscis --focus creative_flow
  $0 manipura --frequency 528 --prime 5 --geometric pentagram --focus power_transformation

EOF
}

# Default values
FREQUENCY=256
PRIME=2
GEOMETRIC="cube"
FOCUS="chakra_purpose"

# Parse arguments
if [ $# -eq 0 ]; then
  echo "Error: chakra-name is required"
  usage
  exit 1
fi

# Check for help first
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  usage
  exit 0
fi

CHAKRA_NAME="$1"
shift

while [ $# -gt 0 ]; do
  case "$1" in
    --frequency)
      FREQUENCY="$2"
      shift 2
      ;;
    --prime)
      PRIME="$2"
      shift 2
      ;;
    --geometric)
      GEOMETRIC="$2"
      shift 2
      ;;
    --focus)
      FOCUS="$2"
      shift 2
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

# Validate chakra name
if [[ ! "$CHAKRA_NAME" =~ ^[a-z_]+$ ]]; then
  echo "Error: Chakra name must contain only lowercase letters and underscores"
  exit 1
fi

CHAKRA_DIR="$FIELD_DIR/chakra/$CHAKRA_NAME"

# Check if chakra directory already exists
if [ -d "$CHAKRA_DIR" ]; then
  echo "Error: Chakra directory already exists: $CHAKRA_DIR"
  exit 1
fi

# Check if template exists
if [ ! -f "$TEMPLATE_PATH" ]; then
  echo "Error: Template not found: $TEMPLATE_PATH"
  exit 1
fi

# Create chakra directory
echo "Creating chakra directory: $CHAKRA_DIR"
mkdir -p "$CHAKRA_DIR"

# Create module.nix from template
echo "Generating module.nix from template..."
MODULE_PATH="$CHAKRA_DIR/module.nix"

# Read template and substitute placeholders
sed -e "s/TEMPLATE_NAME/$CHAKRA_NAME/g" \
    -e "s/GEOMETRIC_PATTERN/$GEOMETRIC/g" \
    -e "s/CHAKRA_PURPOSE/$FOCUS/g" \
    -e "s/default = 256;/default = $FREQUENCY;/" \
    "$TEMPLATE_PATH" > "$MODULE_PATH"

echo "Created: $MODULE_PATH"

# Create basic README for the chakra
README_PATH="$CHAKRA_DIR/README.md"
cat > "$README_PATH" <<EOF
# $CHAKRA_NAME Chakra Module

## Configuration

- **Frequency**: ${FREQUENCY}Hz
- **Prime**: $PRIME
- **Geometric Anchor**: $GEOMETRIC
- **Service Focus**: $FOCUS

## Usage

Enable this chakra in your NixOS configuration:

\`\`\`nix
{
  field.chakra.enable = true;
  field.chakra.$CHAKRA_NAME = {
    enable = true;
    vibrationalFrequency = $FREQUENCY;
    geometricAnchor = "$GEOMETRIC";
    serviceFocus = "$FOCUS";
  };
}
\`\`\`

## Logs

Chakra activation logs are written to:
\`/var/log/iNixos-Hive/chakra-$CHAKRA_NAME.log\`

## Customization

Edit \`module.nix\` to customize options, systemd services, and chakra-specific behavior.

## References

- [docs/chakras.md](../../../docs/chakras.md) - Chakra ecosystem overview
- [FIELD/chakra/template/module.nix](../template/module.nix) - Template source
EOF

echo "Created: $README_PATH"

# Update FIELD/chakra/default.nix to include new chakra
DEFAULT_NIX="$FIELD_DIR/chakra/default.nix"
if [ -f "$DEFAULT_NIX" ]; then
  # Check if chakra is already imported
  if grep -q "./$CHAKRA_NAME/module.nix" "$DEFAULT_NIX"; then
    echo "Warning: $CHAKRA_NAME already imported in $DEFAULT_NIX"
  else
    echo "Adding import to $DEFAULT_NIX..."
    # Add commented import line after the muladhara import
    sed -i "/\.\/muladhara\/module\.nix/a\\    # ./$CHAKRA_NAME/module.nix" "$DEFAULT_NIX"
    echo "Note: Import line added as comment. Uncomment to activate."
  fi
fi

# Add entry to chakra_ecosystem.csv
CSV_PATH="$FIELD_DIR/chakra/chakra_ecosystem.csv"
if [ -f "$CSV_PATH" ]; then
  # Check if entry already exists
  if grep -q "^$CHAKRA_NAME," "$CSV_PATH"; then
    echo "Warning: $CHAKRA_NAME already exists in $CSV_PATH"
  else
    echo "Adding entry to $CSV_PATH..."
    echo "$CHAKRA_NAME,$FOCUS,/$CHAKRA_NAME/sphere/state.py,Manage $CHAKRA_NAME chakra focus: $FOCUS" >> "$CSV_PATH"
  fi
fi

# Create sphere directory structure
SPHERE_DIR="$CHAKRA_DIR/sphere"
mkdir -p "$SPHERE_DIR"

cat > "$SPHERE_DIR/state.py" <<EOF
# $CHAKRA_NAME Chakra Sphere State
# Living sphere quantum state for $CHAKRA_NAME ecosystem

class ${CHAKRA_NAME^}Sphere:
    """
    Quantum state management for $CHAKRA_NAME chakra.
    
    Frequency: ${FREQUENCY}Hz
    Prime: $PRIME
    Geometric Anchor: $GEOMETRIC
    Focus: $FOCUS
    """
    
    def __init__(self):
        self.frequency = $FREQUENCY
        self.prime = $PRIME
        self.geometric_anchor = "$GEOMETRIC"
        self.focus = "$FOCUS"
        self.active = False
        self.resonance = 0.0
    
    def activate(self):
        """Activate the chakra sphere."""
        self.active = True
        print(f"[$CHAKRA_NAME] Activated: {self.focus}")
    
    def harmonize(self, target_frequency):
        """Harmonize with target frequency."""
        delta = abs(target_frequency - self.frequency)
        self.resonance = max(0.0, 1.0 - (delta / self.frequency))
        return self.resonance
    
    def pulse(self):
        """Generate pulse signature."""
        return {
            "chakra": "$CHAKRA_NAME",
            "frequency": self.frequency,
            "active": self.active,
            "resonance": self.resonance,
            "anchor": self.geometric_anchor
        }

if __name__ == "__main__":
    sphere = ${CHAKRA_NAME^}Sphere()
    sphere.activate()
    print(sphere.pulse())
EOF

echo "Created: $SPHERE_DIR/state.py"

# Summary
cat <<EOF

✨ Chakra scaffolding complete!

Created:
  - $MODULE_PATH
  - $README_PATH
  - $SPHERE_DIR/state.py

Next steps:
  1. Review and customize $MODULE_PATH
  2. Uncomment the import in $DEFAULT_NIX
  3. Add to docs/chakras.md with full details
  4. Test activation in isolated environment
  5. Commit changes to version control

To test:
  sudo nixos-rebuild build --flake .#BearsiMac

EOF
