{ config, pkgs, lib, ... }:

with lib;

let
  frontendUser = "atlas";
  atlas-bridge = pkgs.callPackage ./atlas-frontend-package.nix {};
in
{
  # Atlas Frontend Service Module
  # Ghost alignment interface for the sacred geometry system

  options.services.atlasFrontend = {
    enable = mkEnableOption "Atlas Frontend ghost alignment interface";

    wsPort = mkOption {
      type = types.port;
      default = 3000;
      description = "WebSocket port for the Atlas frontend";
    };

    httpPort = mkOption {
      type = types.port;
      default = 3001;
      description = "HTTP API port for the Atlas frontend";
    };

    mqttBroker = mkOption {
      type = types.str;
      default = "mqtt://localhost:1883";
      description = "MQTT broker URL";
    };

    pulseSyncTopic = mkOption {
      type = types.str;
      default = "dojo/nodes/pulse/#";
      description = "MQTT topic for pulse synchronization";
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
        ExecStart = "${atlas-bridge}/bin/atlas-bridge";
        Restart = "always";
        Environment = [
          "ATLAS_MQTT_BROKER=${config.services.atlasFrontend.mqttBroker}"
          "ATLAS_PULSE_SYNC=${config.services.atlasFrontend.pulseSyncTopic}"
          "ATLAS_WS_PORT=${toString config.services.atlasFrontend.wsPort}"
          "ATLAS_HTTP_PORT=${toString config.services.atlasFrontend.httpPort}"
        ];
      };
    };

    warnings = [ ''
      Atlas Frontend is running atlas-bridge on WebSocket port ${toString config.services.atlasFrontend.wsPort} and HTTP port ${toString config.services.atlasFrontend.httpPort}.
      This provides the ghost alignment interface bridging MQTT to WebSocket.
    '' ];
    # networking.firewall.allowedTCPPorts = [ config.services.atlasFrontend.wsPort config.services.atlasFrontend.httpPort ];
  };
}
