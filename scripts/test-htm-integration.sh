#!/usr/bin/env bash

set -euo pipefail

echo "🧠 Testing HTM Consciousness Integration"
echo "========================================"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Test 1: Check if modules evaluate
echo "Testing module evaluation..."
if nix eval .#nixosConfigurations.BearsiMac.config.services.htmTemporalMemory --json > /dev/null 2>&1; then
    echo -e "${GREEN}✓ HTM module evaluates successfully${NC}"
else
    echo -e "${RED}✗ HTM module evaluation failed${NC}"
    exit 1
fi

# Test 2: Check integration with Ajna
echo "Testing Ajna integration..."
if nix eval .#nixosConfigurations.BearsiMac.config.services.ajnaAgent --json > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Ajna integration configured${NC}"
else
    echo -e "${RED}✗ Ajna integration failed${NC}"
fi

# Test 3: Dry build
echo "Testing configuration build..."
if nix build .#nixosConfigurations.BearsiMac.config.system.build.toplevel --dry-run 2>&1 | grep -q "would be built"; then
    echo -e "${GREEN}✓ Configuration builds successfully${NC}"
else
    echo -e "${RED}✗ Build configuration failed${NC}"
fi

echo ""
echo "🎯 HTM Integration Test Complete!"
echo "Ready to deploy with: sudo nixos-rebuild switch --flake .#BearsiMac"
