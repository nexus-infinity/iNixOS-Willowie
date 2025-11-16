# Ajna Chakra - Third Eye Insight & Collective Intelligence
{ config, lib, pkgs, ... }:

with lib;

{
  options.chakras.ajna = {
    enable = mkEnableOption "Ajna chakra - Third eye insight";
    
    observabilityPort = mkOption {
      type = types.port;
      default = 5556;
      description = "Port for Ajna observability dashboard";
    };
  };

  config = mkIf config.chakras.ajna.enable {
    # Ajna observability service
    services.ajnaAgent = {
      enable = true;
      port = config.chakras.ajna.observabilityPort;
      insightMode = "collective";
      dataRetention = "7d";
    };
    
    # Environment for third eye activation
    environment.systemPackages = with pkgs; [
      prometheus
      grafana
      loki
    ];
  };
}
