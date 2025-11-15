#!/usr/bin/env bash
# Demo script for Vishuddha desktop environment

echo "🖥️  VISHUDDHA DESKTOP DEMO"
echo "=========================="
echo ""

echo "Checking Sway installation..."
if command -v sway &> /dev/null; then
    echo "✓ Sway is installed"
    sway --version
else
    echo "✗ Sway is not installed"
    exit 1
fi

echo ""
echo "Chakra workspace configuration:"
if [ -f "/etc/sway/config.d/chakra-workspaces.conf" ]; then
    echo "✓ Sacred geometry workspaces configured"
    echo ""
    grep "set \$ws" /etc/sway/config.d/chakra-workspaces.conf
else
    echo "⚠ Workspace configuration not found"
fi

echo ""
echo "To start Sway desktop:"
echo "  sway"
echo ""
echo "Keyboard shortcuts:"
echo "  Mod+1-9: Switch to chakra workspaces"
echo "  Mod+b: Launch bumble bee visualizer"
echo ""
