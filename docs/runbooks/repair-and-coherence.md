# Runbook — repair_and_backup.sh and Mole checks

Common operations (repo root or mounted installed root)

1. Dry scan (no changes):
   sudo ./repair_and_backup.sh --root /mnt/installed

2. Create a backup tarball:
   sudo ./repair_and_backup.sh --root /mnt/installed --backup /root/nixos-backup.tgz

3. Run Mole coherence check (emit baton if drift detected):
   sudo ./repair_and_backup.sh --root /mnt/installed --mole-check

4. Force baton emission for inspection:
   sudo ./repair_and_backup.sh --root /mnt/installed --emit-baton

5. Apply safe, non-destructive repairs (creates files in the installed tree):
   sudo ./repair_and_backup.sh --root /mnt/installed --auto-repair --yes

6. Inspect OBI‑WAN log (local):
   sudo less /mnt/installed/var/log/obiwan-events.log

Notes
- HMAC key for local baton signing is created at: /mnt/installed/etc/field-keys/mole.hmac.key