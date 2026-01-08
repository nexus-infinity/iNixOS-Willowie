#!/usr/bin/env bash
# =============================================================================
# Validate All DNA Blueprints
# =============================================================================
# Runs validation on all 9 DNA blueprint files.
#
# Usage: ./validate_all_dna.sh
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VALIDATOR="$REPO_ROOT/tools/validate_dna_blueprint.py"
BLUEPRINTS_DIR="$REPO_ROOT/config/dna_blueprints"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}SOMA DNA Blueprint Validator${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}ERROR: python3 not found${NC}"
    exit 1
fi

# Check if validator exists
if [ ! -f "$VALIDATOR" ]; then
    echo -e "${RED}ERROR: Validator not found at $VALIDATOR${NC}"
    exit 1
fi

# Check if blueprints directory exists
if [ ! -d "$BLUEPRINTS_DIR" ]; then
    echo -e "${RED}ERROR: Blueprints directory not found at $BLUEPRINTS_DIR${NC}"
    exit 1
fi

echo "Validator: $VALIDATOR"
echo "Blueprints: $BLUEPRINTS_DIR"
echo ""

# Make validator executable
chmod +x "$VALIDATOR"

# Run validator
echo -e "${BLUE}Running validation...${NC}"
echo ""

if python3 "$VALIDATOR" --all; then
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}✓ All DNA blueprints are valid!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${GREEN}Ubuntu principle verified in all 9 chakras:${NC}"
    echo -e "${GREEN}'I am because we are'${NC}"
    exit 0
else
    echo ""
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}✗ Validation failed${NC}"
    echo -e "${RED}========================================${NC}"
    echo ""
    echo -e "${YELLOW}Please fix the errors above and try again${NC}"
    exit 1
fi
