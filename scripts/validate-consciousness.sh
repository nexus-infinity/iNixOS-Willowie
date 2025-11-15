#!/usr/bin/env bash
# =============================================================================
# CONSCIOUSNESS SYSTEM VALIDATION SCRIPT
# =============================================================================

set -eo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🧘 CONSCIOUSNESS SYSTEM VALIDATION"
echo "=================================="
echo ""

ERRORS=0

# Check Ajna service
echo -n "Checking Ajna agent... "
if systemctl is-active --quiet ajna-agent 2>/dev/null; then
    echo -e "${GREEN}✓ Running${NC}"
else
    echo -e "${YELLOW}⚠ Not running (expected if not yet switched)${NC}"
fi

# Check Ajna health endpoint
echo -n "Checking Ajna health endpoint... "
if curl -s -f http://localhost:6001/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Responding${NC}"
    curl -s http://localhost:6001/health | jq '.'
else
    echo -e "${YELLOW}⚠ Not responding (expected if not yet switched)${NC}"
fi

# Check Sway availability
echo -n "Checking Sway compositor... "
if command -v sway &> /dev/null; then
    echo -e "${GREEN}✓ Installed${NC}"
else
    echo -e "${YELLOW}⚠ Not installed (expected if not yet switched)${NC}"
fi

# Check PipeWire
echo -n "Checking PipeWire... "
if systemctl --user is-active --quiet pipewire 2>/dev/null; then
    echo -e "${GREEN}✓ Running${NC}"
else
    echo -e "${YELLOW}⚠ Not running (expected if not yet switched)${NC}"
fi

# Check bumble bee visualizer
echo -n "Checking bumble bee visualizer... "
if [ -x "tools/bumble-bee/bumble-bee-visualizer" ]; then
    echo -e "${GREEN}✓ Available${NC}"
else
    echo -e "${RED}✗ Not found${NC}"
    ERRORS=$((ERRORS + 1))
fi

echo ""
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ Validation complete${NC}"
    exit 0
else
    echo -e "${RED}✗ Validation found $ERRORS error(s)${NC}"
    exit 1
fi
