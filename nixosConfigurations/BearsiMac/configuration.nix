{ config, lib, pkgs, dojo, ... }:
{
  imports = [ ];

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
    extraGroups = [ "wheel" "networkmanager" "docker" ];
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
    docker.enable = true;
  };

  # System state version
  system.stateVersion = "23.11";
}
