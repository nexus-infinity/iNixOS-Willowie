# FIELD Governance Runbook

## Overview

This runbook defines the governance model for the FIELD (Foundational Intelligent Ecosystem Living Design) chakra architecture, mapping responsibilities to three archetypal roles: Observer, Architect, and Weaver.

## Archetypal Roles

### Observer (Monitor & Alert)

**Purpose**: Maintain awareness of system health, detect misalignments, and provide visibility into chakra ecosystem state.

**Responsibilities**:
- Monitor chakra activation status and health metrics
- Track frequency alignment across all chakras
- Analyze audit logs in `/var/log/iNixos-Hive/`
- Generate alerts when chakras fall out of resonance
- Document observed patterns and anomalies
- Provide read-only diagnostics and reporting

**Access Level**: Read-only across all chakras

**Key Tools**:
- `scripts/diag-capture.sh` - System diagnostics
- `journalctl -u *-chakra` - Service logs
- `/var/log/iNixos-Hive/` - Audit logs
- System metrics and monitoring dashboards

**Typical Activities**:
1. Daily health checks of all active chakras
2. Frequency alignment verification
3. Log analysis and pattern recognition
4. Alert generation for out-of-bounds conditions
5. Documentation of observed behaviors

**Decision Authority**: None (recommendations only)

---

### Architect (Design & Configure)

**Purpose**: Design the structure and configuration of chakra ecosystems, ensuring sacred geometric alignment and proper module architecture.

**Responsibilities**:
- Design new chakra modules following template structure
- Configure chakra options and parameters
- Define interconnections between chakras
- Map sacred geometry to system architecture
- Review and approve structural changes
- Maintain module templates and standards
- Ensure configuration consistency

**Access Level**: Configuration authority with review/approval workflow

**Key Tools**:
- `scripts/field-scaffold.sh` - Scaffold new chakras
- `FIELD/chakra/template/module.nix` - Module template
- `FIELD/chakra/default.nix` - Registry aggregator
- NixOS module system
- Configuration version control

**Typical Activities**:
1. Create new chakra modules from template
2. Define chakra-specific options and defaults
3. Configure geometric anchors and frequencies
4. Design service dependencies and relationships
5. Review configuration changes for coherence
6. Update documentation to reflect structural changes

**Decision Authority**: Structural and configuration changes (subject to approval workflow)

**Approval Workflow**:
1. Architect proposes configuration change
2. Observer reviews impact on system health
3. Weaver assesses runtime implications
4. Consensus or designated authority approves
5. Architect implements approved changes

---

### Weaver (Integrate & Orchestrate)

**Purpose**: Actively manage the runtime integration and energy flow between chakras, orchestrating the living system in operation.

**Responsibilities**:
- Activate and deactivate chakra services
- Manage runtime energy flows between chakras
- Balance load and resource allocation
- Respond to real-time system conditions
- Orchestrate service dependencies
- Execute safe rebuild procedures
- Perform runtime tuning and optimization

**Access Level**: Runtime authority over service state and energy routing

**Key Tools**:
- `systemctl` - Service control
- `nixos-rebuild` - System rebuilds
- `docs/runbooks/safe_unshare_rebuild.md` - Safe rebuild procedure
- Runtime monitoring and control interfaces
- Energy flow management tools

**Typical Activities**:
1. Start/stop chakra services based on needs
2. Route energy flows between active chakras
3. Perform safe system rebuilds
4. Respond to runtime alerts from Observer
5. Balance resources across chakras
6. Execute emergency recovery procedures
7. Tune frequencies and parameters in real-time

**Decision Authority**: Runtime service management and emergency response

**Safe Rebuild Procedure**:
1. Observer confirms system state is stable
2. Architect confirms configuration is valid
3. Weaver executes safe rebuild sequence (see safe_unshare_rebuild.md)
4. Observer monitors rebuild progress
5. Weaver verifies successful activation

---

## Governance Workflows

### New Chakra Creation

1. **Architect**: Uses `scripts/field-scaffold.sh` to create new chakra directory
2. **Architect**: Customizes module from template
3. **Architect**: Defines chakra-specific options, frequencies, and services
4. **Observer**: Reviews proposed chakra for coherence with existing ecosystem
5. **Weaver**: Assesses runtime impact and resource requirements
6. **Architect**: Implements approved design
7. **Weaver**: Activates new chakra in test environment
8. **Observer**: Monitors initial activation and health
9. **Weaver**: Promotes to production if stable

### Configuration Change

1. **Architect**: Proposes configuration modification
2. **Observer**: Analyzes impact on system health metrics
3. **Weaver**: Evaluates runtime implications
4. **Architect**: Implements approved changes in version control
5. **Weaver**: Applies changes via safe rebuild
6. **Observer**: Validates post-change system state

### Runtime Incident Response

1. **Observer**: Detects anomaly and generates alert
2. **Observer**: Provides diagnostic context to Weaver
3. **Weaver**: Assesses severity and determines response
4. **Weaver**: Takes immediate action (stop/start services, reroute energy)
5. **Weaver**: Documents incident and response
6. **Observer**: Monitors resolution
7. **Architect**: Implements preventive configuration changes if needed

### Planned Maintenance

1. **Weaver**: Schedules maintenance window
2. **Architect**: Prepares any configuration updates
3. **Observer**: Captures pre-maintenance baseline
4. **Weaver**: Executes maintenance procedure
5. **Observer**: Validates system health post-maintenance
6. **Weaver**: Confirms return to normal operation

---

## Decision Matrix

| Scenario | Observer | Architect | Weaver |
|----------|----------|-----------|--------|
| Read system state | ✓ Authority | ✓ Authority | ✓ Authority |
| Modify configuration | ✗ Recommend | ✓ Authority | ✗ Recommend |
| Start/stop services | ✗ None | ✗ None | ✓ Authority |
| Create new chakra | ✗ Review | ✓ Authority | ✗ Review |
| Emergency response | ✗ Alert | ✗ None | ✓ Authority |
| Frequency tuning | ✗ Recommend | ✓ Design | ✓ Runtime |
| Safe rebuild | ✗ Monitor | ✓ Config | ✓ Execute |

---

## Communication Protocols

### Status Updates
- **Frequency**: Daily for Observer reports
- **Channel**: Hive audit logs + team communication
- **Format**: Structured status including all active chakras

### Alert Escalation
1. **Observer** detects issue → immediate alert
2. **Weaver** acknowledges within 5 minutes
3. **Weaver** provides initial assessment within 15 minutes
4. **Architect** consulted if configuration change needed

### Change Requests
1. Requester (any role) submits proposal
2. All three roles review within 24 hours
3. Consensus decision or designated authority approves
4. Responsible role implements within agreed timeframe

---

## Audit and Compliance

### Audit Logs
- **Location**: `/var/log/iNixos-Hive/`
- **Retention**: 90 days minimum
- **Format**: ISO 8601 timestamps, structured events
- **Access**: Observer has read access, all roles can write

### Change Tracking
- All configuration changes tracked in version control
- Service state changes logged to audit logs
- Decision rationale documented for major changes

### Review Cycles
- **Weekly**: Observer provides health summary
- **Monthly**: Architect reviews structural coherence
- **Quarterly**: All roles participate in governance review

---

## References

- [docs/chakras.md](../chakras.md) - Chakra ecosystem details
- [docs/runbooks/safe_unshare_rebuild.md](safe_unshare_rebuild.md) - Safe rebuild procedure
- `scripts/field-scaffold.sh` - Scaffolding tool
- `scripts/diag-capture.sh` - Diagnostic capture tool
