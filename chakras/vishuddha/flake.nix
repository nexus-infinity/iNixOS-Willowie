{
  description = "Throat Chakra (Vishuddha) - Communication and Expression";

  outputs = { self }: {
    nixosModules.default = { config, lib, pkgs, ... }: {
      services.dojoNodes.throat = {
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
