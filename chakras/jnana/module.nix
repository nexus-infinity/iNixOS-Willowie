{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.soma.jnana;
  dnaBlueprint = builtins.fromJSON (builtins.readFile ../../config/dna_blueprints/dal_dna_v0.2.0_prime23_jnana_agent99_ubuntu.json);
in
{
  options.services.soma.jnana = {
    enable = mkEnableOption "Jnana chakra service (Prime 23 - Agent 99 Meta-Coordinator)";
    
    port = mkOption {
      type = types.port;
      default = dnaBlueprint.endpoints.port;
      description = "Port for Jnana health endpoint";
    };
    
    basePath = mkOption {
      type = types.path;
      default = dnaBlueprint.directory_structure.base_path;
      description = "Base directory for Jnana chakra data";
    };
    
    pdcaCycleSec = mkOption {
      type = types.int;
      default = dnaBlueprint.swarm_awareness.pdca_cycle_sec;
      description = "PDCA cycle interval in seconds";
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.basePath} 0755 soma soma -"
      "d ${cfg.basePath}/models 0755 soma soma -"
      "d ${cfg.basePath}/memory 0755 soma soma -"
      "d ${cfg.basePath}/coherence 0755 soma soma -"
      "d ${cfg.basePath}/consensus 0755 soma soma -"
      "d ${cfg.basePath}/pdca 0755 soma soma -"
      "d ${cfg.basePath}/logs 0755 soma soma -"
    ];

    users.users.soma = {
      isSystemUser = true;
      group = "soma";
      description = "SOMA collective consciousness user";
    };
    
    users.groups.soma = {};

    systemd.services.soma-jnana = {
      description = "SOMA Jnana Chakra - ${dnaBlueprint.identity.name} (Agent 99 Meta-Coordinator)";
      after = [ "network.target" "soma-eventbus.service" "soma-proofstore.service" ];
      wants = [ "soma-eventbus.service" "soma-proofstore.service" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        CHAKRA_NAME = "jnana";
        PRIME_ID = toString dnaBlueprint.prime_id;
        PORT = toString cfg.port;
        BASE_PATH = cfg.basePath;
        DNA_BLUEPRINT = builtins.toJSON dnaBlueprint;
        UBUNTU_PRINCIPLE = dnaBlueprint.ubuntu_genotype.principle;
        IS_META_COORDINATOR = "true";
        PDCA_CYCLE_SEC = toString cfg.pdcaCycleSec;
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
        
        ExecStart = "${pkgs.bash}/bin/bash -c 'echo \"Jnana Agent 99 (Prime 23) Meta-Coordinator running on port ${toString cfg.port}\"; echo \"PDCA cycle every ${toString cfg.pdcaCycleSec}s\"; while true; do sleep ${toString dnaBlueprint.swarm_awareness.heartbeat_interval_sec}; done'";
      };
    };

    warnings = [
      "SOMA Jnana (Agent 99) service is a stub. Full Python PDCA coordinator implementation pending."
    ];
  };
}
