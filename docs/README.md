# FIELD — docs index

This directory contains short, focused documentation describing the internal interactions
between the major components in the FIELD architecture (chakras, OBI‑WAN, DOJO, ATLAS, TATA)
and practical runbooks for the local environment.

## Architecture & Configuration:
- **docs/FLAKE_ARCHITECTURE.md** — Complete flake configuration architecture and flow diagram
- **docs/FIELD_ALIGNMENT_GUIDE.md** — Quick reference for maintaining field alignment and coherence
- docs/CONFIGURATION_REVIEW.md — Historical configuration review and fixes

## Core Documentation Files:
- docs/chakras/README.md — per-chakra responsibilities and where their configs live
- docs/soma/mole-protocol.md — Mole: coherence detection, baton emission and how to run tests
- docs/provenance/baton-lifecycle.md — baton schema, events, OBI‑WAN log conventions
- docs/runbooks/repair-and-coherence.md — how to run repair_and_backup.sh, mole checks, and inspect OBI‑WAN events

## Ontology & AI Collaboration:
- **docs/ontology/README.md** — Observer-Architect-Weaver Triad ontology for GitHub Copilot and multi-agent AI systems
- docs/ontology/observer-architect-weaver.md — Complete ontology reference
- docs/ontology/copilot-integration.md — GitHub Copilot integration guide
- docs/ontology/meta-prompt-examples.md — Practical meta-prompting examples
- docs/ontology/visual-ontology.md — Mermaid diagrams and visual maps
- docs/ontology/triad-schema.yaml — YAML schema for agent configuration
- docs/ontology/triad-schema.json — JSON schema for programmatic integration

If you add other docs, link them from here.