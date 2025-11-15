{ config, lib, pkgs, ... }:

{
  imports = [
    ../modules/services/htm-config.nix
  ];

  # Enable HTM Temporal Memory
  services.htmTemporalMemory = {
    enable = true;
    anomalyThreshold = 0.95;
    spatialPoolerDimensions = 2048;
    temporalMemoryCells = 32;
    websocketPort = 6002;
  };
}
