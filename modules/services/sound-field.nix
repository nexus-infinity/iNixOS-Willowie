# Sound Field Architecture with PipeWire
# Handles audio streams for consciousness system
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.soundField;
in
{
  options.services.soundField = {
    enable = mkEnableOption "Sound field architecture with PipeWire";

    sacredFrequencies = mkOption {
      type = types.bool;
      default = true;
      description = "Enable 432Hz tuning and solfeggio frequencies";
    };
  };

  config = mkIf cfg.enable {
    # Enable PipeWire
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    # Real-time audio priority
    security.rtkit.enable = true;

    # Sound packages
    environment.systemPackages = with pkgs; [
      pavucontrol
      alsa-utils
      pulseaudio
    ];

    # Custom PipeWire configuration for sacred frequencies
    environment.etc."pipewire/pipewire.conf.d/sacred-frequencies.conf".text = mkIf cfg.sacredFrequencies ''
      context.properties = {
        # 432Hz A4 tuning (sacred frequency)
        # default.clock.rate = 48000
        # default.clock.allowed-rates = [ 44100 48000 88200 96000 ]
      }
    '';
  };
}
