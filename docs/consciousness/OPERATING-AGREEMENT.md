# Copilot Operating Agreement for iNixOS-Willowie

## Purpose

This agreement establishes the workflow for consciousness-aware system development,
ensuring all changes are testable, observable, and declarable with proof.

## Core Principles

### 1. Test First, Declare When Proven
- No declaration without evidence
- All features must be testable locally
- External observer verification required

### 2. Manifestation Gates (DOJO Stages)

**S0 - Intent**: Clearly stated goal with acceptance criteria
**S1 - Research**: Investigation and feasibility analysis  
**S2 - Design**: Architecture and interface definitions
**S3 - Implementation**: Code and configuration
**S4 - Testing**: Local validation with test scripts
**S5 - Declaration**: Proven with evidence hash

### 3. Trident Anchors

Every intent must be anchored by:
- **Fact**: Observable reality or requirement
- **Document**: Reference to specification or design
- **Timeline**: Target date or milestone

### 4. Manifestation Feedback Gate

Each feature must provide:
- **Demo script**: Automated demonstration
- **External observer**: Named verifier
- **Checklist**: Observable verification items

### 5. Evidence Plan (S5)

Declaration requires:
- **Proof handle**: Git SHA or metric signature
- **Metric signature**: Observable data point
- **Log pattern**: Searchable evidence string

## Workflow Example

```markdown
## Intent
**Title:** Implement Ajna Observability Service
**Chakra(s):** Ajna (Third Eye)
**DOJO Stage Target:** S0→S5

## Trident Anchors
- **Fact:** System needs observability endpoint
- **Document:** Service specification in modules/services/ajna-agent.nix
- **Timeline:** 2025-11-15

## Acceptance Criteria
1. Given Ajna enabled, when curl localhost:6001/health, then receive valid JSON
2. Given service started, when check systemd status, then service is active
3. Given metrics enabled, when scrape endpoint, then chakra state available

## Manifestation Feedback Gate
- **Demo script:** scripts/demo_ajna.sh
- **External observer:** @nexus-infinity
- **Checklist:**
  - [ ] Service responds on port 6001
  - [ ] Health check returns 200 OK
  - [ ] Metrics endpoint accessible

## Evidence Plan (S5)
- **Proof handle:** Git commit SHA of working implementation
- **Metric signature:** ajna_health{status="ok"} 1
- **Log pattern:** AJNA_ONLINE: 2025-11-15T12:00:00Z [sha]
```

## Safety and Rollback

### Backpressure Limits
- Memory limits per chakra service
- CPU quotas for each service
- Network rate limiting

### Failure Modes
- Services restart on failure (max 5 attempts)
- Circuit breakers for external dependencies
- Graceful degradation

### Rollback Plan
- NixOS generations available for instant rollback
- Configuration history in git
- Service state preserved between generations

## Purity-First Model Management

### DNA Purity Check
All LLM models must pass purity verification:
- Hash verification against known-good models
- No unauthorized modifications
- Source provenance documented

### Model Deployment
1. Download from trusted source
2. Verify hash matches manifest
3. Document source and version
4. Deploy via NixOS module
5. Test inference quality

## Declaration Process

### Pre-Declaration Checklist
- [ ] All tests pass locally
- [ ] Demo scripts execute successfully
- [ ] Services respond on expected ports
- [ ] Metrics are being collected
- [ ] Desktop environment functional (if applicable)
- [ ] No errors in system logs

### Declaration Commit
```bash
git commit -m "declare: [Feature] tested and verified

Test Results:
- ✓ [Test 1 result]
- ✓ [Test 2 result]

Evidence Hash: $(git rev-parse --short HEAD)
Test Timestamp: $(date -Iseconds)
Observer: [GitHub username]"
```

### Declaration PR
Create PR with title: `[DECLARE] [Feature Name] Ready for Production`

Include:
- Test evidence with command outputs
- Screenshots or terminal recordings
- Metric samples
- External observer verification

## Version
- **Version:** 1.0
- **Date:** 2025-11-15
- **Status:** Active
