{ config, lib, pkgs, ... }: {
  services.dojoNodes.soma = {
    enable = true;
    prime = 19;
    chakra = "soma";
    modelAlias = "manifestation_prime";
    culturalLocalizationHints = {
      domain = "manifestation_space";
      focus = "reality_materialization";
    };
    energyBreathSettings = {
      manifestationPotency = "maximum";
      materializationThreshold = "0.98";
    };
  };
}