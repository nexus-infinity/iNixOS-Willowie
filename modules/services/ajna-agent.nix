# Ajna Observability Agent Service
# Port 6001 - Third Eye Chakra monitoring and metrics
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.ajnaAgent;
in
{
  options.services.ajnaAgent = {
    enable = mkEnableOption "Ajna observability agent";

    port = mkOption {
      type = types.port;
      default = 6001;
      description = "Port for Ajna health and metrics endpoint";
    };

    chakraStateFile = mkOption {
      type = types.path;
      default = "/var/lib/ajna/state.json";
      description = "Path to chakra state file";
    };

    metricsInterval = mkOption {
      type = types.int;
      default = 30;
      description = "Metrics collection interval in seconds";
    };
  };

  config = mkIf cfg.enable {
    # Create ajna user and group
    users.users.ajna = {
      isSystemUser = true;
      group = "ajna";
      description = "Ajna observability agent user";
      home = "/var/lib/ajna";
      createHome = true;
    };

    users.groups.ajna = {};

    # Ajna agent systemd service
    systemd.services.ajna-agent = {
      description = "Ajna Observability Agent (Third Eye Chakra)";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        Type = "simple";
        User = "ajna";
        Group = "ajna";
        Restart = "on-failure";
        RestartSec = "10s";
        
        # Security hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ "/var/lib/ajna" ];
        
        # Resource limits
        MemoryMax = "256M";
        CPUQuota = "50%";
      };

      # Simple Python-based health check server
      script = ''
        ${pkgs.python3}/bin/python3 << 'PYTHON_SCRIPT'
        import http.server
        import json
        import time
        import os
        from datetime import datetime

        PORT = ${toString cfg.port}
        STATE_FILE = "${cfg.chakraStateFile}"

        class AjnaHandler(http.server.BaseHTTPRequestHandler):
            def do_GET(self):
                if self.path == '/health':
                    self.send_response(200)
                    self.send_header('Content-type', 'application/json')
                    self.end_headers()
                    
                    response = {
                        "status": "ok",
                        "chakra": "ajna",
                        "state": "online",
                        "timestamp": int(time.time()),
                        "datetime": datetime.utcnow().isoformat() + "Z"
                    }
                    
                    self.wfile.write(json.dumps(response, indent=2).encode())
                    
                elif self.path == '/metrics':
                    self.send_response(200)
                    self.send_header('Content-type', 'text/plain')
                    self.end_headers()
                    
                    metrics = f"""# HELP ajna_health Ajna chakra health status
# TYPE ajna_health gauge
ajna_health{{status="ok"}} 1

# HELP ajna_uptime_seconds Ajna service uptime
# TYPE ajna_uptime_seconds counter
ajna_uptime_seconds {int(time.time())}

# HELP chakra_state Chakra activation state
# TYPE chakra_state gauge
chakra_state{{chakra="ajna",state="online"}} 1
"""
                    self.wfile.write(metrics.encode())
                    
                else:
                    self.send_response(404)
                    self.end_headers()
            
            def log_message(self, format, *args):
                # Custom logging format
                print(f"AJNA: {datetime.utcnow().isoformat()}Z - {format % args}")

        print(f"AJNA_MANIFEST: {datetime.utcnow().isoformat()}Z - Starting on port {PORT}")
        server = http.server.HTTPServer(('0.0.0.0', PORT), AjnaHandler)
        server.serve_forever()
        PYTHON_SCRIPT
      '';
    };

    # Firewall configuration
    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
