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

  # Import DOJO system components
  services.dojo-node.enable = true;
  services.tata8i-pulse-engine.enable = true;
  services.atlas-frontend.enable = true;

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
