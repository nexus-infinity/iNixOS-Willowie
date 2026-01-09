{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.soma-mcp-bridge;
  
  # Python environment with dependencies
  pythonEnv = pkgs.python311.withPackages (ps: with ps; [
    fastapi
    uvicorn
    pydantic
    httpx
  ]);
  
  # MCP bridge script
  mcpBridgeScript = pkgs.writeScript "soma-mcp-bridge" ''
    #!${pythonEnv}/bin/python3
    ${builtins.readFile ../../services/mcp/soma_mcp_bridge.py}
  '';
in
{
  options.services.soma-mcp-bridge = {
    enable = mkEnableOption "SOMA MCP Bridge Server";
    
    port = mkOption {
      type = types.port;
      default = 8520;
      description = "Port for MCP bridge (852 Hz King's Chamber frequency)";
    };
    
    basePath = mkOption {
      type = types.path;
      default = "/var/lib/soma/mcp";
      description = "Base directory for MCP bridge data";
    };
  };

  config = mkIf cfg.enable {
    # Create directories
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

    # Systemd service for MCP bridge
    systemd.services.soma-mcp-bridge = {
      description = "SOMA MCP Bridge Server (Port 8520 - 852 Hz)";
      after = [ "network.target" "soma-jnana.service" ];
      wants = [ "soma-jnana.service" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        MCP_PORT = toString cfg.port;
        BASE_PATH = cfg.basePath;
        PYTHONUNBUFFERED = "1";
      };

      serviceConfig = {
        Type = "simple";
        User = "soma";
        Group = "soma";
        WorkingDirectory = cfg.basePath;
        Restart = "always";
        RestartSec = "10s";
        
        # Resource limits
        CPUQuota = "10%";
        MemoryMax = "256M";
        
        # Security hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ cfg.basePath ];
        
        ExecStart = "${mcpBridgeScript}";
      };
    };

    # Open firewall for MCP bridge (localhost only by default)
    # For external access, configure networking.firewall.allowedTCPPorts manually
    
    warnings = [
      "SOMA MCP Bridge depends on chakra services being available on ports 8502-8523."
    ];
  };
}
