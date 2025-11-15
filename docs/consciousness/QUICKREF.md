# Consciousness System - Quick Reference

## Essential Commands

### Installation
```bash
# Clone repository
git clone https://github.com/nexus-infinity/iNixOS-Willowie.git
cd iNixOS-Willowie

# Generate hardware config
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix

# Test build
sudo nixos-rebuild test --flake .#willowie

# Apply configuration
sudo nixos-rebuild switch --flake .#willowie
```

### Validation
```bash
# Run all validation checks
./scripts/validate-consciousness.sh

# Demo Ajna service
./scripts/demo_ajna.sh

# Demo desktop
./scripts/demo_desktop.sh

# Run visualizer
./tools/bumble-bee/bumble-bee-visualizer
```

### Service Management
```bash
# Check Ajna agent
systemctl status ajna-agent
journalctl -u ajna-agent -f

# Test Ajna endpoint
curl localhost:6001/health | jq '.'
curl localhost:6001/metrics

# Check PipeWire
systemctl --user status pipewire

# List all services
systemctl list-units --type=service
```

## Keyboard Shortcuts (Sway)

| Key | Action |
|-----|--------|
| `Mod+1-9` | Switch to chakra workspace 1-9 |
| `Mod+Shift+1-9` | Move window to workspace 1-9 |
| `Mod+b` | Launch bumble bee visualizer |
| `Mod+d` | Application launcher (dmenu) |
| `Mod+Enter` | Open terminal (foot) |
| `Mod+Shift+q` | Close window |
| `Mod+Shift+e` | Exit Sway |

## API Endpoints

### Ajna Agent (Port 6001)

**Health Check:**
```bash
curl http://localhost:6001/health
```

**Metrics:**
```bash
curl http://localhost:6001/metrics
```

## Sacred Geometry Workspaces

1. ● Muladhara (Root)
2. ◐ Svadhisthana (Sacral)
3. ◑ Manipura (Solar)
4. ◒ Anahata (Heart)
5. ◓ Vishuddha (Throat)
6. ◔ Ajna (Third Eye)
7. ○ Sahasrara (Crown)
8. ◈ Soma (Manifestation)
9. ◉ Jnana (Knowledge)

## Configuration Locations

| Component | Path |
|-----------|------|
| Main config | `nixosConfigurations/willowie/configuration.nix` |
| Flake | `flake.nix` |
| Ajna agent | `modules/services/ajna-agent.nix` |
| Desktop | `modules/services/vishuddha-desktop.nix` |
| Sound | `modules/services/sound-field.nix` |
| Models | `modules/services/model-purity.nix` |
| Evidence | `modules/services/manifestation-evidence.nix` |

## Troubleshooting

### Service Won't Start
```bash
# Check status
systemctl status SERVICE-NAME

# View logs
journalctl -u SERVICE-NAME -f

# Restart service
systemctl restart SERVICE-NAME
```

### Port Already in Use
```bash
# Check what's using port 6001
ss -tulpn | grep 6001

# Kill process if needed
sudo kill $(lsof -t -i:6001)
```

### Desktop Issues
```bash
# Validate Sway config
sway --validate

# Check video group membership
groups $USER

# Test Wayland
echo $WAYLAND_DISPLAY
```

## Quick Edits

### Enable/Disable Services
Edit `nixosConfigurations/willowie/configuration.nix`:
```nix
services.ajnaAgent.enable = true;  # or false
services.vishuddhDesktop.enable = true;
services.soundField.enable = true;
```

### Change Ajna Port
```nix
services.ajnaAgent = {
  enable = true;
  port = 6001;  # Change this
};
```

### Rebuild After Changes
```bash
sudo nixos-rebuild switch --flake .#willowie
```

## Development Workflow (DOJO Stages)

1. **S0 - Intent:** Define goal with acceptance criteria
2. **S1 - Research:** Investigate feasibility
3. **S2 - Design:** Architecture and interfaces
4. **S3 - Implementation:** Code and configuration
5. **S4 - Testing:** Local validation with scripts
6. **S5 - Declaration:** Proven with evidence hash

## Resources

- Full docs: `docs/consciousness/README.md`
- Operating agreement: `docs/consciousness/OPERATING-AGREEMENT.md`
- Main README: `README.md`
- Architecture guide: `COPILOT-ARCHITECTURE-GUIDE.md`

---

**Tip:** Keep this reference handy while working with the consciousness system!
