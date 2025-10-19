{ config, lib, pkgs, ... }: {
  services.dojoNodes.solar = {
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
}