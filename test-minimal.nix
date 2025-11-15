{ config, pkgs, lib, ... }:
{
  imports = [
    ./modules/services/htm-simple.nix
  ];
  
  services.htmTemporalMemory.enable = true;
  system.stateVersion = "24.05";
  boot.loader.grub.enable = false;
  fileSystems."/" = { device = "/dev/null"; fsType = "ext4"; };
}
