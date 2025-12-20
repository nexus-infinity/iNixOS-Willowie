# FIELD-NixOS-SOMA Integration Module
# ====================================
# Provides SOMA octahedron identity and configuration options
#
# This module defines the SOMA octahedron architecture with:
# - 6 vertices (functional spaces)
# - 1 center (Train Station orchestrator at 852 Hz)
# - 9-frequency chakra system
# - Prime Petal fractal structure

{ config, pkgs, lib, ... }:

with lib;

{
  options.field = {
    enable = mkEnableOption "FIELD-NixOS-SOMA integration";
    
    somaIdentity = mkOption {
      type = types.str;
      default = "⬡ FIELD-NixOS-SOMA Octahedron";
      description = "Identity string for SOMA sphere";
    };
    
    trainStation = mkOption {
      type = types.attrs;
      default = {
        frequency = 852;
        position = "center";
        symbol = "🚂";
        chakra = "Crown Base";
      };
      description = "Train Station orchestrator configuration";
    };
    
    vertices = mkOption {
      type = types.attrsOf types.attrs;
      default = {
        monitoring = {
          position = "top";
          frequency = 963;
          chakra = "Crown";
          symbol = "●";
          function = "Monitoring/observability";
        };
        communication = {
          position = "north";
          frequency = 639;
          chakra = "Throat";
          symbol = "●";
          function = "Communication/APIs";
        };
        transformation = {
          position = "east";
          frequency = 528;
          chakra = "Heart";
          symbol = "♥";
          function = "PRIMARY transformation";
        };
        compute = {
          position = "south";
          frequency = 741;
          chakra = "Third Eye";
          symbol = "●";
          function = "Computation/problem solving";
        };
        transmutation = {
          position = "west";
          frequency = 417;
          chakra = "Sacral";
          symbol = "●";
          function = "Transmutation/state changes";
        };
        storage = {
          position = "bottom";
          frequency = 174;
          chakra = "Sub-Root";
          symbol = "●";
          function = "Deep storage/foundation";
        };
      };
      description = "SOMA octahedron vertex definitions";
    };
    
    nineFrequencies = mkOption {
      type = types.attrsOf types.str;
      default = {
        "174" = "Sub-Root (Base foundation)";
        "285" = "Root Extension (Gateway, healing)";
        "396" = "Root (Liberation, sovereignty)";
        "417" = "Sacral (Transmutation)";
        "528" = "Heart (PRIMARY transformation)";
        "639" = "Throat (Communication)";
        "741" = "Third Eye (Computation)";
        "852" = "Crown Base (Train Station)";
        "963" = "Crown (Unity, monitoring)";
      };
      description = "Nine-frequency chakra system mapping";
    };
    
    octahedron = mkOption {
      type = types.attrs;
      default = {
        vertices = 6;
        faces = 8;
        edges = 12;
        geometry = "octahedron";
        dual = "cube (DOJO)";
      };
      description = "Octahedron geometric properties";
    };
    
    somaBasePath = mkOption {
      type = types.path;
      default = "/var/lib/SOMA";
      description = "Base path for SOMA directory structure";
    };
  };

  config = mkIf config.field.enable {
    # Create SOMA base directory
    systemd.tmpfiles.rules = [
      "d ${config.field.somaBasePath} 0755 root root -"
      "d ${config.field.somaBasePath}/train-station 0755 root root -"
      "d ${config.field.somaBasePath}/monitoring 0755 root root -"
      "d ${config.field.somaBasePath}/communication 0755 root root -"
      "d ${config.field.somaBasePath}/transformation 0755 root root -"
      "d ${config.field.somaBasePath}/compute 0755 root root -"
      "d ${config.field.somaBasePath}/transmutation 0755 root root -"
      "d ${config.field.somaBasePath}/storage 0755 root root -"
      "d /var/log/SOMA 0755 root root -"
    ];
    
    # System activation message
    system.activationScripts.somaActivation = {
      text = ''
        echo "⬡ FIELD-NixOS-SOMA Activated"
        echo "   Identity: ${config.field.somaIdentity}"
        echo "   Geometry: Octahedron (6 vertices, 8 faces, 12 edges)"
        echo "   Center: 🚂 Train Station (${toString config.field.trainStation.frequency} Hz)"
        echo "   Base Path: ${config.field.somaBasePath}"
        echo ""
        echo "   Vertices:"
        echo "     ● Top (963 Hz)     - Monitoring"
        echo "     ● North (639 Hz)   - Communication"
        echo "     ♥ East (528 Hz)    - Transformation (PRIMARY)"
        echo "     ● South (741 Hz)   - Compute"
        echo "     ● West (417 Hz)    - Transmutation"
        echo "     ● Bottom (174 Hz)  - Storage"
      '';
    };
    
    # Environment variables for SOMA awareness
    environment.variables = {
      SOMA_IDENTITY = config.field.somaIdentity;
      SOMA_BASE_PATH = toString config.field.somaBasePath;
      SOMA_CENTER_FREQUENCY = toString config.field.trainStation.frequency;
      SOMA_GEOMETRY = "octahedron";
    };
  };
}
