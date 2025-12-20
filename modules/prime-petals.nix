# SOMA Prime Petals Module
# =========================
# Generates Prime Petal structure (P1-P11) for all SOMA vertices on boot
#
# Prime Petals provide fractal recursion at all scales:
# P1 (·)  - Seed (0D point)
# P3 (△)  - Identity (2D triangle)
# P5 (⬠)  - Vessel (2D pentagon with φ)
# P7 (⬡)  - Temporal (2D→3D hexagon)
# P9 (✦)  - Wisdom (2D radial)
# P11 (⊞) - Registry (2D→3D grid)

{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.field;
  
  # Python script for generating Prime Petals
  primePetalGenerator = pkgs.writeScriptBin "soma-prime-petal-generator" ''
    #!${pkgs.python3}/bin/python3
    ${builtins.readFile ../scripts/soma-prime-petal-generator.py}
  '';

in {
  options.field.primePetals = {
    enable = mkEnableOption "Generate Prime Petal structure on boot" // {
      default = cfg.enable;
    };
    
    generateOnBoot = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to generate Prime Petals during system activation";
    };
  };

  config = mkIf (cfg.enable && cfg.primePetals.enable) {
    # Install the generator script
    environment.systemPackages = [
      primePetalGenerator
      pkgs.python3Packages.pyyaml
    ];
    
    # Generate Prime Petals during system activation
    system.activationScripts.somaPrimePetals = mkIf cfg.primePetals.generateOnBoot {
      deps = [ "var" ];
      text = ''
        echo "Generating SOMA Prime Petals..."
        
        # Ensure SOMA directories exist
        mkdir -p ${cfg.somaBasePath}
        
        # Run Prime Petal generator
        ${primePetalGenerator}/bin/soma-prime-petal-generator \
          --base-path ${cfg.somaBasePath} || true
        
        echo "✓ Prime Petal generation complete"
      '';
    };
    
    # Create a systemd service for regenerating Prime Petals on demand
    systemd.services.soma-prime-petals-generator = {
      description = "SOMA Prime Petal Generator Service";
      
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${primePetalGenerator}/bin/soma-prime-petal-generator --base-path ${cfg.somaBasePath}";
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };
  };
}
