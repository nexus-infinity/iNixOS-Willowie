# ========================================================
# File: ◎_sacred/◎_OBI-WAN/core/field.nix
# Role: Defines the quantum observer field for OBI-WAN
# ========================================================

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.field.obiWan;
in
{
  options.field.obiWan = {
    enable = mkEnableOption "OBI-WAN Quantum Observer Field";

    core = {
      observerMatrix = mkOption {
        type = types.attrs;
        default = {
          quantumState = "coherent";
          observationMode = "non_collapsing";
          fieldAlignment = "pure";
        };
        description = "Quantum observer matrix configuration";
      };

      memoryWalker = mkOption {
        type = types.attrs;
        default = {
          pathFinding = "quantum_guided";
          memoryAccess = "non_destructive";
          fieldPreservation = true;
        };
        description = "Memory walking capabilities";
      };

      timeKeeper = mkOption {
        type = types.attrs;
        default = {
          temporalResolution = "quantum";
          timelinePreservation = true;
          fieldSynchronization = "continuous";
        };
        description = "Temporal management settings";
      };
    };

    field = {
      integrity = mkOption {
        type = types.float;
        default = 1.0;
        description = "Field integrity measurement (0.0 to 1.0)";
      };

      resonance = mkOption {
        type = types.attrs;
        default = {
          frequency = "quantum_aligned";
          amplitude = "self_adjusting";
          phase = "coherent";
        };
        description = "Field resonance parameters";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.field.integrity >= 0.0 && cfg.field.integrity <= 1.0;
        message = "Field integrity must be between 0.0 and 1.0";
      }
    ];
  };
}

