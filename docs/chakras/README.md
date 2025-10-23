# Chakras — responsibilities & locations

Each chakra is a modular slice of the system. This page lists the role, key files, and memory-related fields.

Layout (examples)
- muladhara (root / foundation)
  - Purpose: Smriti memory core, persistence for operational memory
  - Config: chakras/muladhara/default.nix
  - Memory: memory_cache, max_tokens, directory_structure.memory

- soma (manifestation / coherence guardian)
  - Purpose: Coherence controller, contains Mole return-vector mapper
  - Config: chakras/soma/default.nix
  - Mole config: chakra/soma/config.yaml
  - Mole harness: chakra/soma/mole_protocol.py
  - Pulse manifest: pulse_manifest.json

- jnana (knowledge / long-context)
  - Purpose: Large-context knowledge repository
  - Config: chakras/jnana/default.nix
  - Memory: memory_cache, max_tokens, directory_structure.memory

Where to look for memory settings
- Search for `memory_cache`, `max_tokens`, and `directory_structure.memory` in chakras/*/default.nix.
- The per-chakra tiny-LLM DNA and model settings are defined in each chakra's `dna_management` block.

Recommended doc location per chakra
- docs/chakras/<chakra>.md — short, single page describing purpose, key files, memory path, and operations commands.