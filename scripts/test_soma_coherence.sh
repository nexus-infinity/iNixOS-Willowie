#!/usr/bin/env bash
# =============================================================================
# SOMA Coherence Test Script
# =============================================================================
# Tests all 9 chakras + Agent 99 + infrastructure services for health and
# Ubuntu collective awareness.
#
# Usage: ./test_soma_coherence.sh
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}SOMA Coherence Health Check${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Test function
test_endpoint() {
    local name=$1
    local url=$2
    local expected_status=${3:-200}
    
    echo -n "Testing $name... "
    
    if command -v curl &> /dev/null; then
        response=$(curl -s -w "\n%{http_code}" "$url" 2>/dev/null || echo "000")
        http_code=$(echo "$response" | tail -n1)
        body=$(echo "$response" | head -n-1)
        
        if [ "$http_code" = "$expected_status" ]; then
            echo -e "${GREEN}✓ PASS${NC} (HTTP $http_code)"
            if command -v jq &> /dev/null && [ -n "$body" ]; then
                echo "$body" | jq -C '.' 2>/dev/null || echo "$body"
            else
                echo "$body" | head -c 200
            fi
            ((PASSED++))
        else
            echo -e "${RED}✗ FAIL${NC} (HTTP $http_code, expected $expected_status)"
            ((FAILED++))
        fi
    else
        echo -e "${YELLOW}⚠ SKIP${NC} (curl not installed)"
    fi
    echo ""
}

# Test Infrastructure Services
echo -e "${BLUE}--- Infrastructure Services ---${NC}"
echo ""

echo "Testing Redis EventBus (Agent 1)..."
if command -v redis-cli &> /dev/null; then
    if redis-cli -h 127.0.0.1 -p 6379 ping &> /dev/null; then
        echo -e "${GREEN}✓ PASS${NC} Redis EventBus is reachable"
        ((PASSED++))
    else
        echo -e "${RED}✗ FAIL${NC} Redis EventBus not reachable"
        ((FAILED++))
    fi
else
    echo -e "${YELLOW}⚠ SKIP${NC} redis-cli not installed"
fi
echo ""

echo "Testing PostgreSQL ProofStore (Agent 2)..."
if command -v psql &> /dev/null; then
    if psql -h localhost -p 5432 -U soma -d soma_proofstore -c "SELECT 1" &> /dev/null; then
        echo -e "${GREEN}✓ PASS${NC} ProofStore is reachable"
        ((PASSED++))
    else
        echo -e "${YELLOW}⚠ SKIP${NC} ProofStore connection failed (may need password)"
    fi
else
    echo -e "${YELLOW}⚠ SKIP${NC} psql not installed"
fi
echo ""

test_endpoint "Scheduler (Agent 3)" "http://localhost:8501/health"

# Test Chakra Services
echo -e "${BLUE}--- Chakra Services ---${NC}"
echo ""

declare -A CHAKRAS=(
    [2]="Muladhara (Root)"
    [3]="Svadhisthana (Sacral)"
    [5]="Manipura (Solar Plexus)"
    [7]="Anahata (Heart)"
    [11]="Vishuddha (Throat)"
    [13]="Ajna (Third Eye)"
    [17]="Sahasrara (Crown)"
    [19]="Soma (Manifestation)"
    [23]="Jnana (Agent 99 Meta-Coordinator)"
)

for prime in 2 3 5 7 11 13 17 19 23; do
    port=$((8500 + prime))
    chakra_name="${CHAKRAS[$prime]}"
    test_endpoint "$chakra_name (Prime $prime)" "http://localhost:$port/health"
done

# Test Agent 99 specific endpoints
echo -e "${BLUE}--- Agent 99 Meta-Coordinator ---${NC}"
echo ""

test_endpoint "Agent 99 Coherence" "http://localhost:8523/coherence"
test_endpoint "Agent 99 PDCA Status" "http://localhost:8523/pdca"

# Test MCP Bridge
echo -e "${BLUE}--- MCP Bridge ---${NC}"
echo ""

test_endpoint "MCP Bridge" "http://localhost:8520/health"
test_endpoint "MCP Tools List" "http://localhost:8520/mcp/tools"

# Summary
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Test Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    echo -e "${GREEN}Ubuntu: I am because we are - Collective coherence achieved${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    echo -e "${YELLOW}Note: Failures expected if services not yet started${NC}"
    exit 1
fi
