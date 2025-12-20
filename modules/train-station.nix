# SOMA Train Station Module
# ==========================
# 🚂 Train Station Orchestrator Service (852 Hz)
#
# Provides central orchestration for SOMA octahedron architecture.
# Routes requests to appropriate vertices using Triadic Handshake protocol.
#
# Position: CENTER of octahedron
# Frequency: 852 Hz (Crown Base - Spiritual Order)
# Function: Orchestration hub, not a service endpoint

{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.field.trainStation;
  fieldCfg = config.field;
  
  # Python service for Train Station orchestrator
  trainStationService = pkgs.writeScriptBin "train-station-orchestrator" ''
    #!${pkgs.python3}/bin/python3
    ${builtins.readFile ../services/train-station/orchestrator.py}
  '';

in {
  options.field.trainStation.serviceEnable = mkEnableOption "Train Station Orchestrator Service" // {
    default = fieldCfg.enable;
  };
  
  options.field.trainStation.port = mkOption {
    type = types.port;
    default = 8520;
    description = "Port for Train Station HTTP API (8520 inspired by 852 Hz)";
  };
  
  options.field.trainStation.logPath = mkOption {
    type = types.path;
    default = "/var/log/SOMA/train-station.log";
    description = "Path to Train Station log file";
  };

  config = mkIf (fieldCfg.enable && cfg.serviceEnable) {
    # Install Train Station service script
    environment.systemPackages = [
      trainStationService
    ];
    
    # Systemd service for Train Station orchestrator
    systemd.services.train-station = {
      description = "🚂 SOMA Train Station Orchestrator (852 Hz)";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      
      serviceConfig = {
        Type = "simple";
        ExecStart = "${trainStationService}/bin/train-station-orchestrator --port ${toString cfg.port} --log-path ${cfg.logPath}";
        Restart = "always";
        RestartSec = "10s";
        
        # Service hardening
        DynamicUser = true;
        PrivateTmp = true;
        NoNewPrivileges = true;
        
        # Log management
        StandardOutput = "journal";
        StandardError = "journal";
        
        # State directory for logs
        StateDirectory = "SOMA";
        LogsDirectory = "SOMA";
      };
      
      environment = {
        SOMA_CENTER_FREQUENCY = toString fieldCfg.trainStation.frequency;
        TRAIN_STATION_POSITION = fieldCfg.trainStation.position;
        SOMA_BASE_PATH = toString fieldCfg.somaBasePath;
      };
    };
    
    # Open firewall port if requested
    networking.firewall.allowedTCPPorts = mkIf (cfg.port != 0) [ cfg.port ];
  };
}
