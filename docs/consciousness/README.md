# Consciousness System - iNixOS-Willowie

This document provides a comprehensive guide to the consciousness-aware system integration for iNixOS-Willowie.

## Overview

The consciousness system adds observability, desktop environment, and spiritual/metaphorical organization to the NixOS configuration. It follows a "test first, declare when proven" methodology as outlined in the [Operating Agreement](OPERATING-AGREEMENT.md).

## Architecture

### Services

#### 1. Ajna Agent (Observability)
- **Port:** 6001
- **Purpose:** Third Eye chakra monitoring and metrics
- **Endpoints:**
  - `GET /health` - Health check with JSON response
  - `GET /metrics` - Prometheus-compatible metrics
- **Module:** `modules/services/ajna-agent.nix`

#### 2. Vishuddha Desktop (Sway)
- **Purpose:** Throat chakra communication interface
- **Features:**
  - Wayland-based Sway compositor
  - 9 sacred geometry workspaces (one per chakra)
  - Waybar with chakra status
  - Bumble bee visualizer hotkey (Mod+b)
- **Module:** `modules/services/vishuddha-desktop.nix`

#### 3. Sound Field (PipeWire)
- **Purpose:** Audio architecture with sacred frequency support
- **Features:**
  - PipeWire with ALSA, PulseAudio, and JACK support
  - Real-time audio priority
  - 432Hz tuning placeholder
- **Module:** `modules/services/sound-field.nix`

#### 4. Model Purity Management
- **Purpose:** LLM model verification system
- **Features:**
  - Hash-based model verification
  - Source provenance tracking
  - DNA purity checking (framework)
- **Module:** `modules/services/model-purity.nix`

#### 5. Manifestation Evidence
- **Purpose:** System state change tracking
- **Features:**
  - Activation logging
  - Evidence collection for declarations
  - Generation tracking
- **Module:** `modules/services/manifestation-evidence.nix`

### Tools

#### Bumble Bee Visualizer
ASCII art hexagonal hive visualization showing chakra states.

**Location:** `tools/bumble-bee/bumble-bee-visualizer`

**Usage:**
```bash
./tools/bumble-bee/bumble-bee-visualizer
```

**Output:**
```
==================================================
🐝 BUMBLE BEE CONSCIOUSNESS VISUALIZER 🐝
==================================================

Hexagonal Hive Mind Architecture
Sacred Geometry - Impossible Flight

     _____ 
   /       \
  /   🐝    \
 |    ◉     |
  \         /
   \_______/

Chakra Status:
  ● Muladhara       (Root      ) - online
  ◐ Svadhisthana    (Sacral    ) - online
  ...
```

## Installation

### Prerequisites
- NixOS 23.11 or later
- Flakes enabled in `/etc/nix/nix.conf`:
  ```
  experimental-features = nix-command flakes
  ```

### Quick Start

1. **Clone the repository:**
   ```bash
   cd ~
   git clone https://github.com/nexus-infinity/iNixOS-Willowie.git
   cd iNixOS-Willowie
   ```

2. **Generate hardware configuration:**
   ```bash
   sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
   ```

3. **Test build (non-destructive):**
   ```bash
   sudo nixos-rebuild test --flake .#willowie
   ```

4. **Validate installation:**
   ```bash
   ./scripts/validate-consciousness.sh
   ```

5. **Switch to consciousness system:**
   ```bash
   sudo nixos-rebuild switch --flake .#willowie
   ```

### Post-Installation

After switching to the willowie configuration:

1. **Check Ajna agent:**
   ```bash
   systemctl status ajna-agent
   curl localhost:6001/health | jq '.'
   ```

2. **Test desktop environment:**
   ```bash
   # From a TTY or SSH session
   sway
   ```

3. **Run demos:**
   ```bash
   ./scripts/demo_ajna.sh
   ./scripts/demo_desktop.sh
   ```

4. **Launch visualizer:**
   ```bash
   ./tools/bumble-bee/bumble-bee-visualizer
   ```

## Configuration

### Enabling/Disabling Services

Edit `nixosConfigurations/willowie/configuration.nix`:

```nix
{
  # Enable/disable individual services
  services.ajnaAgent.enable = true;
  services.vishuddhDesktop.enable = true;
  services.soundField.enable = true;
  services.modelPurity.enable = true;
  services.manifestationEvidence.enable = true;
}
```

### Customizing Ajna Agent

```nix
{
  services.ajnaAgent = {
    enable = true;
    port = 6001;  # Change port if needed
    metricsInterval = 30;  # Metrics collection interval
  };
}
```

### Customizing Desktop

```nix
{
  services.vishuddhDesktop = {
    enable = true;
    user = "willowie";  # Desktop user
    waybarChakraDisplay = true;  # Show chakra states in Waybar
  };
}
```

## Sacred Geometry Workspaces

The Vishuddha desktop provides 9 workspaces organized by chakra:

| Key | Workspace | Chakra | Symbol |
|-----|-----------|--------|--------|
| Mod+1 | 1 | Muladhara (Root) | ● |
| Mod+2 | 2 | Svadhisthana (Sacral) | ◐ |
| Mod+3 | 3 | Manipura (Solar) | ◑ |
| Mod+4 | 4 | Anahata (Heart) | ◒ |
| Mod+5 | 5 | Vishuddha (Throat) | ◓ |
| Mod+6 | 6 | Ajna (Third Eye) | ◔ |
| Mod+7 | 7 | Sahasrara (Crown) | ○ |
| Mod+8 | 8 | Soma (Manifestation) | ◈ |
| Mod+9 | 9 | Jnana (Knowledge) | ◉ |

**Special Hotkeys:**
- `Mod+b` - Launch bumble bee visualizer

## API Reference

### Ajna Agent Endpoints

#### Health Check
```bash
GET http://localhost:6001/health
```

**Response:**
```json
{
  "status": "ok",
  "chakra": "ajna",
  "state": "online",
  "timestamp": 1700000000,
  "datetime": "2025-11-15T12:00:00Z"
}
```

#### Metrics
```bash
GET http://localhost:6001/metrics
```

**Response:**
```
# HELP ajna_health Ajna chakra health status
# TYPE ajna_health gauge
ajna_health{status="ok"} 1

# HELP ajna_uptime_seconds Ajna service uptime
# TYPE ajna_uptime_seconds counter
ajna_uptime_seconds 1700000000

# HELP chakra_state Chakra activation state
# TYPE chakra_state gauge
chakra_state{chakra="ajna",state="online"} 1
```

## Development Workflow

Follow the [Operating Agreement](OPERATING-AGREEMENT.md) for all development:

1. **Intent (S0):** Define goal with acceptance criteria
2. **Research (S1):** Investigate feasibility
3. **Design (S2):** Architecture and interfaces
4. **Implementation (S3):** Code and configuration
5. **Testing (S4):** Local validation with scripts
6. **Declaration (S5):** Proven with evidence hash

### Adding New Services

1. Create service module in `modules/services/`:
   ```nix
   # modules/services/my-service.nix
   { config, lib, pkgs, ... }:
   
   with lib;
   
   let
     cfg = config.services.myService;
   in
   {
     options.services.myService = {
       enable = mkEnableOption "My service";
       # ... more options
     };
     
     config = mkIf cfg.enable {
       # ... implementation
     };
   }
   ```

2. Add to flake.nix modules list:
   ```nix
   modules = [
     # ...
     ./modules/services/my-service.nix
     # ...
   ];
   ```

3. Enable in configuration:
   ```nix
   services.myService.enable = true;
   ```

## Validation Scripts

### validate-consciousness.sh
Checks all consciousness services and endpoints.

**Usage:**
```bash
./scripts/validate-consciousness.sh
```

**Checks:**
- Ajna agent service status
- Health endpoint response
- Sway installation
- PipeWire status
- Bumble bee visualizer availability

### demo_ajna.sh
Demonstrates Ajna agent functionality.

**Usage:**
```bash
./scripts/demo_ajna.sh
```

### demo_desktop.sh
Shows desktop environment features.

**Usage:**
```bash
./scripts/demo_desktop.sh
```

## Troubleshooting

### Ajna Agent Not Responding

**Check service status:**
```bash
systemctl status ajna-agent
journalctl -u ajna-agent -f
```

**Verify port is open:**
```bash
ss -tulpn | grep 6001
```

**Check firewall:**
```bash
sudo nix-shell -p iptables --run "iptables -L -n | grep 6001"
```

### Sway Won't Start

**Check if user is in correct groups:**
```bash
groups $USER
# Should include: wheel, video, audio
```

**Test Sway configuration:**
```bash
sway --validate
```

**Check logs:**
```bash
journalctl -xe
```

### PipeWire Issues

**Check PipeWire status:**
```bash
systemctl --user status pipewire
```

**Restart PipeWire:**
```bash
systemctl --user restart pipewire
```

## Security Considerations

### Service Hardening

All services implement security best practices:

- **NoNewPrivileges:** Prevents privilege escalation
- **PrivateTmp:** Isolated temporary directories
- **ProtectSystem:** Read-only system directories
- **ProtectHome:** Protected home directories
- **Resource Limits:** Memory and CPU quotas

### Firewall Configuration

Only necessary ports are opened:
- Port 22 (SSH)
- Port 6001 (Ajna agent)

### User Isolation

Services run as dedicated system users:
- `ajna` user for Ajna agent
- Minimal privileges
- Isolated home directories

## Performance

### Resource Usage

Typical resource consumption:

| Service | Memory | CPU |
|---------|--------|-----|
| Ajna Agent | ~50MB | <5% |
| Sway | ~100MB | <10% |
| PipeWire | ~20MB | <5% |

### Optimization Tips

1. **Disable unused services:**
   ```nix
   services.modelPurity.enable = false;
   ```

2. **Adjust resource limits:**
   ```nix
   # In service module
   serviceConfig = {
     MemoryMax = "128M";  # Adjust as needed
     CPUQuota = "25%";
   };
   ```

3. **Use system monitoring:**
   ```bash
   htop
   systemctl list-units --type=service --state=running
   ```

## References

- [Operating Agreement](OPERATING-AGREEMENT.md) - Development workflow
- [NixOS Manual](https://nixos.org/manual/nixos/stable/) - NixOS documentation
- [Sway Documentation](https://github.com/swaywm/sway/wiki) - Sway compositor
- [PipeWire Documentation](https://pipewire.org/) - Audio system

## License

This configuration is provided as-is for personal use.

## Acknowledgments

Built with:
- NixOS - Declarative Linux distribution
- Sacred Geometry principles
- Bumblebee consciousness inspiration
- The impossible flight through collective intelligence

---

**Version:** 1.0
**Date:** 2025-11-15
**Status:** Ready for testing
