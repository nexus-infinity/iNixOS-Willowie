# Service Fix Documentation

## Overview
This document describes the fixes made to the atlas-frontend, metatron-cube, and tata8i-pulse-engine services.

## Changes Made

### 1. Atlas Frontend Service

**Problem**: The service was trying to run a non-existent `server.js` file from `/var/lib/atlas-frontend/`.

**Solution**: Created a proper Nix package for the atlas-bridge.js implementation.

#### New Files
- `modules/services/atlas-frontend-package.nix` - Nix package definition using buildNpmPackage
- `dot-hive/atlas-frontend/package.json` - npm package manifest with dependencies (express, ws, mqtt)
- `dot-hive/atlas-frontend/package-lock.json` - npm dependency lockfile

#### Modified Files
- `modules/services/atlas-frontend.nix`:
  - Changed `ExecStart` from `${pkgs.nodejs_18}/bin/node server.js` to `${atlas-bridge}/bin/atlas-bridge`
  - Removed `WorkingDirectory` directive
  - Updated environment variables to match atlas-bridge.js expectations:
    - `PORT` → `ATLAS_WS_PORT`
    - `PULSE_ENGINE_SOURCE` → removed (not used by atlas-bridge.js)
    - `PULSE_SYNC_SOURCE` → `ATLAS_PULSE_SYNC`
    - Added `ATLAS_MQTT_BROKER` and `ATLAS_HTTP_PORT`
  - Updated service options:
    - `listenPort` → `wsPort` (WebSocket port)
    - Added `httpPort` (HTTP API port)
    - `pulseEngineSource` → removed
    - `pulseSyncSource` → `pulseSyncTopic` (just the topic, not full URL)
    - Added `mqttBroker` (broker URL)

- `nixosConfigurations/BearsiMac/configuration.nix`:
  - Updated atlas-frontend configuration to use new option names
  - Added `httpPort = 3001`

### 2. Metatron Cube Service

**Problem**: Service was enabled but had no systemd service definition, causing boot failures.

**Solution**: Added a placeholder systemd service that won't block boot.

#### Modified Files
- `modules/services/metatron-cube.nix`:
  - Added `systemd.services.metatron-cube` with `Type = "oneshot"`
  - Service logs activation message and exits cleanly
  - `RemainAfterExit = true` ensures the service appears as "active" in systemctl

### 3. TATA 8i Pulse Engine Service

**Problem**: Service was enabled but had no systemd service definition, causing boot failures.

**Solution**: Added a placeholder systemd service that won't block boot.

#### Modified Files
- `modules/services/tata8i-pulse-engine.nix`:
  - Added `systemd.services.tata8i-pulse-engine` with `Type = "oneshot"`
  - Service logs activation message and exits cleanly
  - `RemainAfterExit = true` ensures the service appears as "active" in systemctl

## Testing

### Build the Configuration
```bash
# On a NixOS system with the flake:
nix build .#nixosConfigurations.BearsiMac.config.system.build.toplevel

# Or to deploy:
sudo nixos-rebuild switch --flake .#BearsiMac
```

### First Build Note - IMPORTANT
On the first build, the atlas-frontend package will fail with a hash mismatch error. **This is expected and intentional.** 

The error will look like:
```
error: hash mismatch in fixed-output derivation '/nix/store/...':
  specified: sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
  got:        sha256-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX=
```

Copy the "got" hash from the error message and update line 16 in `modules/services/atlas-frontend-package.nix`:
```nix
npmDepsHash = "sha256-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX=";
```

Then rebuild. This is the standard NixOS workflow for packages with remote dependencies.

### Check Service Status
After boot, you can check the status of the services:

```bash
# Atlas Frontend (should be running)
systemctl status atlas-frontend

# Metatron Cube (placeholder, will show as active/exited)
systemctl status metatron-cube

# TATA 8i Pulse Engine (placeholder, will show as active/exited)
systemctl status tata8i-pulse-engine
```

### Atlas Frontend Endpoints
Once running, atlas-frontend provides:
- WebSocket endpoint: `ws://localhost:3000/ws`
- HTTP API endpoint: `http://localhost:3001`
- Health check: `GET http://localhost:3001/health`
- Publish endpoint: `POST http://localhost:3001/publish`

## Future Work

### Metatron Cube
The metatron-cube service currently just logs an activation message. Future implementation should:
- Implement the actual Q-dimensional translation service
- Expose the API endpoints defined in `sacred_geometry/metatron_cube_translator.nix`
- Handle the sacred geometry bridging functionality

### TATA 8i Pulse Engine
The tata8i-pulse-engine service currently just logs an activation message. Future implementation should:
- Implement the actual chakra synchronization service
- Coordinate pulse across all chakra nodes
- Integrate with MQTT for pulse distribution

## Notes

- The atlas-bridge.js script expects an MQTT broker to be running on `localhost:1883`
- If you need to change ports or the MQTT broker, update the configuration in `nixosConfigurations/BearsiMac/configuration.nix`
- The placeholder services (metatron-cube and tata8i-pulse-engine) won't prevent the system from booting, but also don't provide functionality yet
