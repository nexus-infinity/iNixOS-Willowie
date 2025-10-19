{
  description = "Root Chakra (Muladhara) - Foundation and Security";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  outputs = { self, nixpkgs }: {
    nixosModules.default = { config, lib, pkgs, ... }: {
      services.dojoNodes.root = {
        enable = true;
        prime = 2;
        chakra = "muladhara";
        modelAlias = "foundation_prime";
        culturalLocalizationHints = {
          domain = "system_security";
          focus = "grounding_operations";
        };
        energyBreathSettings = {
          resourcePriority = "high";
          stabilityThreshold = "0.95";
        };
      };
    };
  };
}
