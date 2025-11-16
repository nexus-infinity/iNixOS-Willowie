#!/usr/bin/env bash
# Demo script for Ajna observability service

echo "🔮 AJNA OBSERVABILITY DEMO"
echo "=========================="
echo ""

echo "Testing Ajna health endpoint..."
echo ""

if curl -s -f http://localhost:6001/health > /dev/null 2>&1; then
    echo "✓ Ajna is responding!"
    echo ""
    echo "Health check response:"
    curl -s http://localhost:6001/health | jq '.'
    echo ""
    echo "Metrics endpoint:"
    curl -s http://localhost:6001/metrics | head -20
else
    echo "⚠ Ajna service not responding"
    echo "Make sure the system has been switched with: sudo nixos-rebuild switch --flake .#willowie"
fi

echo ""
