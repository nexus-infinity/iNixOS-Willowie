{ config, lib, pkgs, ... }:

with lib;

{
  options.services.htmTemporalMemory = {
    enable = mkEnableOption "HTM Temporal Memory";
    
    anomalyThreshold = mkOption {
      type = types.float;
      default = 0.95;
      description = "Anomaly threshold";
    };
    
    spatialPoolerDimensions = mkOption {
      type = types.int;
      default = 2048;
    };
    
    temporalMemoryCells = mkOption {
      type = types.int;
      default = 32;
    };
    
    websocketPort = mkOption {
      type = types.int;
      default = 6002;
    };
  };
  
  config = mkIf config.services.htmTemporalMemory.enable {
    environment.systemPackages = with pkgs; [
      (python3.withPackages (ps: with ps; [ numpy scipy pandas ]))
    ];
  };
}
