{ config, lib, pkgs, ... }:

with lib;

{
  # Integration module that ties HTM with existing consciousness components
  
  config = mkMerge [
    # Enable HTM Temporal Memory alongside Ajna
    (mkIf config.services.ajnaAgent.enable {
      services.htmTemporalMemory = {
        enable = true;
        anomalyThreshold = 0.95;
        mqttBroker = "tcp://localhost:1883";
        websocketPort = 6002;
      };
      
      # Connect HTM to Ajna's consciousness stream
      systemd.services.htm-temporal-memory = {
        after = [ "ajna-agent.service" ];
        wants = [ "ajna-agent.service" ];
      };
    })
    
    # Connect to Vishuddha desktop if enabled
    (mkIf config.services.vishuddhaDesktop.enable {
      services.vishuddhaDesktop.extraConfig = ''
        # Display HTM consciousness state in status bar
        bar {
          status_command ${pkgs.writeScript "htm-status" ''
            #!/bin/sh
            while true; do
              echo "HTM: $(curl -s localhost:6002/state | jq -r .consciousness)"
              sleep 1
            done
          ''}
        }
      '';
    })
    
    # Connect to Sound Field for consciousness sonification
    (mkIf config.services.soundField.enable {
      services.soundField.consciousnessInput = {
        enable = true;
        source = "htm-temporal-memory";
        port = 6002;
      };
    })
  ];
}
