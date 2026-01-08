{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.soma.manipura;
  dnaBlueprint = builtins.fromJSON (builtins.readFile ../../config/dna_blueprints/dal_dna_v0.2.0_prime5_manipura_ubuntu.json);
in
{
  options.services.soma.manipura = {
    enable = mkEnableOption "Manipura chakra service (Prime 5 - Solar Power)";
    
    port = mkOption {
      type = types.port;
      default = dnaBlueprint.endpoints.port;
      description = "Port for Manipura health endpoint";
    };
    
    basePath = mkOption {
      type = types.path;
      default = dnaBlueprint.directory_structure.base_path;
      description = "Base directory for Manipura chakra data";
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.basePath} 0755 soma soma -"
      "d ${cfg.basePath}/models 0755 soma soma -"
      "d ${cfg.basePath}/memory 0755 soma soma -"
      "d ${cfg.basePath}/coherence 0755 soma soma -"
      "d ${cfg.basePath}/logs 0755 soma soma -"
    ];

    users.users.soma = {
      isSystemUser = true;
      group = "soma";
      description = "SOMA collective consciousness user";
    };
    
    users.groups.soma = {};

    systemd.services.soma-manipura = {
      description = "SOMA Manipura Chakra - ${dnaBlueprint.identity.name}";
      after = [ "network.target" "soma-eventbus.service" ];
      wants = [ "soma-eventbus.service" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        CHAKRA_NAME = "manipura";
        PRIME_ID = toString dnaBlueprint.prime_id;
        PORT = toString cfg.port;
        BASE_PATH = cfg.basePath;
        DNA_BLUEPRINT = builtins.toJSON dnaBlueprint;
        UBUNTU_PRINCIPLE = dnaBlueprint.ubuntu_genotype.principle;
      };

      serviceConfig = {
        Type = "simple";
        User = "soma";
        Group = "soma";
        WorkingDirectory = cfg.basePath;
        Restart = "always";
        RestartSec = "10s";
        
        CPUQuota = "${toString dnaBlueprint.homeostatic_budgets.cpu_percent}%";
        MemoryMax = "${toString dnaBlueprint.homeostatic_budgets.memory_mb}M";
        
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ cfg.basePath ];
        
        ExecStart = "${pkgs.bash}/bin/bash -c 'echo \"Manipura (Prime 5) running on port ${toString cfg.port}\"; while true; do sleep ${toString dnaBlueprint.swarm_awareness.heartbeat_interval_sec}; done'";
      };
    };

    warnings = [
      "SOMA Manipura service is a stub. Full Python agent implementation pending."
    ];
  };
}
