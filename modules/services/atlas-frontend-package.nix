{ pkgs, lib, ... }:

pkgs.buildNpmPackage rec {
  pname = "atlas-bridge";
  version = "1.0.0";

  src = ../../dot-hive/atlas-frontend;

  npmDepsHash = lib.fakeHash;

  # Make the script executable
  postInstall = ''
    chmod +x $out/bin/atlas-bridge
  '';

  meta = with lib; {
    description = "MQTT to WebSocket bridge for ATLAS Frontend";
    mainProgram = "atlas-bridge";
  };
}
