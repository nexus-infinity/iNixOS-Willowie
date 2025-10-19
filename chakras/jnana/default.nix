{ config, lib, pkgs, ... }: {
  services.dojoNodes.jnana = {
    enable = true;
    prime = 23;
    chakra = "jnana";
    modelAlias = "universal_knowledge_prime";
    culturalLocalizationHints = {
      domain = "universal_information";
      focus = "irrefutable_truth_storage";
    };
    energyBreathSettings = {
      knowledgeDepth = "infinite";
      truthVerificationThreshold = "0.99";
    };
  };
}