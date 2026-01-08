{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.soma.muladhara;
  dnaBlueprint = builtins.fromJSON (builtins.readFile ../../config/dna_blueprints/dal_dna_v0.2.0_prime2_muladhara_ubuntu.json);
in
{
  options.services.soma.muladhara = {
    enable = mkEnableOption "Muladhara chakra service (Prime 2 - Root Foundation)";
    
    port = mkOption {
      type = types.port;
      default = dnaBlueprint.endpoints.port;
      description = "Port for Muladhara health endpoint";
    };
    
    basePath = mkOption {
      type = types.path;
      default = dnaBlueprint.directory_structure.base_path;
      description = "Base directory for Muladhara chakra data";
    };
  };

  config = mkIf cfg.enable {
    # Create necessary directories
    systemd.tmpfiles.rules = [
      "d ${cfg.basePath} 0755 soma soma -"
      "d ${cfg.basePath}/models 0755 soma soma -"
      "d ${cfg.basePath}/memory 0755 soma soma -"
      "d ${cfg.basePath}/coherence 0755 soma soma -"
      "d ${cfg.basePath}/logs 0755 soma soma -"
    ];

    # Create soma user if not exists
    users.users.soma = {
      isSystemUser = true;
      group = "soma";
      description = "SOMA collective consciousness user";
    };
    
    users.groups.soma = {};

    # Systemd service for Muladhara
    systemd.services.soma-muladhara = {
      description = "SOMA Muladhara Chakra - ${dnaBlueprint.identity.name}";
      after = [ "network.target" "soma-eventbus.service" ];
      wants = [ "soma-eventbus.service" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        CHAKRA_NAME = "muladhara";
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
        
        # Resource limits from DNA blueprint
        CPUQuota = "${toString dnaBlueprint.homeostatic_budgets.cpu_percent}%";
        MemoryMax = "${toString dnaBlueprint.homeostatic_budgets.memory_mb}M";
        
        # Security hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ cfg.basePath ];
        
        # Placeholder for actual service binary
        ExecStart = "${pkgs.bash}/bin/bash -c 'echo \"Muladhara (Prime 2) running on port ${toString cfg.port}\"; while true; do sleep ${toString dnaBlueprint.swarm_awareness.heartbeat_interval_sec}; done'";
      };
    };

    # Add warning that this is a stub implementation
    warnings = [
      "SOMA Muladhara service is a stub. Full Python agent implementation pending."
    ];
  };
}
