{ config, lib, pkgs, ... }:

with lib;

{
  # FIELD Chakra Registry Aggregator
  # Imports chakra modules and provides top-level enable option
  
  imports = [
    ./muladhara/module.nix
    # Additional chakra modules can be imported here:
    # ./svadhisthana/module.nix
    # ./manipura/module.nix
    # ./anahata/module.nix
    # ./vishuddha/module.nix
    # ./ajna/module.nix
    # ./sahasrara/module.nix
    # ./soma/module.nix
    # ./jnana/module.nix
  ];

  options.field.chakra = {
    enable = mkEnableOption "FIELD Chakra Ecosystem";
    
    globalFrequencyBase = mkOption {
      type = types.int;
      default = 432;
      description = "Global base frequency in Hz for chakra system alignment (432Hz universal harmony).";
    };

    manifestationProtocol = mkOption {
      type = types.str;
      default = "breath_awareness_pulse";
      description = "Activation protocol for chakra manifestation.";
    };

    hiveLogRoot = mkOption {
      type = types.path;
      default = "/var/log/iNixos-Hive";
      description = "Root directory for all FIELD/Hive logging.";
    };
  };

  config = mkIf config.field.chakra.enable {
    # Global FIELD chakra system activation
    systemd.tmpfiles.rules = [
      "d ${config.field.chakra.hiveLogRoot} 0755 root root -"
    ];

    # System-wide activation message
    system.activationScripts.fieldChakraActivation = {
      text = ''
        echo "🌀 FIELD Chakra Ecosystem Activated"
        echo "   Global Frequency Base: ${toString config.field.chakra.globalFrequencyBase}Hz"
        echo "   Manifestation Protocol: ${config.field.chakra.manifestationProtocol}"
        echo "   Hive Log Root: ${config.field.chakra.hiveLogRoot}"
      '';
    };
  };
}
