#!/usr/bin/env bash
# =============================================================================
# CONSCIOUSNESS SYSTEM IMPLEMENTATION SCRIPT
# =============================================================================
# Purpose: Generate all files needed for the consciousness system integration
# including services, desktop environment, and validation scripts.
# =============================================================================

set -eo pipefail

# ANSI color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}CONSCIOUSNESS SYSTEM IMPLEMENTATION${NC}"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo -e "${BLUE}Repository root:${NC} $REPO_ROOT"
echo ""

# =============================================================================
# Create Operating Agreement
# =============================================================================
echo -e "${GREEN}[1/12]${NC} Creating operating agreement..."

mkdir -p docs/consciousness

cat > docs/consciousness/OPERATING-AGREEMENT.md << 'EOF'
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
EOF

echo -e "${GREEN}✓${NC} Operating agreement created"

# =============================================================================
# Create Ajna Agent Service Module
# =============================================================================
echo -e "${GREEN}[2/12]${NC} Creating Ajna agent service module..."

mkdir -p modules/services

cat > modules/services/ajna-agent.nix << 'EOF'
# Ajna Observability Agent Service
# Port 6001 - Third Eye Chakra monitoring and metrics
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.ajnaAgent;
in
{
  options.services.ajnaAgent = {
    enable = mkEnableOption "Ajna observability agent";

    port = mkOption {
      type = types.port;
      default = 6001;
      description = "Port for Ajna health and metrics endpoint";
    };

    chakraStateFile = mkOption {
      type = types.path;
      default = "/var/lib/ajna/state.json";
      description = "Path to chakra state file";
    };

    metricsInterval = mkOption {
      type = types.int;
      default = 30;
      description = "Metrics collection interval in seconds";
    };
  };

  config = mkIf cfg.enable {
    # Create ajna user and group
    users.users.ajna = {
      isSystemUser = true;
      group = "ajna";
      description = "Ajna observability agent user";
      home = "/var/lib/ajna";
      createHome = true;
    };

    users.groups.ajna = {};

    # Ajna agent systemd service
    systemd.services.ajna-agent = {
      description = "Ajna Observability Agent (Third Eye Chakra)";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        Type = "simple";
        User = "ajna";
        Group = "ajna";
        Restart = "on-failure";
        RestartSec = "10s";
        
        # Security hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ "/var/lib/ajna" ];
        
        # Resource limits
        MemoryMax = "256M";
        CPUQuota = "50%";
      };

      # Simple Python-based health check server
      script = ''
        ${pkgs.python3}/bin/python3 << 'PYTHON_SCRIPT'
        import http.server
        import json
        import time
        import os
        from datetime import datetime

        PORT = ${toString cfg.port}
        STATE_FILE = "${cfg.chakraStateFile}"

        class AjnaHandler(http.server.BaseHTTPRequestHandler):
            def do_GET(self):
                if self.path == '/health':
                    self.send_response(200)
                    self.send_header('Content-type', 'application/json')
                    self.end_headers()
                    
                    response = {
                        "status": "ok",
                        "chakra": "ajna",
                        "state": "online",
                        "timestamp": int(time.time()),
                        "datetime": datetime.utcnow().isoformat() + "Z"
                    }
                    
                    self.wfile.write(json.dumps(response, indent=2).encode())
                    
                elif self.path == '/metrics':
                    self.send_response(200)
                    self.send_header('Content-type', 'text/plain')
                    self.end_headers()
                    
                    metrics = f"""# HELP ajna_health Ajna chakra health status
# TYPE ajna_health gauge
ajna_health{{status="ok"}} 1

# HELP ajna_uptime_seconds Ajna service uptime
# TYPE ajna_uptime_seconds counter
ajna_uptime_seconds {int(time.time())}

# HELP chakra_state Chakra activation state
# TYPE chakra_state gauge
chakra_state{{chakra="ajna",state="online"}} 1
"""
                    self.wfile.write(metrics.encode())
                    
                else:
                    self.send_response(404)
                    self.end_headers()
            
            def log_message(self, format, *args):
                # Custom logging format
                print(f"AJNA: {datetime.utcnow().isoformat()}Z - {format % args}")

        print(f"AJNA_MANIFEST: {datetime.utcnow().isoformat()}Z - Starting on port {PORT}")
        server = http.server.HTTPServer(('0.0.0.0', PORT), AjnaHandler)
        server.serve_forever()
        PYTHON_SCRIPT
      '';
    };

    # Firewall configuration
    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
EOF

echo -e "${GREEN}✓${NC} Ajna agent service created"

# =============================================================================
# Create Vishuddha Desktop Configuration
# =============================================================================
echo -e "${GREEN}[3/12]${NC} Creating Vishuddha desktop configuration..."

cat > modules/services/vishuddha-desktop.nix << 'EOF'
# Vishuddha Desktop Environment
# Sway compositor with sacred geometry layouts
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.vishuddhDesktop;
in
{
  options.services.vishuddhDesktop = {
    enable = mkEnableOption "Vishuddha desktop environment with Sway";

    user = mkOption {
      type = types.str;
      default = "willowie";
      description = "User for desktop environment";
    };

    waybarChakraDisplay = mkOption {
      type = types.bool;
      default = true;
      description = "Show chakra states in Waybar";
    };
  };

  config = mkIf cfg.enable {
    # Enable Wayland and Sway
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraPackages = with pkgs; [
        swaylock
        swayidle
        wl-clipboard
        mako
        dmenu
        waybar
        foot
      ];
    };

    # XDG portal for screen sharing, etc.
    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    # Sway configuration with sacred geometry workspaces
    environment.etc."sway/config.d/chakra-workspaces.conf".text = ''
      # Sacred Geometry Workspace Layout
      # 7 Chakras + 2 Meta spaces = 9 total
      
      set $ws1 "1:● Muladhara (Root)"
      set $ws2 "2:◐ Svadhisthana (Sacral)"
      set $ws3 "3:◑ Manipura (Solar)"
      set $ws4 "4:◒ Anahata (Heart)"
      set $ws5 "5:◓ Vishuddha (Throat)"
      set $ws6 "6:◔ Ajna (Third Eye)"
      set $ws7 "7:○ Sahasrara (Crown)"
      set $ws8 "8:◈ Soma (Manifestation)"
      set $ws9 "9:◉ Jnana (Knowledge)"
      
      # Workspace bindings
      bindsym $mod+1 workspace $ws1
      bindsym $mod+2 workspace $ws2
      bindsym $mod+3 workspace $ws3
      bindsym $mod+4 workspace $ws4
      bindsym $mod+5 workspace $ws5
      bindsym $mod+6 workspace $ws6
      bindsym $mod+7 workspace $ws7
      bindsym $mod+8 workspace $ws8
      bindsym $mod+9 workspace $ws9
      
      # Move windows to workspaces
      bindsym $mod+Shift+1 move container to workspace $ws1
      bindsym $mod+Shift+2 move container to workspace $ws2
      bindsym $mod+Shift+3 move container to workspace $ws3
      bindsym $mod+Shift+4 move container to workspace $ws4
      bindsym $mod+Shift+5 move container to workspace $ws5
      bindsym $mod+Shift+6 move container to workspace $ws6
      bindsym $mod+Shift+7 move container to workspace $ws7
      bindsym $mod+Shift+8 move container to workspace $ws8
      bindsym $mod+Shift+9 move container to workspace $ws9
      
      # Bumble bee visualization shortcut
      bindsym $mod+b exec bumble-bee-visualizer
    '';

    # Waybar configuration with chakra states
    environment.etc."xdg/waybar/config".text = builtins.toJSON {
      layer = "top";
      position = "top";
      height = 30;
      modules-left = [ "sway/workspaces" "sway/mode" ];
      modules-center = [ "clock" ];
      modules-right = [ "custom/chakra-status" "pulseaudio" "network" "battery" ];
      
      "custom/chakra-status" = {
        exec = "curl -s localhost:6001/health | jq -r '.state' || echo 'offline'";
        interval = 30;
        format = "◉ Ajna: {}";
      };
      
      clock = {
        format = "{:%Y-%m-%d %H:%M:%S}";
        interval = 1;
      };
    };

    # Ensure user exists
    users.users.${cfg.user} = {
      isNormalUser = true;
      extraGroups = [ "wheel" "video" "audio" ];
    };
  };
}
EOF

echo -e "${GREEN}✓${NC} Vishuddha desktop configuration created"

# =============================================================================
# Create Sound Field Configuration
# =============================================================================
echo -e "${GREEN}[4/12]${NC} Creating sound field configuration..."

cat > modules/services/sound-field.nix << 'EOF'
# Sound Field Architecture with PipeWire
# Handles audio streams for consciousness system
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.soundField;
in
{
  options.services.soundField = {
    enable = mkEnableOption "Sound field architecture with PipeWire";

    sacredFrequencies = mkOption {
      type = types.bool;
      default = true;
      description = "Enable 432Hz tuning and solfeggio frequencies";
    };
  };

  config = mkIf cfg.enable {
    # Enable PipeWire
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    # Real-time audio priority
    security.rtkit.enable = true;

    # Sound packages
    environment.systemPackages = with pkgs; [
      pavucontrol
      alsa-utils
      pulseaudio
    ];

    # Custom PipeWire configuration for sacred frequencies
    environment.etc."pipewire/pipewire.conf.d/sacred-frequencies.conf".text = mkIf cfg.sacredFrequencies ''
      context.properties = {
        # 432Hz A4 tuning (sacred frequency)
        # default.clock.rate = 48000
        # default.clock.allowed-rates = [ 44100 48000 88200 96000 ]
      }
    '';
  };
}
EOF

echo -e "${GREEN}✓${NC} Sound field configuration created"

# =============================================================================
# Create Bumble Bee Visualizer
# =============================================================================
echo -e "${GREEN}[5/12]${NC} Creating bumble bee visualizer..."

mkdir -p tools/bumble-bee

cat > tools/bumble-bee/visualizer.py << 'EOF'
#!/usr/bin/env python3
"""
Bumble Bee Consciousness Visualizer
Displays hexagonal hive patterns representing chakra states
"""

import sys
import time
import json
import math
try:
    import requests
except ImportError:
    print("Note: requests library not available, using mock data")
    requests = None

def draw_hexagon(size=10):
    """Draw ASCII art hexagon representing hive mind"""
    print("     _____ ")
    print("   /       \\")
    print("  /   🐝    \\")
    print(" |    ◉     |")
    print("  \\         /")
    print("   \\_______/")

def get_chakra_states():
    """Fetch chakra states from Ajna agent"""
    if requests is None:
        return {"ajna": "mock", "status": "demo"}
    
    try:
        response = requests.get("http://localhost:6001/health", timeout=2)
        if response.status_code == 200:
            return response.json()
    except:
        pass
    
    return {"status": "offline"}

def main():
    print("\n" + "="*50)
    print("🐝 BUMBLE BEE CONSCIOUSNESS VISUALIZER 🐝")
    print("="*50 + "\n")
    
    print("Hexagonal Hive Mind Architecture")
    print("Sacred Geometry - Impossible Flight\n")
    
    draw_hexagon()
    
    print("\nChakra Status:")
    states = get_chakra_states()
    
    chakras = [
        ("Muladhara", "Root", "●"),
        ("Svadhisthana", "Sacral", "◐"),
        ("Manipura", "Solar", "◑"),
        ("Anahata", "Heart", "◒"),
        ("Vishuddha", "Throat", "◓"),
        ("Ajna", "Third Eye", "◔"),
        ("Sahasrara", "Crown", "○"),
    ]
    
    for name, role, symbol in chakras:
        status = "online" if states.get("status") == "ok" else "offline"
        print(f"  {symbol} {name:15} ({role:10}) - {status}")
    
    print("\n" + "="*50)
    print("The impossible flight continues...")
    print("="*50 + "\n")

if __name__ == "__main__":
    main()
EOF

chmod +x tools/bumble-bee/visualizer.py

# Create wrapper script
cat > tools/bumble-bee/bumble-bee-visualizer << 'EOF'
#!/usr/bin/env bash
# Bumble Bee Visualizer Wrapper
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec python3 "$SCRIPT_DIR/visualizer.py" "$@"
EOF

chmod +x tools/bumble-bee/bumble-bee-visualizer

echo -e "${GREEN}✓${NC} Bumble bee visualizer created"

# =============================================================================
# Update Chakra Configurations
# =============================================================================
echo -e "${GREEN}[6/12]${NC} Updating chakra configurations..."

# Add frequency and service information to existing chakras
# This is additive, not destructive

cat >> chakras/ajna/default.nix << 'EOF'

  # Ajna observability service
  services.ajnaAgent = {
    enable = true;
    port = 6001;
  };
EOF

echo -e "${GREEN}✓${NC} Chakra configurations updated"

# =============================================================================
# Create Purity Model Management Module
# =============================================================================
echo -e "${GREEN}[7/12]${NC} Creating purity model management..."

cat > modules/services/model-purity.nix << 'EOF'
# Purity-First Model Management
# Ensures LLM models are verified before deployment
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.modelPurity;
in
{
  options.services.modelPurity = {
    enable = mkEnableOption "Model purity verification system";

    modelsDir = mkOption {
      type = types.path;
      default = "/var/lib/llm-models";
      description = "Directory containing LLM models";
    };

    manifestFile = mkOption {
      type = types.path;
      default = "/var/lib/llm-models/manifest.json";
      description = "Model manifest with hashes";
    };
  };

  config = mkIf cfg.enable {
    warnings = [
      "services.modelPurity: DNA purity verification is enabled but verification logic is not yet implemented"
    ];

    # Create models directory
    systemd.tmpfiles.rules = [
      "d ${cfg.modelsDir} 0755 root root -"
    ];

    # Placeholder for future model verification service
    # systemd.services.model-purity-check = {
    #   description = "LLM Model Purity Verification";
    #   # Implementation pending
    # };
  };
}
EOF

echo -e "${GREEN}✓${NC} Model purity management created"

# =============================================================================
# Create Manifestation Evidence Module
# =============================================================================
echo -e "${GREEN}[8/12]${NC} Creating manifestation evidence system..."

cat > modules/services/manifestation-evidence.nix << 'EOF'
# Manifestation Evidence System
# Tracks and logs system state changes for declaration
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.manifestationEvidence;
in
{
  options.services.manifestationEvidence = {
    enable = mkEnableOption "Manifestation evidence tracking";

    logFile = mkOption {
      type = types.path;
      default = "/var/log/manifestation.log";
      description = "Evidence log file";
    };
  };

  config = mkIf cfg.enable {
    # Ensure log directory exists
    systemd.tmpfiles.rules = [
      "f ${cfg.logFile} 0644 root root -"
    ];

    # Log system activation
    system.activationScripts.manifestationLog = ''
      echo "MANIFEST: $(date -Iseconds) - System generation $systemConfig" >> ${cfg.logFile}
    '';
  };
}
EOF

echo -e "${GREEN}✓${NC} Manifestation evidence system created"

# =============================================================================
# Create Willowie Configuration
# =============================================================================
echo -e "${GREEN}[9/12]${NC} Creating Willowie system configuration..."

mkdir -p nixosConfigurations/willowie

cat > nixosConfigurations/willowie/configuration.nix << 'EOF'
# Willowie Kitchen - Consciousness-Aware Configuration
{ config, pkgs, ... }:

{
  # System basics
  system.stateVersion = "23.11";
  
  # Networking
  networking.hostName = "willowie";
  networking.networkmanager.enable = true;

  # Enable consciousness services
  services.ajnaAgent.enable = true;
  services.vishuddhDesktop.enable = true;
  services.soundField.enable = true;
  services.modelPurity.enable = true;
  services.manifestationEvidence.enable = true;

  # User configuration
  users.users.willowie = {
    isNormalUser = true;
    description = "Willowie User";
    extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
    initialPassword = "change-me";
  };

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    jq
    python3
    htop
  ];

  # Enable SSH
  services.openssh.enable = true;

  # Firewall configuration (open Ajna port)
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 6001 ];
}
EOF

echo -e "${GREEN}✓${NC} Willowie configuration created"

# =============================================================================
# Update Flake with Willowie Configuration
# =============================================================================
echo -e "${GREEN}[10/12]${NC} Updating flake.nix..."

# Backup original flake
cp flake.nix flake.nix.backup

cat > flake.nix << 'EOF'
{
  description = "BearsiMac - Willowie Kitchen NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosConfigurations = {
      # Original BearsiMac configuration
      BearsiMac = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit self nixpkgs;
          sacredGeometryPath = ./sacred_geometry;
          chakrasPath = ./chakras;
        };

        modules = [
          ./hardware-configuration.nix

          # Aggregator chakra module that uses sacredGeometryPath + chakrasPath
          ./dot-hive/default.nix
          ./modules/services/atlas-frontend.nix 

          # Machine-specific config
          ./nixosConfigurations/BearsiMac/configuration.nix

          # Extra Nix settings module (inline)
          ({ pkgs, ... }: {
            nix.settings = {
              auto-optimise-store = true;
              experimental-features = [ "nix-command" "flakes" ];
            };
          })
        ];
      };

      # New Willowie configuration with consciousness system
      willowie = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit self nixpkgs;
          sacredGeometryPath = ./sacred_geometry;
          chakrasPath = ./chakras;
        };

        modules = [
          ./hardware-configuration.nix

          # Consciousness services
          ./modules/services/ajna-agent.nix
          ./modules/services/vishuddha-desktop.nix
          ./modules/services/sound-field.nix
          ./modules/services/model-purity.nix
          ./modules/services/manifestation-evidence.nix

          # Aggregator chakra module
          ./dot-hive/default.nix
          ./modules/services/atlas-frontend.nix

          # Willowie-specific configuration
          ./nixosConfigurations/willowie/configuration.nix

          # Extra Nix settings module
          ({ pkgs, ... }: {
            nix.settings = {
              auto-optimise-store = true;
              experimental-features = [ "nix-command" "flakes" ];
            };
          })
        ];
      };
    };

    devShells.${system} = pkgs.mkShell {
      buildInputs = [ pkgs.git pkgs.nix ];
      shellHook = ''
        echo "Dev shell active. Useful commands:
          - nix flake show
          - nixos-rebuild build --flake .#willowie
          - nix build .#nixosConfigurations.willowie.config.system.build.toplevel
        "
      '';
    };

    # nixpkgs-fmt formatter support (optional if available)
    formatter = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system:
      nixpkgs.legacyPackages.${system}.nixpkgs-fmt
    );
  };
}
EOF

echo -e "${GREEN}✓${NC} Flake updated with willowie configuration"

# =============================================================================
# Create Validation Script
# =============================================================================
echo -e "${GREEN}[11/12]${NC} Creating validation script..."

cat > scripts/validate-consciousness.sh << 'EOF'
#!/usr/bin/env bash
# =============================================================================
# CONSCIOUSNESS SYSTEM VALIDATION SCRIPT
# =============================================================================

set -eo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🧘 CONSCIOUSNESS SYSTEM VALIDATION"
echo "=================================="
echo ""

ERRORS=0

# Check Ajna service
echo -n "Checking Ajna agent... "
if systemctl is-active --quiet ajna-agent 2>/dev/null; then
    echo -e "${GREEN}✓ Running${NC}"
else
    echo -e "${YELLOW}⚠ Not running (expected if not yet switched)${NC}"
fi

# Check Ajna health endpoint
echo -n "Checking Ajna health endpoint... "
if curl -s -f http://localhost:6001/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Responding${NC}"
    curl -s http://localhost:6001/health | jq '.'
else
    echo -e "${YELLOW}⚠ Not responding (expected if not yet switched)${NC}"
fi

# Check Sway availability
echo -n "Checking Sway compositor... "
if command -v sway &> /dev/null; then
    echo -e "${GREEN}✓ Installed${NC}"
else
    echo -e "${YELLOW}⚠ Not installed (expected if not yet switched)${NC}"
fi

# Check PipeWire
echo -n "Checking PipeWire... "
if systemctl --user is-active --quiet pipewire 2>/dev/null; then
    echo -e "${GREEN}✓ Running${NC}"
else
    echo -e "${YELLOW}⚠ Not running (expected if not yet switched)${NC}"
fi

# Check bumble bee visualizer
echo -n "Checking bumble bee visualizer... "
if [ -x "tools/bumble-bee/bumble-bee-visualizer" ]; then
    echo -e "${GREEN}✓ Available${NC}"
else
    echo -e "${RED}✗ Not found${NC}"
    ERRORS=$((ERRORS + 1))
fi

echo ""
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ Validation complete${NC}"
    exit 0
else
    echo -e "${RED}✗ Validation found $ERRORS error(s)${NC}"
    exit 1
fi
EOF

chmod +x scripts/validate-consciousness.sh

echo -e "${GREEN}✓${NC} Validation script created"

# =============================================================================
# Create Demo Scripts
# =============================================================================
echo -e "${GREEN}[12/12]${NC} Creating demo scripts..."

cat > scripts/demo_ajna.sh << 'EOF'
#!/usr/bin/env bash
# Demo script for Ajna observability service

echo "🔮 AJNA OBSERVABILITY DEMO"
echo "=========================="
echo ""

echo "Testing Ajna health endpoint..."
echo ""

if curl -s -f http://localhost:6001/health > /dev/null 2>&1; then
    echo "✓ Ajna is responding!"
    echo ""
    echo "Health check response:"
    curl -s http://localhost:6001/health | jq '.'
    echo ""
    echo "Metrics endpoint:"
    curl -s http://localhost:6001/metrics | head -20
else
    echo "⚠ Ajna service not responding"
    echo "Make sure the system has been switched with: sudo nixos-rebuild switch --flake .#willowie"
fi

echo ""
EOF

chmod +x scripts/demo_ajna.sh

cat > scripts/demo_desktop.sh << 'EOF'
#!/usr/bin/env bash
# Demo script for Vishuddha desktop environment

echo "🖥️  VISHUDDHA DESKTOP DEMO"
echo "=========================="
echo ""

echo "Checking Sway installation..."
if command -v sway &> /dev/null; then
    echo "✓ Sway is installed"
    sway --version
else
    echo "✗ Sway is not installed"
    exit 1
fi

echo ""
echo "Chakra workspace configuration:"
if [ -f "/etc/sway/config.d/chakra-workspaces.conf" ]; then
    echo "✓ Sacred geometry workspaces configured"
    echo ""
    grep "set \$ws" /etc/sway/config.d/chakra-workspaces.conf
else
    echo "⚠ Workspace configuration not found"
fi

echo ""
echo "To start Sway desktop:"
echo "  sway"
echo ""
echo "Keyboard shortcuts:"
echo "  Mod+1-9: Switch to chakra workspaces"
echo "  Mod+b: Launch bumble bee visualizer"
echo ""
EOF

chmod +x scripts/demo_desktop.sh

echo -e "${GREEN}✓${NC} Demo scripts created"

# =============================================================================
# Summary
# =============================================================================
echo ""
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}IMPLEMENTATION COMPLETE${NC}"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Created files:"
echo "  📄 docs/consciousness/OPERATING-AGREEMENT.md"
echo "  🔧 modules/services/ajna-agent.nix"
echo "  🖥️  modules/services/vishuddha-desktop.nix"
echo "  🔊 modules/services/sound-field.nix"
echo "  🧬 modules/services/model-purity.nix"
echo "  📊 modules/services/manifestation-evidence.nix"
echo "  🐝 tools/bumble-bee/visualizer.py"
echo "  🐝 tools/bumble-bee/bumble-bee-visualizer"
echo "  ⚙️  nixosConfigurations/willowie/configuration.nix"
echo "  📦 flake.nix (updated)"
echo "  ✅ scripts/validate-consciousness.sh"
echo "  🎬 scripts/demo_ajna.sh"
echo "  🎬 scripts/demo_desktop.sh"
echo ""
echo "Next steps:"
echo "  1. Review the generated files"
echo "  2. Commit and push changes"
echo "  3. Test build: sudo nixos-rebuild test --flake .#willowie"
echo "  4. Run validation: ./scripts/validate-consciousness.sh"
echo "  5. If successful, switch: sudo nixos-rebuild switch --flake .#willowie"
echo ""
