{ config, pkgs, lib, ... }:

with lib;

let
  frontendUser = "atlas";
in
{
  # Atlas Frontend Service Module
  # Ghost alignment interface for the sacred geometry system

  options.services.atlasFrontend = {
    enable = mkEnableOption "Atlas Frontend ghost alignment interface";

    listenPort = mkOption {
      type = types.port;
      default = 3000;
      description = "Port to listen on for the Atlas frontend";
    };

    pulseEngineSource = mkOption {
      type = types.str;
      default = "mqtt://localhost:1883/dojo/pulse";
      description = "MQTT source for pulse engine data";
    };

    pulseSyncSource = mkOption {
      type = types.str;
      default = "mqtt://localhost:1883/dojo/nodes/pulse/#";
      description = "MQTT source for pulse synchronization";
    };
  };

  config = mkIf config.services.atlasFrontend.enable {
    users.users.${frontendUser} = {
      isSystemUser = true;
      group = frontendUser;
    };

    users.groups.${frontendUser} = {};

    systemd.services.atlas-frontend = {
      description = "ATLAS Frontend Service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        User = frontendUser;
        WorkingDirectory = "/var/lib/atlas-frontend";
        ExecStart = "${pkgs.nodejs_18}/bin/node server.js";
        Restart = "always";
        Environment = [
          "PORT=${toString config.services.atlasFrontend.listenPort}"
          "PULSE_ENGINE_SOURCE=${config.services.atlasFrontend.pulseEngineSource}"
          "PULSE_SYNC_SOURCE=${config.services.atlasFrontend.pulseSyncSource}"
        ];
      };
    };

    warnings = [ ''
      Atlas Frontend is configured to listen on port ${toString config.services.atlasFrontend.listenPort}.
      Service implementation is pending. This provides the ghost alignment interface.
    '' ];
    # networking.firewall.allowedTCPPorts = [ config.services.atlasFrontend.listenPort ];
  };
}
