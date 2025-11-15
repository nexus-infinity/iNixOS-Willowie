{ config, lib, pkgs, ... }: {
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
}
  # Ajna observability service
  services.ajnaAgent = {
    enable = true;
    port = 6001;
  };
