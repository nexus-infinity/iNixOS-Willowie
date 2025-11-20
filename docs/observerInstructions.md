# Observer Instructions & Field Testing Plan

Purpose
- Anchor: store the canonical instructions and test checklist for the copilot-assistant service and for any Copilot-driven changes.
- Observers: define required roles and concrete acceptance checks.

Roles (sign-off required before enabling)
- Position 3 — Field Observer
- Position 6 — Architect
- Position 9 — Weaver
- Position 11 — External Observer (repository owner / final approver)

Anchor steps (create branch + files)
1. Create a branch prefixed with `copilot/`.
2. Add `.github/copilot-instructions.md` and this file.
3. Open a PR targeting `main` and request reviewers: positions 3,6,9.
4. After reviewers approve, run the verification checklist and ask Position 11 (external observer) to witness and confirm.

Verification checklist (run these locally; do not expose secrets)
1) Validate flake builds (no switch):
   nix build --no-link .#nixosConfigurations.BearsiMac.config.system.build.toplevel
   - Expected: exit 0 and `result` symlink present.

2) Confirm module visibility:
   nixos-option services.copilot-assistant.enable
   - Expected: prints boolean (true/false). Default must be false in PR.

3) Switch (only on controlled machine) and enable in configuration (after approvals):
   sudo nixos-rebuild switch --flake .#BearsiMac

4) Systemd service checks:
   systemctl status copilot-assistant.service
   journalctl -u copilot-assistant -n 200 --no-pager

5) Local HTTP sanity check:
   curl -fsS http://localhost:8765/ | head -n 20
   - Expected: service responds (html/json or health text).

6) Post-deploy acceptance by Observers:
   - Field Observer (3): confirm behavior in the environment and provide short note in PR.
   - Architect (6): confirm architecture and security posture.
   - Weaver (9): confirm packaging, flake, and reproducibility.
   - External Observer (11): run end-to-end checks and post final approval.

Rollback
- If service misbehaves:
  sudo nixos-rebuild switch --rollback
  or revert the config commit and rebuild.

Recordkeeping
- Save test outputs (nix build logs, systemctl and journalctl snippets) as artifacts in the PR conversation — attach them before seeking Position 11 sign-off.

Signed seal
- After successful tests, add a PR comment:
  "Seal: tests passed; observers 3,6,9 confirm; external observer 11 to finalize."
