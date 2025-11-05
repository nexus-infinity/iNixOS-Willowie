{ pkgs, lib, ... }:

pkgs.buildNpmPackage rec {
  pname = "atlas-bridge";
  version = "1.0.0";

  src = ../../dot-hive/atlas-frontend;

  # ⚠️ IMPORTANT: lib.fakeHash will cause build to fail on first attempt.
  # This is the standard NixOS workflow for packages with remote dependencies.
  # Steps to fix:
  # 1. Run: nix build .#nixosConfigurations.BearsiMac.config.system.build.toplevel
  # 2. Copy the "got:" hash from the error message
  # 3. Replace lib.fakeHash below with the hash (e.g., "sha256-ABC123...=")
  # 4. Rebuild
  npmDepsHash = lib.fakeHash;

  # buildNpmPackage automatically handles bin entries from package.json
  # atlas-bridge.js already has #!/usr/bin/env node shebang

  meta = with lib; {
    description = "MQTT to WebSocket bridge for ATLAS Frontend";
    mainProgram = "atlas-bridge";
  };
}
