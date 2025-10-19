{ config, lib, pkgs, ... }: {
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
}