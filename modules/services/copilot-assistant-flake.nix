{ config, pkgs, lib, ... }:

with lib;

let
  assistantScript = config.services.copilot-assistant.backendScript;
in {

  # Geometric Alignment: Anchored to dot-hive/Willowie purity.
  options.services.copilot-assistant = {
    enable = mkEnableOption "Copilot AI Assistant service";
    backend = mkOption {
      type = types.enum [ "python" "rust" ];
      default = "python";
      description = "Copilot backend: choose 'python' or 'rust'.";
    };
    backendScript = mkOption {
      type = types.str;
      default = "/etc/copilot-assistant/copilot-assistant-python.py";
      description = "Path to the backend script to run.";
    };
    port = mkOption {
      type = types.port;
      default = 8765;
      description = "Local API port for Copilot Assistant.";
    };
  };

  config = mkIf config.services.copilot-assistant.enable {
    systemd.services.copilot-assistant = {
      description = "NixOS Copilot AI Assistant";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart =
          if config.services.copilot-assistant.backend == "python"
          then "${pkgs.python3}/bin/python3 ${config.services.copilot-assistant.backendScript} --port ${toString config.services.copilot-assistant.port}"
          else "${pkgs.rustc}/bin/rustc ${config.services.copilot-assistant.backendScript} && ./copilot-assistant-rust ${toString config.services.copilot-assistant.port}";
        Restart = "on-failure";
        WorkingDirectory = "/etc/copilot-assistant";
      };
      environment = {
        COPILOT_ASSISTANT_PORT = toString config.services.copilot-assistant.port;
      };
    };
  };

}
