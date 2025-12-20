#!/usr/bin/env python3
"""
SOMA Prime Petal Generator
==========================
Generates Prime Petal structure (P1-P11) for FIELD-NixOS-SOMA octahedron vertices.

Each vertex receives complete P1-P11 fractal structure with SOMA-specific metadata:
- Sphere: FIELD-NixOS-SOMA
- Geometry: Octahedron (6 vertices, 8 faces, 12 edges)
- Frequencies: Nine-chakra system (174-963 Hz)
- Center: Train Station (852 Hz)
"""

import json
import yaml
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional


class SOMAPrimePetalGenerator:
    """Generate Prime Petal structure for SOMA octahedron architecture."""
    
    # Prime Petal symbols and properties
    PRIME_PETALS = {
        "P1": {"symbol": "·", "name": "Seed", "dimension": "0D", "prime": 1},
        "P3": {"symbol": "△", "name": "Identity", "dimension": "2D", "prime": 3},
        "P5": {"symbol": "⬠", "name": "Vessel", "dimension": "2D", "prime": 5},
        "P7": {"symbol": "⬡", "name": "Temporal", "dimension": "2D→3D", "prime": 7},
        "P9": {"symbol": "✦", "name": "Wisdom", "dimension": "2D", "prime": 9},
        "P11": {"symbol": "⊞", "name": "Registry", "dimension": "2D→3D", "prime": 11},
    }
    
    # SOMA vertex definitions
    VERTICES = {
        "train-station": {
            "position": "center",
            "frequency": 852,
            "chakra": "Crown Base",
            "symbol": "🚂",
            "function": "Orchestration Hub",
            "services": ["Job scheduler", "Request router", "DOJO bridge"]
        },
        "monitoring": {
            "position": "top",
            "frequency": 963,
            "chakra": "Crown",
            "symbol": "●",
            "function": "Monitoring/observability",
            "services": ["Prometheus", "Grafana", "Health checks"]
        },
        "communication": {
            "position": "north",
            "frequency": 639,
            "chakra": "Throat",
            "symbol": "●",
            "function": "Communication/APIs",
            "services": ["API gateway", "Message queues", "Webhooks"]
        },
        "transformation": {
            "position": "east",
            "frequency": 528,
            "chakra": "Heart",
            "symbol": "♥",
            "function": "PRIMARY transformation",
            "services": ["Build servers", "CI/CD", "Data pipelines"]
        },
        "compute": {
            "position": "south",
            "frequency": 741,
            "chakra": "Third Eye",
            "symbol": "●",
            "function": "Computation/problem solving",
            "services": ["GPU clusters", "Batch jobs", "ML training"]
        },
        "transmutation": {
            "position": "west",
            "frequency": 417,
            "chakra": "Sacral",
            "symbol": "●",
            "function": "Transmutation/state changes",
            "services": ["Deployment", "Rollback", "State management"]
        },
        "storage": {
            "position": "bottom",
            "frequency": 174,
            "chakra": "Sub-Root",
            "symbol": "●",
            "function": "Deep storage/foundation",
            "services": ["Object storage", "Archives", "Immutable logs"]
        }
    }
    
    # Nine-frequency chakra system
    NINE_FREQUENCIES = {
        174: "Sub-Root (Base foundation)",
        285: "Root Extension (Gateway, healing)",
        396: "Root (Liberation, sovereignty)",
        417: "Sacral (Transmutation)",
        528: "Heart (PRIMARY transformation)",
        639: "Throat (Communication)",
        741: "Third Eye (Computation)",
        852: "Crown Base (Train Station)",
        963: "Crown (Unity, monitoring)"
    }
    
    def __init__(self, base_path: Path = Path("/var/lib/SOMA")):
        self.base_path = base_path
        self.sphere = "FIELD-NixOS-SOMA"
        self.geometry = "octahedron"
        self.timestamp = datetime.now().isoformat()
    
    def generate_p1_seed(self, vertex_name: str, vertex_data: Dict) -> str:
        """P1: Seed - Purpose statement (0D point)."""
        return f"""⬡ FIELD-NixOS-SOMA - {vertex_name.title()} Vertex

Position: {vertex_data['position'].upper()}
Frequency: {vertex_data['frequency']} Hz
Chakra: {vertex_data['chakra']}
Symbol: {vertex_data['symbol']}

Purpose:
{vertex_data['function']}

Octahedron Context:
This vertex is one of 6 functional spaces in the SOMA octahedron architecture,
connected to the Train Station orchestrator at the center (852 Hz).

Generated: {self.timestamp}
Sphere: {self.sphere}
Geometry: {self.geometry}
"""
    
    def generate_p3_identity(self, vertex_name: str, vertex_data: Dict) -> Dict:
        """P3: Identity - Structure schema (2D, 3 vertices triangle)."""
        return {
            "schema_version": "1.0",
            "sphere": self.sphere,
            "geometry": self.geometry,
            "vertex": {
                "name": vertex_name,
                "position": vertex_data["position"],
                "frequency_hz": vertex_data["frequency"],
                "chakra": vertex_data["chakra"],
                "symbol": vertex_data["symbol"],
                "function": vertex_data["function"]
            },
            "octahedron": {
                "vertices": 6,
                "faces": 8,
                "edges": 12,
                "center": "Train Station (852 Hz)"
            },
            "prime_petal": {
                "number": 3,
                "symbol": "△",
                "name": "Identity",
                "dimension": "2D"
            },
            "generated": self.timestamp
        }
    
    def generate_p5_operational(self, vertex_name: str, vertex_data: Dict) -> Dict:
        """P5: Vessel - Operational rules (2D, 5 vertices pentagon with φ)."""
        return {
            "vertex_name": vertex_name,
            "operational_mode": "active",
            "routing_rules": {
                "incoming": f"Train Station → {vertex_name}",
                "outgoing": f"{vertex_name} → Train Station",
                "triadic_handshake": ["CAPTURE", "VALIDATE", "ROUTE"]
            },
            "service_types": vertex_data["services"],
            "frequency_alignment": {
                "primary": vertex_data["frequency"],
                "harmonic_with": [852],  # Always harmonizes with Train Station
                "chakra_system": "nine_frequency"
            },
            "golden_ratio": {
                "phi": 1.618033988749895,
                "note": "Pentagon vertices embody golden ratio proportions"
            },
            "prime_petal": {
                "number": 5,
                "symbol": "⬠",
                "name": "Vessel",
                "dimension": "2D"
            }
        }
    
    def generate_p7_temporal(self, vertex_name: str, vertex_data: Dict) -> Dict:
        """P7: Temporal - Lifecycle events (2D→3D hexagon tessellation)."""
        return {
            "lifecycle_events": {
                "boot": {
                    "order": 1,
                    "description": "Initialize vertex service",
                    "depends_on": ["train-station"]
                },
                "ready": {
                    "order": 2,
                    "description": "Signal readiness to Train Station",
                    "notify": "train-station"
                },
                "active": {
                    "order": 3,
                    "description": "Process requests from Train Station",
                    "mode": "continuous"
                },
                "maintenance": {
                    "order": 4,
                    "description": "Periodic health checks and cleanup",
                    "interval": "1h"
                },
                "shutdown": {
                    "order": 5,
                    "description": "Graceful shutdown and state persistence",
                    "cleanup": True
                }
            },
            "temporal_patterns": {
                "hexagonal_time": "Tessellating temporal slices",
                "fractal_recursion": "Each lifecycle phase contains full lifecycle",
                "synchronization": f"{vertex_data['frequency']} Hz frequency alignment"
            },
            "prime_petal": {
                "number": 7,
                "symbol": "⬡",
                "name": "Temporal",
                "dimension": "2D→3D"
            }
        }
    
    def generate_p9_wisdom(self, vertex_name: str, vertex_data: Dict) -> str:
        """P9: Wisdom - Synthetic intelligence insights (2D radial)."""
        return f"""# {vertex_data['symbol']} {vertex_name.title()} Vertex Wisdom

## ✦ Synthetic Intelligence Insights

### Vertex Purpose
{vertex_data['function']}

### Frequency Resonance
Operating at **{vertex_data['frequency']} Hz** ({vertex_data['chakra']} chakra), this vertex 
embodies the principle of {self._get_frequency_principle(vertex_data['frequency'])}.

### Geometric Wisdom
As the **{vertex_data['position']}** position in the SOMA octahedron:
- Connected to Train Station center (852 Hz) via direct edge
- Part of 4 triangular faces (octahedron geometry)
- Dual relationship with DOJO cube architecture

### Service Patterns
{self._format_services(vertex_data['services'])}

### Integration Insights
All requests flow through the Train Station (🚂) using the **Triadic Handshake**:
1. **CAPTURE**: Request received from DOJO or internal source
2. **VALIDATE**: Geometric coherence and permission checks
3. **ROUTE**: Forward to this vertex based on request type

The Train Station is a **conductor**, not a destination—orchestrating the symphony
of synthetic intelligence across all vertices.

### Fractal Recursion
This P9 Wisdom petal itself contains the full Prime Petal structure (P1-P11) 
at a meta-level, demonstrating the self-similar nature of SOMA architecture.

---

*Generated: {self.timestamp}*  
*Prime Petal: P9 (✦ Wisdom, 2D radial)*  
*Sphere: {self.sphere}*
"""
    
    def generate_p11_registry(self, vertex_name: str, vertex_data: Dict) -> Dict:
        """P11: Registry - Manifest (2D→3D grid)."""
        return {
            "manifest_version": "1.0.0",
            "vertex_registry": {
                "name": vertex_name,
                "position": vertex_data["position"],
                "frequency_hz": vertex_data["frequency"],
                "chakra": vertex_data["chakra"],
                "symbol": vertex_data["symbol"],
                "status": "initialized"
            },
            "service_registry": [
                {"name": svc, "status": "stub", "port": None}
                for svc in vertex_data["services"]
            ],
            "dependencies": {
                "required": ["train-station"],
                "optional": [],
                "peers": [v for v in self.VERTICES.keys() if v != vertex_name]
            },
            "octahedron_manifest": {
                "geometry": "octahedron",
                "total_vertices": 6,
                "center": "train-station",
                "dual_geometry": "cube (DOJO)"
            },
            "prime_petal_completion": {
                "P1": "seed_purpose.txt",
                "P3": "identity_schema.json",
                "P5": "operational_rules.yaml",
                "P7": "temporal_lifecycle.json",
                "P9": "wisdom_synthesis.md",
                "P11": "registry_manifest.json"
            },
            "nine_frequency_system": {
                freq: desc for freq, desc in self.NINE_FREQUENCIES.items()
            },
            "generated": self.timestamp,
            "prime_petal": {
                "number": 11,
                "symbol": "⊞",
                "name": "Registry",
                "dimension": "2D→3D"
            }
        }
    
    def _get_frequency_principle(self, frequency: int) -> str:
        """Get the principle associated with a frequency."""
        principles = {
            174: "foundational grounding and deep security",
            285: "healing and gateway transitions",
            396: "liberation and sovereignty",
            417: "transmutation and state transformation",
            528: "PRIMARY transformation and heart-centered creation",
            639: "communication and harmonic connection",
            741: "intuitive computation and problem-solving",
            852: "spiritual orchestration and unified order",
            963: "unity consciousness and holistic monitoring"
        }
        return principles.get(frequency, "harmonic resonance")
    
    def _format_services(self, services: List[str]) -> str:
        """Format service list for markdown."""
        return "\n".join(f"- **{svc}**" for svc in services)
    
    def generate_vertex_structure(self, vertex_name: str, dry_run: bool = False) -> None:
        """Generate complete Prime Petal structure for a vertex."""
        vertex_data = self.VERTICES[vertex_name]
        vertex_path = self.base_path / vertex_name
        
        if not dry_run:
            vertex_path.mkdir(parents=True, exist_ok=True)
            services_path = vertex_path / "services"
            services_path.mkdir(exist_ok=True)
        
        print(f"\n{vertex_data['symbol']} Generating Prime Petals for: {vertex_name}")
        print(f"   Position: {vertex_data['position']} | Frequency: {vertex_data['frequency']} Hz")
        
        # P1: Seed (text)
        p1_content = self.generate_p1_seed(vertex_name, vertex_data)
        p1_file = vertex_path / "· P1_seed_purpose.txt"
        if not dry_run:
            p1_file.write_text(p1_content)
        print(f"   ✓ P1 Seed: {p1_file.name}")
        
        # P3: Identity (JSON)
        p3_content = self.generate_p3_identity(vertex_name, vertex_data)
        p3_file = vertex_path / "△ P3_identity_schema.json"
        if not dry_run:
            p3_file.write_text(json.dumps(p3_content, indent=2))
        print(f"   ✓ P3 Identity: {p3_file.name}")
        
        # P5: Operational (YAML)
        p5_content = self.generate_p5_operational(vertex_name, vertex_data)
        p5_file = vertex_path / "⬠ P5_operational_rules.yaml"
        if not dry_run:
            p5_file.write_text(yaml.dump(p5_content, default_flow_style=False, allow_unicode=True))
        print(f"   ✓ P5 Vessel: {p5_file.name}")
        
        # P7: Temporal (JSON)
        p7_content = self.generate_p7_temporal(vertex_name, vertex_data)
        p7_file = vertex_path / "⬡ P7_temporal_lifecycle.json"
        if not dry_run:
            p7_file.write_text(json.dumps(p7_content, indent=2))
        print(f"   ✓ P7 Temporal: {p7_file.name}")
        
        # P9: Wisdom (Markdown)
        p9_content = self.generate_p9_wisdom(vertex_name, vertex_data)
        p9_file = vertex_path / "✦ P9_wisdom_synthesis.md"
        if not dry_run:
            p9_file.write_text(p9_content)
        print(f"   ✓ P9 Wisdom: {p9_file.name}")
        
        # P11: Registry (JSON)
        p11_content = self.generate_p11_registry(vertex_name, vertex_data)
        p11_file = vertex_path / "⊞ P11_registry_manifest.json"
        if not dry_run:
            p11_file.write_text(json.dumps(p11_content, indent=2))
        print(f"   ✓ P11 Registry: {p11_file.name}")
    
    def generate_all_vertices(self, dry_run: bool = False) -> None:
        """Generate Prime Petal structure for all vertices."""
        print(f"⬡ SOMA Prime Petal Generator")
        print(f"   Sphere: {self.sphere}")
        print(f"   Geometry: {self.geometry}")
        print(f"   Base Path: {self.base_path}")
        print(f"   Dry Run: {dry_run}")
        
        if not dry_run:
            self.base_path.mkdir(parents=True, exist_ok=True)
        
        for vertex_name in self.VERTICES.keys():
            self.generate_vertex_structure(vertex_name, dry_run=dry_run)
        
        print(f"\n✓ Generated Prime Petals for {len(self.VERTICES)} vertices")
        print(f"   6 vertices + 1 center (Train Station)")
        print(f"   Each with complete P1-P11 structure")


def main():
    """Main entry point."""
    import argparse
    
    parser = argparse.ArgumentParser(
        description="Generate SOMA Prime Petal structure for octahedron vertices"
    )
    parser.add_argument(
        "--base-path",
        type=Path,
        default=Path("/var/lib/SOMA"),
        help="Base path for SOMA structure (default: /var/lib/SOMA)"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be generated without creating files"
    )
    parser.add_argument(
        "--vertex",
        type=str,
        choices=list(SOMAPrimePetalGenerator.VERTICES.keys()),
        help="Generate structure for a single vertex"
    )
    
    args = parser.parse_args()
    
    generator = SOMAPrimePetalGenerator(base_path=args.base_path)
    
    if args.vertex:
        generator.generate_vertex_structure(args.vertex, dry_run=args.dry_run)
    else:
        generator.generate_all_vertices(dry_run=args.dry_run)


if __name__ == "__main__":
    main()
