{ config, lib, pkgs, ... }: {
  services.dojoNodes.crown = {
    enable = true;
    prime = 17;
    chakra = "sahasrara";
    modelAlias = "unity_prime";
    culturalLocalizationHints = {
      domain = "system_consciousness";
      focus = "holistic_integration";
    };
    energyBreathSettings = {
      unityAwareness = "complete";
      consciousnessThreshold = "0.97";
    };
  };
}