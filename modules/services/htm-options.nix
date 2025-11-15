{ config, lib, pkgs, ... }:

with lib;

{
  options.services.htmTemporalMemory = {
    enable = mkEnableOption "HTM Temporal Memory for consciousness monitoring";
    
    anomalyThreshold = mkOption {
      type = types.float;
      default = 0.95;
      description = "Threshold for detecting consciousness anomalies";
    };
    
    mqttBroker = mkOption {
      type = types.str;
      default = "tcp://localhost:1883";
      description = "MQTT broker for consciousness communication";
    };
    
    websocketPort = mkOption {
      type = types.port;
      default = 6002;
      description = "WebSocket port for real-time consciousness stream";
    };
    
    spatialPoolerDimensions = mkOption {
      type = types.int;
      default = 2048;
      description = "Dimensions for spatial pooler (should match Ajna output)";
    };
    
    temporalMemoryCells = mkOption {
      type = types.int;
      default = 32;
      description = "Cells per column in temporal memory";
    };
  };
}
