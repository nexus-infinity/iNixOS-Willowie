{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.soma-infrastructure.eventbus;
in
{
  options.services.soma-infrastructure.eventbus = {
    enable = mkEnableOption "SOMA EventBus (Redis Agent 1)";
    
    port = mkOption {
      type = types.port;
      default = 6379;
      description = "Redis port for EventBus";
    };
    
    bind = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Bind address for Redis";
    };
  };

  config = mkIf cfg.enable {
    # Enable Redis service
    services.redis.servers.soma-eventbus = {
      enable = true;
      port = cfg.port;
      bind = cfg.bind;
      
      # Ubuntu philosophy: shared resources, no isolation
      settings = {
        maxmemory = "512mb";
        maxmemory-policy = "allkeys-lru";
        
        # Pub/sub configuration for collective coherence
        timeout = 300;
        tcp-keepalive = 60;
        
        # Persistence for event history
        save = [
          [900 1]    # Save after 900 sec if at least 1 key changed
          [300 10]   # Save after 300 sec if at least 10 keys changed
          [60 10000] # Save after 60 sec if at least 10000 keys changed
        ];
        
        # Enable append-only file for durability
        appendonly = true;
        appendfsync = "everysec";
      };
    };

    # Create directory for SOMA EventBus data
    systemd.tmpfiles.rules = [
      "d /var/lib/soma/eventbus 0755 redis redis -"
    ];

    # Ubuntu EventBus topics (documented, enforced by application layer):
    # - signals.coherence.* - Coherence monitoring signals
    # - signals.ubuntu.heartbeat - Ubuntu pulse from all chakras
    # - signals.pulse.* - Prime-based pulse signals
    # - moves.action.* - Collective action coordination
    # - proofs.validation.* - Proof validation results
    
    # Open firewall for localhost only (collective access)
    networking.firewall = mkIf (cfg.bind == "127.0.0.1") {
      allowedTCPPorts = [];  # No external access
    };
  };
}
