#!/usr/bin/env python3
"""
SOMA DNA Blueprint Validator
==============================
Validates DNA blueprint JSON files against schema v0.2.0.

Usage:
    python3 validate_dna_blueprint.py <blueprint.json>
    python3 validate_dna_blueprint.py --all  # Validate all blueprints

Validates:
- JSON schema compliance
- Ubuntu philosophy presence ("I am because we are")
- Prime number sequence (2, 3, 5, 7, 11, 13, 17, 19, 23)
- Frequency ranges (108-1086 Hz)
- Cultural mappings (minimum 5 traditions)
- never_acts_alone: true
"""

import json
import sys
from pathlib import Path
from typing import Dict, List, Tuple


class DNABlueprintValidator:
    """Validator for SOMA DNA blueprints v0.2.0."""
    
    VALID_PRIMES = [2, 3, 5, 7, 11, 13, 17, 19, 23]
    VALID_CHAKRAS = [
        "muladhara", "svadhisthana", "manipura", "anahata",
        "vishuddha", "ajna", "sahasrara", "soma", "jnana"
    ]
    
    FREQ_MIN = 108
    FREQ_MAX = 1086
    
    MIN_CULTURAL_EXPRESSIONS = 5
    
    def __init__(self, schema_path: str = None):
        self.schema_path = schema_path
        self.errors = []
        self.warnings = []
    
    def validate_file(self, blueprint_path: str) -> Tuple[bool, List[str], List[str]]:
        """
        Validate a DNA blueprint file.
        
        Returns:
            (is_valid, errors, warnings)
        """
        self.errors = []
        self.warnings = []
        
        # Load blueprint
        try:
            with open(blueprint_path, 'r') as f:
                blueprint = json.load(f)
        except FileNotFoundError:
            self.errors.append(f"File not found: {blueprint_path}")
            return False, self.errors, self.warnings
        except json.JSONDecodeError as e:
            self.errors.append(f"Invalid JSON: {e}")
            return False, self.errors, self.warnings
        
        # Validate structure
        self._validate_version(blueprint)
        self._validate_prime_id(blueprint)
        self._validate_chakra(blueprint)
        self._validate_identity(blueprint)
        self._validate_ubuntu_genotype(blueprint)
        self._validate_cultural_phenotype(blueprint)
        self._validate_model(blueprint)
        self._validate_homeostatic_budgets(blueprint)
        self._validate_swarm_awareness(blueprint)
        self._validate_frequencies(blueprint)
        
        is_valid = len(self.errors) == 0
        return is_valid, self.errors, self.warnings
    
    def _validate_version(self, blueprint: Dict):
        """Validate version field."""
        if "version" not in blueprint:
            self.errors.append("Missing 'version' field")
            return
        
        version = blueprint["version"]
        if not version.startswith("0.2.0-ubuntu-"):
            self.errors.append(f"Invalid version format: {version} (expected 0.2.0-ubuntu-*)")
    
    def _validate_prime_id(self, blueprint: Dict):
        """Validate prime_id field."""
        if "prime_id" not in blueprint:
            self.errors.append("Missing 'prime_id' field")
            return
        
        prime = blueprint["prime_id"]
        if prime not in self.VALID_PRIMES:
            self.errors.append(f"Invalid prime_id: {prime} (must be one of {self.VALID_PRIMES})")
    
    def _validate_chakra(self, blueprint: Dict):
        """Validate chakra field."""
        if "chakra" not in blueprint:
            self.errors.append("Missing 'chakra' field")
            return
        
        chakra = blueprint["chakra"]
        if chakra not in self.VALID_CHAKRAS:
            self.errors.append(f"Invalid chakra: {chakra} (must be one of {self.VALID_CHAKRAS})")
    
    def _validate_identity(self, blueprint: Dict):
        """Validate identity section."""
        if "identity" not in blueprint:
            self.errors.append("Missing 'identity' section")
            return
        
        identity = blueprint["identity"]
        required = ["name", "role", "archetype"]
        for field in required:
            if field not in identity:
                self.errors.append(f"Missing identity.{field}")
    
    def _validate_ubuntu_genotype(self, blueprint: Dict):
        """Validate Ubuntu genotype - CRITICAL."""
        if "ubuntu_genotype" not in blueprint:
            self.errors.append("CRITICAL: Missing 'ubuntu_genotype' section")
            return
        
        ubuntu = blueprint["ubuntu_genotype"]
        
        # Check principle contains "I am because we are"
        if "principle" not in ubuntu:
            self.errors.append("CRITICAL: Missing ubuntu_genotype.principle")
        elif "I am because we are" not in ubuntu["principle"]:
            self.errors.append(
                f"CRITICAL: Ubuntu principle must contain 'I am because we are', "
                f"found: {ubuntu['principle']}"
            )
        
        # Check manifestation
        if "manifestation" not in ubuntu:
            self.errors.append("Missing ubuntu_genotype.manifestation")
        
        # Check never_alone
        if "never_alone" not in ubuntu:
            self.errors.append("CRITICAL: Missing ubuntu_genotype.never_alone")
        elif ubuntu["never_alone"] is not True:
            self.errors.append("CRITICAL: ubuntu_genotype.never_alone must be true")
    
    def _validate_cultural_phenotype(self, blueprint: Dict):
        """Validate cultural expressions."""
        if "cultural_phenotype" not in blueprint:
            self.errors.append("Missing 'cultural_phenotype' section")
            return
        
        cultural = blueprint["cultural_phenotype"]
        if "expressions" not in cultural:
            self.errors.append("Missing cultural_phenotype.expressions")
            return
        
        expressions = cultural["expressions"]
        if len(expressions) < self.MIN_CULTURAL_EXPRESSIONS:
            self.errors.append(
                f"Insufficient cultural expressions: {len(expressions)} "
                f"(minimum {self.MIN_CULTURAL_EXPRESSIONS} required)"
            )
    
    def _validate_model(self, blueprint: Dict):
        """Validate model configuration."""
        if "model" not in blueprint:
            self.errors.append("Missing 'model' section")
            return
        
        model = blueprint["model"]
        
        # Check primary model
        if "primary" not in model:
            self.errors.append("Missing model.primary")
        else:
            primary = model["primary"]
            if "name" in primary and not primary["name"].startswith("TinyLlama"):
                self.warnings.append(
                    f"Primary model is not TinyLlama: {primary['name']}"
                )
        
        # Check quantization
        if "quantization" not in model:
            self.errors.append("Missing model.quantization")
        
        # Check fallback
        if "fallback" not in model:
            self.errors.append("Missing model.fallback")
        elif not isinstance(model["fallback"], list):
            self.errors.append("model.fallback must be an array")
    
    def _validate_homeostatic_budgets(self, blueprint: Dict):
        """Validate resource budgets."""
        if "homeostatic_budgets" not in blueprint:
            self.errors.append("Missing 'homeostatic_budgets' section")
            return
        
        budgets = blueprint["homeostatic_budgets"]
        required = ["cpu_percent", "memory_mb", "cqhi_cap"]
        
        for field in required:
            if field not in budgets:
                self.errors.append(f"Missing homeostatic_budgets.{field}")
        
        # Validate ranges
        if "cpu_percent" in budgets:
            cpu = budgets["cpu_percent"]
            if not (0 < cpu <= 100):
                self.errors.append(f"cpu_percent out of range: {cpu} (must be 0-100)")
        
        if "cqhi_cap" in budgets:
            cqhi = budgets["cqhi_cap"]
            if not (0 <= cqhi <= 1):
                self.errors.append(f"cqhi_cap out of range: {cqhi} (must be 0-1)")
    
    def _validate_swarm_awareness(self, blueprint: Dict):
        """Validate swarm awareness - CRITICAL for Ubuntu."""
        if "swarm_awareness" not in blueprint:
            self.errors.append("CRITICAL: Missing 'swarm_awareness' section")
            return
        
        swarm = blueprint["swarm_awareness"]
        
        # Check never_acts_alone
        if "never_acts_alone" not in swarm:
            self.errors.append("CRITICAL: Missing swarm_awareness.never_acts_alone")
        elif swarm["never_acts_alone"] is not True:
            self.errors.append("CRITICAL: swarm_awareness.never_acts_alone must be true")
        
        # Check octahedral_coordination
        if "octahedral_coordination" not in swarm:
            self.errors.append("Missing swarm_awareness.octahedral_coordination")
        elif swarm["octahedral_coordination"] is not True:
            self.errors.append("swarm_awareness.octahedral_coordination should be true")
        
        # Check consensus_threshold
        if "consensus_threshold" not in swarm:
            self.errors.append("Missing swarm_awareness.consensus_threshold")
        elif swarm["consensus_threshold"] != "5/8":
            self.warnings.append(
                f"Unusual consensus threshold: {swarm['consensus_threshold']} "
                f"(expected 5/8)"
            )
    
    def _validate_frequencies(self, blueprint: Dict):
        """Validate frequency configuration."""
        if "frequencies" not in blueprint:
            self.errors.append("Missing 'frequencies' section")
            return
        
        freq = blueprint["frequencies"]
        
        if "sacred_hz" not in freq:
            self.errors.append("Missing frequencies.sacred_hz")
        else:
            hz = freq["sacred_hz"]
            if isinstance(hz, (int, float)):
                if not (self.FREQ_MIN <= hz <= self.FREQ_MAX):
                    self.warnings.append(
                        f"Frequency outside typical range: {hz} Hz "
                        f"(expected {self.FREQ_MIN}-{self.FREQ_MAX} Hz)"
                    )


def validate_all_blueprints(blueprints_dir: str = None) -> bool:
    """
    Validate all DNA blueprints in directory.
    
    Returns:
        True if all valid, False otherwise
    """
    if blueprints_dir is None:
        blueprints_dir = Path(__file__).parent.parent / "config" / "dna_blueprints"
    else:
        blueprints_dir = Path(blueprints_dir)
    
    if not blueprints_dir.exists():
        print(f"ERROR: Directory not found: {blueprints_dir}")
        return False
    
    blueprint_files = sorted(blueprints_dir.glob("dal_dna_v0.2.0_prime*.json"))
    
    if not blueprint_files:
        print(f"ERROR: No blueprint files found in {blueprints_dir}")
        return False
    
    print(f"Found {len(blueprint_files)} DNA blueprints to validate\n")
    
    validator = DNABlueprintValidator()
    all_valid = True
    
    for blueprint_file in blueprint_files:
        print(f"Validating: {blueprint_file.name}")
        is_valid, errors, warnings = validator.validate_file(str(blueprint_file))
        
        if is_valid:
            print("  ✓ VALID")
        else:
            print("  ✗ INVALID")
            all_valid = False
        
        if errors:
            print("  Errors:")
            for error in errors:
                print(f"    - {error}")
        
        if warnings:
            print("  Warnings:")
            for warning in warnings:
                print(f"    - {warning}")
        
        print()
    
    return all_valid


def main():
    """Main entry point."""
    if len(sys.argv) < 2:
        print("Usage: validate_dna_blueprint.py <blueprint.json>")
        print("       validate_dna_blueprint.py --all")
        sys.exit(1)
    
    if sys.argv[1] == "--all":
        success = validate_all_blueprints()
        sys.exit(0 if success else 1)
    
    blueprint_path = sys.argv[1]
    
    validator = DNABlueprintValidator()
    is_valid, errors, warnings = validator.validate_file(blueprint_path)
    
    if is_valid:
        print(f"✓ {blueprint_path} is VALID")
    else:
        print(f"✗ {blueprint_path} is INVALID")
    
    if errors:
        print("\nErrors:")
        for error in errors:
            print(f"  - {error}")
    
    if warnings:
        print("\nWarnings:")
        for warning in warnings:
            print(f"  - {warning}")
    
    sys.exit(0 if is_valid else 1)


if __name__ == "__main__":
    main()
