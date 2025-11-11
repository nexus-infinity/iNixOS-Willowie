{
  description = "Throat Chakra (Vishuddha) - Communication and Expression";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  outputs = { self, nixpkgs }: {
    nixosModules.default = { config, lib, pkgs, ... }: {
      services.dojoNodes.vishuddha = {
        enable = true;
        prime = 11;
        chakra = "vishuddha";
        modelAlias = "communication_prime";
        culturalLocalizationHints = {
          domain = "network_communication";
          focus = "protocol_optimization";
        };
        energyBreathSettings = {
          communicationQuality = "high";
          expressionThreshold = "0.88";
        };
      };
    };
  };
}
