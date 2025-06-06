{ config, lib, pkgs, dojo, root-chakra, sacral-chakra, solar-chakra, heart-chakra, throat-chakra, third-eye-chakra, crown-chakra, ... }:
{
  imports = [
    # Import chakra-specific configurations
    root-chakra.nixosModules.default
    sacral-chakra.nixosModules.default
    solar-chakra.nixosModules.default
    heart-chakra.nixosModules.default
    throat-chakra.nixosModules.default
    third-eye-chakra.nixosModules.default
    crown-chakra.nixosModules.default
  ];

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
    pulseEngineSource = "mqtt://localhost:1883/dojo/pulse";
    pulseSyncSource = "mqtt://localhost:1883/dojo/nodes/pulse/#";
    listenPort = 3000;
  };

  # TATA 8i Pulse Engine for Chakra Synchronization
  services.tata8i-pulse-engine = {
    enable = true;
    # Pulse engine specific settings will be auto-configured
  };

  # Enable all chakra nodes with their respective alignments
  services.dojoNodes = {
    defaults = {
      transactionOptimizationEnabled = true;
    };
    
    # The nodes themselves are configured in their respective chakra flakes
    # but we can override specific settings here if needed
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
  ];

  # Enable important services
  services = {
    openssh.enable = true;
  };

  # System state version
  system.stateVersion = "23.11";
}
