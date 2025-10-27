{ config, pkgs, lib, ... }:

let
  frontendUser = "atlas";
in
{
  options.services.atlasFrontend = {
    enable = lib.mkEnableOption "ATLAS Frontend service";

    listenPort = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "Port to serve the frontend on";
    };

    pulseEngineSource = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "MQTT pulse source";
    };

    pulseSyncSource = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "MQTT sync source";
    };
  };

  config = lib.mkIf config.services.atlasFrontend.enable {
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
  };
}
