{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.htmTemporalMemory;
  
  htmPython = pkgs.python3.withPackages (ps: with ps; [
    numpy
    scipy
    pandas
    scikit-learn
    fastapi
    uvicorn
    prometheus-client
    paho-mqtt
    websockets
  ]);
  
  htmScriptPath = "${./../../scripts/htm/consciousness_monitor.py}";

in {
  imports = [ ./htm-options.nix ];
  
  config = mkIf cfg.enable {
    systemd.services.htm-temporal-memory = {
      description = "HTM Temporal Memory - NuPIC-inspired consciousness monitor";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      
      serviceConfig = {
        Type = "simple";
        ExecStart = "${htmPython}/bin/python ${htmScriptPath}";
        Restart = "always";
        RestartSec = 10;
        
        # Hardening
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        NoNewPrivileges = true;
      };
      
      environment = {
        PYTHONUNBUFFERED = "1";
        HTM_MODE = "consciousness";
        FIELD_INTEGRATION = "active";
        ANOMALY_THRESHOLD = toString cfg.anomalyThreshold;
      };
    };
    
    # Open firewall for WebSocket
    networking.firewall.allowedTCPPorts = [ cfg.websocketPort ];
  };
}
