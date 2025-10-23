# Mole Protocol — alignment, detection, and return-baton flow

Location summary:
- Configuration: chakra/soma/config.yaml
- Reference implementation (test harness): chakra/soma/mole_protocol.py
- Pulse trigger manifest: pulse_manifest.json
- Helper for system-wide scans: tools/mole_checker.py
- Event log (local OBI‑WAN): var/log/obiwan-events.log

What Mole does
- Computes a global coherence/order parameter (mean pairwise cosine over agent signatures).
- When coherence < threshold, emits a return-baton instructing DOJO/agents to route attention back to a seed.
- Baton includes: memory ids, weights, short provenance, lease + ttl, and signature (HMAC or later asymmetric).

How Mole interacts with other fields
- Mole reads the pulse_manifest.json threshold to decide when to act.
- Mole writes baton events into OBI‑WAN (append-only log) and can optionally create a signed baton JSON in /var/log/obiwan-events.log.
- DOJO subscribes to OBI‑WAN events and acts on baton intents (route, reconcile, summarize, etc.).
- ATLAS may provide canonical embeddings; replace mole's deterministic vectors with canonical embeddings for production.

How to run the local harness
- Run the test harness:
  python3 tests/mole_harness.py
- Run the repo scan + mole check:
  sudo ./repair_and_backup.sh --root /mnt/installed --mole-check
- Force baton emission for local inspection:
  sudo ./repair_and_backup.sh --root /mnt/installed --emit-baton

Notes
- The default threshold lives in pulse_manifest.json; update there for experiments.
- For stronger provenance, use an append-only chained log module (see docs/provenance/baton-lifecycle.md).