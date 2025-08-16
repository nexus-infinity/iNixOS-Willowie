# Complete NixOS Configuration for 2019 iMac
# WiFi, Sound, Graphics - Everything
{ config, pkgs, ... }:

{
  # Boot configuration for 2019 iMac
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # 2019 iMac specific - Broadcom WiFi BCM4360
  boot.initrd.kernelModules = [ "wl" ];
  boot.kernelModules = [ "kvm-intel" "wl" "snd-hda-intel" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  
  # Fix for Fusion Drive if needed
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" "sdhci_pci" ];
  
  # Enable all firmware
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;
  
  # Graphics for 2019 iMac (AMD Radeon Pro 570X/575X/580X)
  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      rocm-opencl-icd
      rocm-opencl-runtime
      amdvlk
    ];
  };
  
  # Sound configuration for 2019 iMac
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  
  # Networking with NetworkManager (easier for WiFi)
  networking.networkmanager.enable = true;
  networking.wireless.enable = false;  # Disable wpa_supplicant
  
  # SSH with password authentication temporarily enabled
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;  # Enable this!
      KbdInteractiveAuthentication = true;
      PubkeyAuthentication = true;
    };
    openFirewall = true;
  };
  
  # Avahi for .local discovery
  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
      userServices = true;
    };
  };
  
  # Time zone
  time.timeZone = "Australia/Sydney";
  
  # Locale
  i18n.defaultLocale = "en_AU.UTF-8";
  
  # X11/Wayland
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  
  # Enable CUPS for printing
  services.printing.enable = true;
  
  # Users
  users.users.jb = {
    isNormalUser = true;
    description = "JB";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" ];
    # Password hash for "Niama@1974" - remove after SSH keys work
    hashedPassword = "$6$rounds=656000$YourSaltHere$YourHashHere";
  };
  
  # Packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    networkmanager
    networkmanagerapplet
    pavucontrol  # Audio control
    firefox
    alsa-utils
    pulseaudio  # For pactl commands
  ];
  
  # Allow unfree packages (needed for broadcom_sta)
  nixpkgs.config.allowUnfree = true;
}
