{
  description = "Heart Chakra (Anahata) - Balance and Integration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  outputs = { self, nixpkgs }: {
    nixosModules.default = { config, lib, pkgs, ... }: {
      services.dojoNodes.anahata = {
        enable = true;
        prime = 7;
        chakra = "anahata";
        modelAlias = "balance_prime";
        culturalLocalizationHints = {
          domain = "system_integration";
          focus = "harmonious_operation";
        };
        energyBreathSettings = {
          balanceControl = "adaptive";
          harmonyThreshold = "0.92";
        };
      };
    };
  };
}
