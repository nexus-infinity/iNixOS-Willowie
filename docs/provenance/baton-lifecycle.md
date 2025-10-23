# Baton lifecycle & OBI‑WAN provenance

Purpose
- Define a minimal baton schema and event lifecycle so consumers can implement claim/process/pass/retire semantics and audit.

Minimal baton schema (summary)
- baton_id: UUID or short hash
- seq: integer
- producer: { agent_id, host, public_key? }
- holder: agent_id (may be null until claimed)
- intent: string (e.g., reconcilation, return_vector, repair_action)
- attention_entries: [ { memory_id, path, owner_repo, weight, hash, provenance_event } ]
- context_ref: { scan_root, summary, prompt_hash? }
- lease: { issued_at, ttl_seconds }
- prev_baton_id: optional
- signature: HMAC or asymmetric signature
- lifecycle.status: issued | claimed | processed | passed | retired | expired

Event types (append-only OBI-WAN log)
- baton:issued — the baton object is created and published
- baton:claimed — agent claims and starts processing (includes claim signature)
- baton:processed — processing complete (includes used_memory_ids, result_hash)
- baton:passed — baton forwarded (includes new baton_id)
- baton:retired — finalization (archival instructions, revoke tokens)

Local OBI‑WAN log convention
- Default path (local test): /var/log/obiwan-events.log (inside installed root when running repair script)
- Each JSON event should include prev_event_hash (optional), timestamp, and event_type to allow chaining
- Prefer to move to a chained log (each event contains previous event hash) for tamper-evidence.