{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.field.chakra.muladhara;
in
{
  options.field.chakra.muladhara = {
    enable = mkEnableOption "Muladhara (Root) Chakra - Foundation and Security";

    geometricAnchor = mkOption {
      type = types.str;
      default = "tetrahedron";
      description = "Sacred geometric pattern anchoring this chakra's manifestation.";
    };

    vibrationalFrequency = mkOption {
      type = types.int;
      default = 108;
      description = "Base frequency in Hz for root chakra alignment (108Hz Sanskrit harmonics).";
    };

    serviceFocus = mkOption {
      type = types.str;
      default = "grounding_stability";
      description = "Primary service focus for this chakra ecosystem.";
    };

    auditLogPath = mkOption {
      type = types.path;
      default = "/var/log/iNixos-Hive/chakra-muladhara.log";
      description = "Path to audit log for chakra activation events.";
    };
  };

  config = mkIf cfg.enable {
    # Ensure log directory exists
    systemd.tmpfiles.rules = [
      "d /var/log/iNixos-Hive 0755 root root -"
    ];

    # Muladhara chakra activation service
    systemd.services.muladhara-chakra = {
      description = "Muladhara (Root) Chakra - Foundation Service";
      wantedBy = [ "multi-user.target" ];
      
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
        # Audit log entry for chakra activation
        echo "$(date -Iseconds) [MULADHARA] Activated with anchor=${cfg.geometricAnchor} frequency=${toString cfg.vibrationalFrequency}Hz focus=${cfg.serviceFocus}" >> ${cfg.auditLogPath}
        
        # Create initial state marker
        echo "Muladhara chakra initialized: grounding and stability foundation active"
      '';
    };
  };
}
