{ config, lib, pkgs, ... }:

with lib;

{
  options.services.ajnaAgent = {
    enable = mkEnableOption "Ajna Agent observability service";
    
    port = mkOption {
      type = types.port;
      default = 5556;
      description = "Port for Ajna observability dashboard";
    };
    
    insightMode = mkOption {
      type = types.str;
      default = "collective";
      description = "Insight gathering mode";
    };
    
    dataRetention = mkOption {
      type = types.str;
      default = "7d";
      description = "Data retention period";
    };
  };
  
  config = mkIf config.services.ajnaAgent.enable {
    # Placeholder implementation
    environment.systemPackages = with pkgs; [ ];
  };
}
