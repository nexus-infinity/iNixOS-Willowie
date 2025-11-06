# BearsiMac - Willowie Kitchen Configuration
# Machine-specific settings for the sacred geometry system
{ config, lib, pkgs, ... }:
{
  # Basic system configuration
  networking = {
    hostName = "BearsiMac";
    networkmanager.enable = true;
    wireless = {
      enable = true;
      networks."Willowie" = {
        priority = 100;
      };
    };
  };

  # Atlas Frontend Configuration for Ghost Alignments
  services.atlasFrontend = {
    enable = true;
    mqttBroker = "mqtt://localhost:1883";
    pulseSyncTopic = "dojo/nodes/pulse/#";
    wsPort = 3000;
    httpPort = 3001;
  };

  # TATA 8i Pulse Engine for Chakra Synchronization
  services.tata8i-pulse-engine = {
    enable = true;
    # Pulse engine specific settings will be auto-configured
  };

  # Enable all chakra nodes with their respective alignments
  # The actual chakra configurations are imported via dot-hive/default.nix
  services.dojoNodes = {
    defaults = {
      transactionOptimizationEnabled = true;
    };

    # The nodes themselves are configured in their respective chakra definitions
  };

  # User configuration
  users.users.jbear = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    zsh
  ];

  # Enable important services
  services = {
    openssh.enable = true;
  };

  # System state version
  system.stateVersion = "23.11";
}
