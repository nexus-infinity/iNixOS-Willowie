{ pkgs, lib, ... }:

pkgs.buildNpmPackage rec {
  pname = "atlas-bridge";
  version = "1.0.0";

  src = ../../dot-hive/atlas-bridge;

  # This will fail on first build and give us the correct hash
  npmDepsHash = lib.fakeHash;

  # Allow npm to write to cache during build
  makeCacheWritable = true;
  
  # Use legacy peer deps to avoid strict dependency resolution
  npmFlags = [ "--legacy-peer-deps" ];

  # buildNpmPackage automatically handles bin entries from package.json
  # atlas-bridge.js already has #!/usr/bin/env node shebang

  meta = with lib; {
    description = "MQTT to WebSocket bridge for ATLAS Frontend";
    mainProgram = "atlas-bridge";
  };
}
