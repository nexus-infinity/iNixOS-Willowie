{ config, lib, pkgs, ... }:

{
  imports = [
    ../modules/services/htm-simple.nix
  ];

  services.htmTemporalMemory = {
    enable = true;
    anomalyThreshold = 0.95;
    spatialPoolerDimensions = 2048;
    temporalMemoryCells = 32;
    websocketPort = 6002;
  };
}
