# BearsiMac - Willowie Kitchen Configuration
# Machine-specific settings for the sacred geometry system
{ config, lib, pkgs, ... }:
{
  # Basic system configuration
  networking = {
    hostName = "BearsiMac";
    networkmanager.enable = true;
    # Note: Do not enable wireless.enable when using NetworkManager
    # They conflict with each other
  };

  # Boot loader configuration for EFI
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 5;
  };

  # iMac 2019 Hardware Support
  hardware = {
    enableRedistributableFirmware = true;
    opengl = {
      enable = true;
      driSupport = true;
    };
  };

  # Enable TRIM for SSD
  services.fstrim.enable = true;

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
    # Set initial password - change this after first login!
    # To generate a hashed password: mkpasswd -m sha-512
    initialPassword = "nixos";
  };

  # Enable zsh shell
  programs.zsh.enable = true;
  };

  # Enable zsh shell
  programs.zsh.enable = true;

  # System packages
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    zsh
    htop
    firefox
    gnome.gnome-tweaks
  ];

  # Enable important services
  services = {
    openssh.enable = true;
    
    # Enable X11 and GNOME Desktop
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      
      # For iMac's AMD Radeon graphics
      videoDrivers = [ "amdgpu" ];
    };
  };

  # System state version
  system.stateVersion = "23.11";
}
