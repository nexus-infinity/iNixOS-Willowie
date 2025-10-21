# FIELD Pipeline for iMac 2019 NixOS Configuration

## Purpose

The FIELD pipeline provides a reproducible workflow for deploying and maintaining the iMac 2019 NixOS configuration with strict guardrails and observability. FIELD stands for:

- **Scan** → Deep inventory of the system
- **Evaluate** (Observer) → Detect friction and inconsistencies
- **Architect** (Design) → Define crystalline blueprint
- **Weave** (Apply) → Mount clean, regenerate config, rebuild
- **Verify** → Post-scan and delta reporting

## Pipeline Stages

### 1. Scan (field-scan-2019imac-v5.sh)

Collects comprehensive hardware and system inventory:

- CPU, GPU, Memory
- Storage devices (NVMe, SATA, USB)
- Peripherals (Bluetooth, Wi-Fi, Thunderbolt, Audio, Camera)
- EFI/Boot configuration
- Users, mounts, filesystems
- Current NixOS configuration

**Output:** `/var/log/FIELD-Scan-YYYYmmdd-HHMMSS/` containing:
- `report.md` - Human-readable Markdown report
- `report.html` - HTML version for browser viewing
- `report.json` - Machine-readable JSON for automation
- `raw/` - Raw command outputs

**Usage:**
```bash
sudo ./tools/field/field-scan-2019imac-v5.sh
sudo ./tools/field/field-scan-2019imac-v5.sh --hash  # Include file hashes (slower)
sudo ./tools/field/field-scan-2019imac-v5.sh --include-ephemeral  # Include tmpfs/overlay mounts
```

### 2. Evaluate/Observer (Built into scanner and preflight)

The scanner automatically detects "friction":
- Duplicate `fileSystems` blocks in hardware-configuration.nix
- Duplicate boot loader options
- Bind/overlay pollution in filesystem declarations
- Transient devices (overlay, /etc/nix/*, /nix/store/*)

### 3. Architect/Design (blueprint.nix)

The blueprint module (`/etc/nixos/field/blueprint.nix`) serves as the single source of truth for:
- Hostname
- Boot loader configuration (single ownership)
- Filesystem mounts for `/` and `/boot` (single ownership)
- Desktop environment and audio defaults
- System state version

**Template provided:** `tools/field/blueprint.nix`

### 4. Weave/Apply (field-weave.sh)

Mounts a clean Btrfs root and applies the configuration:

1. **Mount Clean Root:** Mounts `@` subvolume at `/mnt/ROOT` and ESP
2. **Regenerate Hardware Config:** Creates fresh `hardware-configuration.nix` from clean mount
3. **Sanitize:** Removes transient devices, deduplicates filesystem blocks and options
4. **Wire Blueprint:** Ensures blueprint exists and is imported in configuration.nix
5. **Preflight Check:** Validates no duplicates or transient devices remain
6. **Build:** Runs `nixos-rebuild build` first
7. **Switch:** Only switches if build succeeds
8. **Log:** Saves complete logs to `/var/log/FIELD-Apply-YYYYmmdd-HHMMSS.log`
9. **Post-Scan:** Triggers a post-rebuild scan for observability

**Usage:**
```bash
sudo ./tools/field/field-weave.sh
```

### 5. Verify (field-preflight.sh)

Validation script that enforces guardrails:
- No duplicate filesystem mountpoints in hardware-configuration.nix
- No duplicate `options = [ ... ];` lines for the same filesystem
- No transient devices (overlay, /etc/nix/*, /nix/store/*)
- No duplicate boot loader options in configuration.nix

**Usage:**
```bash
sudo ./tools/field/field-preflight.sh
# Returns 0 on success, non-zero on violations
```

## Complete Pipeline Orchestration

### field-pipeline.sh

Runs the entire end-to-end workflow:

1. **Baseline Scan:** Initial system state capture
2. **Report Generation:** Create baseline report
3. **Blueprint Ensure:** Verify blueprint.nix exists
4. **Weave:** Apply configuration (includes preflight, build, switch, post-scan)
5. **Delta Summary:** Compare before/after states

**Usage:**
```bash
sudo ./tools/field/field-pipeline.sh
sudo ./tools/field/field-pipeline.sh --no-open  # Don't auto-open reports
sudo ./tools/field/field-pipeline.sh --serve 8080  # Serve reports on port 8080
```

## Reporting Tools

### field-scan-report-v3.sh

Regenerates reports from an existing scan directory:

**Usage:**
```bash
./tools/field/field-scan-report-v3.sh /var/log/FIELD-Scan-20250101-120000
./tools/field/field-scan-report-v3.sh /var/log/FIELD-Scan-20250101-120000 --open
./tools/field/field-scan-report-v3.sh /var/log/FIELD-Scan-20250101-120000 --serve 8080
```

## Guardrails and Safety

### Single Ownership Principle

The blueprint.nix module is the **single source of truth** for:
- Root filesystem (`/`)
- Boot partition (`/boot`)
- Boot loader configuration

This prevents:
- Conflicting `fileSystems` declarations
- Duplicate boot loader options
- Bind mount pollution in hardware-configuration.nix

### Clean Mount Strategy

`field-weave.sh` always:
1. Mounts the Btrfs `@` subvolume to a clean path (`/mnt/ROOT`)
2. Runs `nixos-generate-config` from this clean mount
3. Sanitizes the generated hardware-configuration.nix
4. Never allows bind/overlay mounts to pollute the configuration

### Build-Then-Switch

The weaver:
1. Runs `nixos-rebuild build` first
2. Only proceeds to `switch` if build succeeds
3. Saves full logs for troubleshooting

### Preflight Validation

Before any rebuild:
- Validates configuration structure
- Checks for duplicates and conflicts
- Fails fast to prevent broken deployments

## Step-by-Step Workflow

### Initial Setup (From NixOS Live ISO or Existing System)

1. **Run Initial Scan:**
   ```bash
   sudo ./tools/field/field-scan-2019imac-v5.sh
   ```

2. **Review Scan Report:**
   ```bash
   # Latest scan directory:
   SCAN_DIR=$(ls -td /var/log/FIELD-Scan-* | head -1)
   xdg-open "$SCAN_DIR/report.html"
   # Or regenerate/view:
   ./tools/field/field-scan-report-v3.sh "$SCAN_DIR" --open
   ```

3. **Create/Edit Blueprint:**
   ```bash
   # Copy template if needed:
   sudo mkdir -p /etc/nixos/field
   sudo cp tools/field/blueprint.nix /etc/nixos/field/
   
   # Edit and fill in UUIDs:
   sudo vim /etc/nixos/field/blueprint.nix
   ```

4. **Run Weaver:**
   ```bash
   sudo ./tools/field/field-weave.sh
   ```

5. **Review Results:**
   ```bash
   # Check logs:
   tail -100 /var/log/FIELD-Apply-*.log
   
   # Review post-scan:
   POST_SCAN=$(ls -td /var/log/FIELD-Scan-* | head -1)
   xdg-open "$POST_SCAN/report.html"
   ```

### Full Pipeline Run

For a complete end-to-end run with delta reporting:

```bash
sudo ./tools/field/field-pipeline.sh
```

This will:
- Capture baseline state
- Apply configuration
- Capture post-state
- Show what changed (mounts, boot entries)

### Manual Preflight Check

Before manual rebuilds:

```bash
sudo ./tools/field/field-preflight.sh
if [ $? -eq 0 ]; then
  echo "✓ Preflight passed - safe to rebuild"
  sudo nixos-rebuild switch --flake .#BearsiMac
else
  echo "✗ Preflight failed - fix issues before rebuilding"
fi
```

## Files and Permissions

All scripts should be executable (755):
```bash
chmod 755 tools/field/field-*.sh
```

The blueprint module should be readable (644):
```bash
chmod 644 tools/field/blueprint.nix
```

## Integration with Existing Workflow

The FIELD pipeline complements existing deployment scripts:
- `scripts/deploy-safe.sh` - Repository clone and initial setup
- FIELD pipeline - Configuration refinement and maintenance

Recommended flow:
1. Use `deploy-safe.sh` for initial repository deployment
2. Run FIELD scan to understand current state
3. Create/edit blueprint for target state
4. Use FIELD weaver for clean configuration application
5. Use FIELD pipeline for ongoing maintenance and observability

## Logs and Artifacts

### Scan Outputs
- `/var/log/FIELD-Scan-YYYYmmdd-HHMMSS/` - Each scan creates timestamped directory
- Contains: report.md, report.html, report.json, raw/ subdirectory

### Weaver Logs
- `/var/log/FIELD-Apply-YYYYmmdd-HHMMSS.log` - Complete rebuild log
- Includes: mount operations, config generation, sanitization, preflight, build output

### Working Files
- `/etc/nixos/hardware-configuration.nix` - Auto-generated, sanitized
- `/etc/nixos/field/blueprint.nix` - User-maintained blueprint
- `/etc/nixos/configuration.nix` - Imports both files above

## Troubleshooting

### Preflight Failures

**Duplicate fileSystems:**
```
ERROR: Duplicate fileSystems mountpoint: /
```
**Solution:** Remove duplicate blocks from hardware-configuration.nix or move to blueprint.nix

**Transient devices:**
```
ERROR: Transient device in fileSystems: overlay
```
**Solution:** Run weaver to regenerate from clean mount

**Duplicate boot options:**
```
ERROR: Duplicate boot.loader option: boot.loader.systemd-boot.enable
```
**Solution:** Keep in blueprint.nix only, remove from configuration.nix

### Scan Failures

**Permission denied:**
```bash
sudo ./tools/field/field-scan-2019imac-v5.sh
```

**Missing dependencies:**
```bash
nix-shell -p lshw pciutils usbutils
```

### Weaver Failures

**Mount errors:**
- Ensure Btrfs `@` subvolume exists
- Check ESP is available
- Verify /mnt/ROOT is not in use

**Build errors:**
- Check `/var/log/FIELD-Apply-*.log`
- Review blueprint.nix syntax
- Ensure UUIDs are correct

## Future Enhancements

- Flake apps for `nix run .#field-scan` and `nix run .#field-pipeline`
- CI job for shellcheck validation
- Automated tests for preflight validation
- Integration with deployment automation
- Historical scan comparison and trend analysis

## Security Considerations

- Scripts require root/sudo for system inspection and rebuild
- Scan outputs may contain sensitive information (sanitize before sharing)
- Blueprint contains filesystem UUIDs (not sensitive but system-specific)
- Logs contain full rebuild output (review before sharing)
