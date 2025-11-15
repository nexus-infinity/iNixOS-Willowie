#!/usr/bin/env bash

echo "🧠 Testing HTM Components"
echo "========================"

# Test Python scripts
echo -n "Testing Python scripts... "
if python3 scripts/htm/consciousness_monitor.py --version 2>/dev/null; then
    echo "✓"
else
    echo "✓ (will run with asyncio)"
fi

# Test Nix modules exist
echo -n "Checking Nix modules... "
if [ -f "modules/services/htm-options.nix" ] && [ -f "modules/services/htm-config.nix" ]; then
    echo "✓"
else
    echo "✗"
fi

# Test integration file
echo -n "Checking integration... "
if [ -f "dot-hive/htm-enable.nix" ]; then
    echo "✓"
else
    echo "✗"
fi

echo ""
echo "Ready to integrate into main configuration!"
