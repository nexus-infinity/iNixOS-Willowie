{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.soma-infrastructure.scheduler;
  
  # Prime-based pulse intervals in seconds
  primeIntervals = {
    prime2 = 2;
    prime3 = 3;
    prime5 = 5;
    prime7 = 7;
    prime11 = 11;
    prime13 = 13;
    prime17 = 17;
    prime19 = 19;
    prime23 = 23;
  };
in
{
  options.services.soma-infrastructure.scheduler = {
    enable = mkEnableOption "SOMA Scheduler (Prime Pulse Agent 3)";
    
    port = mkOption {
      type = types.port;
      default = 8501;
      description = "HTTP port for scheduler status endpoint";
    };
    
    basePath = mkOption {
      type = types.path;
      default = "/var/lib/soma/scheduler";
      description = "Base directory for scheduler data";
    };
  };

  config = mkIf cfg.enable {
    # Create directory structure
    systemd.tmpfiles.rules = [
      "d ${cfg.basePath} 0755 soma soma -"
      "d ${cfg.basePath}/logs 0755 soma soma -"
    ];

    # Ensure soma user exists
    users.users.soma = {
      isSystemUser = true;
      group = "soma";
      description = "SOMA collective consciousness user";
    };
    
    users.groups.soma = {};

    # Systemd service for Prime Pulse Scheduler
    systemd.services.soma-scheduler = {
      description = "SOMA Prime Pulse Scheduler (Agent 3)";
      after = [ "network.target" "soma-eventbus.service" ];
      wants = [ "soma-eventbus.service" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        SCHEDULER_PORT = toString cfg.port;
        BASE_PATH = cfg.basePath;
        REDIS_HOST = "127.0.0.1";
        REDIS_PORT = "6379";
        
        # Prime pulse intervals
        PULSE_PRIME_2 = toString primeIntervals.prime2;
        PULSE_PRIME_3 = toString primeIntervals.prime3;
        PULSE_PRIME_5 = toString primeIntervals.prime5;
        PULSE_PRIME_7 = toString primeIntervals.prime7;
        PULSE_PRIME_11 = toString primeIntervals.prime11;
        PULSE_PRIME_13 = toString primeIntervals.prime13;
        PULSE_PRIME_17 = toString primeIntervals.prime17;
        PULSE_PRIME_19 = toString primeIntervals.prime19;
        PULSE_PRIME_23 = toString primeIntervals.prime23;
      };

      serviceConfig = {
        Type = "simple";
        User = "soma";
        Group = "soma";
        WorkingDirectory = cfg.basePath;
        Restart = "always";
        RestartSec = "10s";
        
        # Resource limits
        CPUQuota = "5%";
        MemoryMax = "128M";
        
        # Security hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ cfg.basePath ];
        
        # Placeholder for actual scheduler implementation
        # This will be replaced with Python APScheduler service
        ExecStart = pkgs.writeShellScript "soma-scheduler" ''
          #!/usr/bin/env bash
          echo "SOMA Prime Pulse Scheduler (Agent 3) starting on port ${toString cfg.port}"
          echo "Prime pulse intervals: 2s, 3s, 5s, 7s, 11s, 13s, 17s, 19s, 23s"
          echo "Publishing to Redis EventBus at 127.0.0.1:6379"
          
          # Simulate prime pulse generation (stub implementation)
          counter=0
          while true; do
            sleep 1
            counter=$((counter + 1))
            
            # Check if counter is divisible by any prime
            for prime in 2 3 5 7 11 13 17 19 23; do
              if [ $((counter % prime)) -eq 0 ]; then
                echo "[PULSE] Prime $prime pulse at $(date +%s)"
              fi
            done
          done
        '';
      };
    };

    # Add systemd timer for each prime pulse (alternative to Python APScheduler)
    # This provides native systemd scheduling as backup
    systemd.timers = {
      soma-pulse-prime2 = {
        description = "SOMA Prime 2 Pulse Timer";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "2s";
          OnUnitActiveSec = "2s";
          AccuracySec = "1ms";
        };
      };
      
      soma-pulse-prime3 = {
        description = "SOMA Prime 3 Pulse Timer";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "3s";
          OnUnitActiveSec = "3s";
          AccuracySec = "1ms";
        };
      };
      
      soma-pulse-prime5 = {
        description = "SOMA Prime 5 Pulse Timer";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "5s";
          OnUnitActiveSec = "5s";
          AccuracySec = "1ms";
        };
      };
      
      soma-pulse-prime7 = {
        description = "SOMA Prime 7 Pulse Timer";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "7s";
          OnUnitActiveSec = "7s";
          AccuracySec = "1ms";
        };
      };
    };

    warnings = [
      "SOMA Scheduler is a stub. Full Python APScheduler implementation with Redis pub/sub pending."
    ];
  };
}
