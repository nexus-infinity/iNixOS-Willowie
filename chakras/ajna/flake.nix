{
  description = "Third Eye Chakra (Ajna) - Insight and Perception";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  outputs = { self, nixpkgs }: {
    nixosModules.default = { config, lib, pkgs, ... }: {
      services.dojoNodes.thirdeye = {
        enable = true;
        prime = 13;
        chakra = "ajna";
        modelAlias = "insight_prime";
        culturalLocalizationHints = {
          domain = "system_insight";
          focus = "predictive_analysis";
        };
        energyBreathSettings = {
          insightDepth = "deep";
          perceptionThreshold = "0.94";
        };
      };
    };
  };
}
