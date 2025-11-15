# Manifestation Evidence System
# Tracks and logs system state changes for declaration
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.manifestationEvidence;
in
{
  options.services.manifestationEvidence = {
    enable = mkEnableOption "Manifestation evidence tracking";

    logFile = mkOption {
      type = types.path;
      default = "/var/log/manifestation.log";
      description = "Evidence log file";
    };
  };

  config = mkIf cfg.enable {
    # Ensure log directory exists
    systemd.tmpfiles.rules = [
      "f ${cfg.logFile} 0644 root root -"
    ];

    # Log system activation
    system.activationScripts.manifestationLog = ''
      echo "MANIFEST: $(date -Iseconds) - System generation $systemConfig" >> ${cfg.logFile}
    '';
  };
}
