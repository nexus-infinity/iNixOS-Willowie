#!/usr/bin/env bash
# =============================================================================
# FIELD-SOMA Status Command
# =============================================================================
# Displays status of SOMA octahedron architecture including:
# - Train Station orchestrator
# - All 6 vertices
# - Prime Petal structure
# - Frequency alignment
# =============================================================================

set -euo pipefail

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Symbols
CHECK="✓"
CROSS="✗"
TRAIN="🚂"
HEART="♥"

SOMA_BASE="${SOMA_BASE_PATH:-/var/lib/SOMA}"
TRAIN_PORT="${TRAIN_STATION_PORT:-8520}"

echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}⬡ FIELD-NixOS-SOMA Status${NC}"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# System Identity
echo -e "${BLUE}System Identity:${NC}"
echo -e "  Identity: ${SOMA_IDENTITY:-⬡ FIELD-NixOS-SOMA Octahedron}"
echo -e "  Geometry: Octahedron (6 vertices, 8 faces, 12 edges)"
echo -e "  Base Path: ${SOMA_BASE}"
echo ""

# Train Station Status
echo -e "${BLUE}${TRAIN} Train Station (CENTER - 852 Hz):${NC}"
if systemctl is-active --quiet train-station 2>/dev/null; then
    echo -e "  ${GREEN}${CHECK} Service: Active${NC}"
    
    # Try to query Train Station health
    if command -v curl &> /dev/null; then
        if curl -s -f "http://localhost:${TRAIN_PORT}/health" &> /dev/null; then
            echo -e "  ${GREEN}${CHECK} HTTP API: Responsive (port ${TRAIN_PORT})${NC}"
        else
            echo -e "  ${YELLOW}⚠ HTTP API: Not responding${NC}"
        fi
    fi
else
    echo -e "  ${RED}${CROSS} Service: Inactive${NC}"
fi

if [[ -d "${SOMA_BASE}/train-station" ]]; then
    echo -e "  ${GREEN}${CHECK} Directory: Exists${NC}"
    
    # Check for Prime Petals
    petal_count=$(find "${SOMA_BASE}/train-station" -name "P*_*.txt" -o -name "P*_*.json" -o -name "P*_*.yaml" -o -name "P*_*.md" 2>/dev/null | wc -l)
    if [[ $petal_count -ge 6 ]]; then
        echo -e "  ${GREEN}${CHECK} Prime Petals: Complete (${petal_count}/6)${NC}"
    else
        echo -e "  ${YELLOW}⚠ Prime Petals: Incomplete (${petal_count}/6)${NC}"
    fi
else
    echo -e "  ${RED}${CROSS} Directory: Missing${NC}"
fi
echo ""

# Vertices Status
echo -e "${BLUE}Vertices:${NC}"

vertices=(
    "top:963:Crown:monitoring"
    "north:639:Throat:communication"
    "east:528:Heart:transformation"
    "south:741:Third Eye:compute"
    "west:417:Sacral:transmutation"
    "bottom:174:Sub-Root:storage"
)

for vertex in "${vertices[@]}"; do
    IFS=':' read -r position freq chakra name <<< "$vertex"
    
    symbol="●"
    [[ "$position" == "east" ]] && symbol="♥"
    
    echo -e "  ${symbol} ${position^} (${freq} Hz - ${chakra}): ${name}"
    
    if [[ -d "${SOMA_BASE}/${name}" ]]; then
        petal_count=$(find "${SOMA_BASE}/${name}" -name "P*_*" 2>/dev/null | wc -l)
        if [[ $petal_count -ge 6 ]]; then
            echo -e "     ${GREEN}${CHECK} Prime Petals: ${petal_count}/6${NC}"
        else
            echo -e "     ${YELLOW}⚠ Prime Petals: ${petal_count}/6${NC}"
        fi
    else
        echo -e "     ${RED}${CROSS} Directory missing${NC}"
    fi
done
echo ""

# Nine-Frequency System
echo -e "${BLUE}Nine-Frequency Chakra System:${NC}"
echo -e "  174 Hz - Sub-Root (Base foundation)"
echo -e "  285 Hz - Root Extension (Gateway, healing)"
echo -e "  396 Hz - Root (Liberation, sovereignty)"
echo -e "  417 Hz - Sacral (Transmutation) ${HEART} WEST VERTEX"
echo -e "  528 Hz - Heart (PRIMARY transformation) ${HEART} EAST VERTEX"
echo -e "  639 Hz - Throat (Communication) ● NORTH VERTEX"
echo -e "  741 Hz - Third Eye (Computation) ● SOUTH VERTEX"
echo -e "  852 Hz - Crown Base (Train Station) ${TRAIN} CENTER"
echo -e "  963 Hz - Crown (Unity, monitoring) ● TOP VERTEX"
echo ""

# Octahedron Structure
echo -e "${BLUE}Octahedron Geometry:${NC}"
echo -e "  Vertices: 6 functional spaces"
echo -e "  Faces: 8 triangular"
echo -e "  Edges: 12 pathways"
echo -e "  Center: ${TRAIN} Train Station orchestrator"
echo -e "  Dual: Cube (DOJO architecture)"
echo ""

# DOJO Bridge
echo -e "${BLUE}DOJO Bridge:${NC}"
echo -e "  Shared Frequencies: 5 (396, 528, 741, 852, 963 Hz)"
echo -e "  SOMA-Only Frequencies: 4 (174, 285, 417, 639 Hz)"
echo -e "  Relationship: Independent spheres, connected via Train Station"
echo ""

echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
