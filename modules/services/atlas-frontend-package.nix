{ pkgs, lib, ... }:

pkgs.buildNpmPackage rec {
  pname = "atlas-bridge";
  version = "1.0.0";

  src = ../../dot-hive/atlas-frontend;

  # NOTE: lib.fakeHash will cause build to fail on first attempt.
  # This is intentional - NixOS will provide the correct hash in the error message.
  # Replace this with the correct hash after first build attempt.
  # Example: npmDepsHash = "sha256-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX=";
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
