{
  description = "Solar Plexus Chakra (Manipura) - Power and Processing";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  outputs = { self, nixpkgs }: {
    nixosModules.default = { config, lib, pkgs, ... }: {
      services.dojoNodes.manipura = {
        enable = true;
        prime = 5;
        chakra = "manipura";
        modelAlias = "power_prime";
        culturalLocalizationHints = {
          domain = "compute_power";
          focus = "processing_optimization";
        };
        energyBreathSettings = {
          powerManagement = "balanced";
          processingThreshold = "0.90";
        };
      };
    };
  };
}
