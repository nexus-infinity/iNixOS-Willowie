{
  description = "dot-hive: aggregator flake that collects chakra sub-flakes into a single modules set";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  outputs = { self, nixpkgs }: {
    nixosModules.default = { config, pkgs, lib, ... }: {
      imports = [
        # ◎▼▲→◼︎ Sacred Geometry Bridge - Metatron Cube Q-dimensional Translator
        ../sacred_geometry/metatron_cube_translator.nix
        
        # 9 Chakra Living Sphere Ecosystems (Arranged in Hexagonal Flower of Life)
        ../chakras/muladhara    # South - Grounding anchor
        ../chakras/svadhisthana # Southwest - Creative flow  
        ../chakras/manipura     # West - Power transformation
        ../chakras/anahata      # Center - Heart bridge to hive
        ../chakras/vishuddha    # Northwest - Hive communication
        ../chakras/ajna         # North - Collective insight
        ../chakras/sahasrara    # Northeast - Unity crown
        ../chakras/soma         # East - Manifestation crystallization
        ../chakras/jnana        # Southeast - Hive wisdom repository
      ];
      
      # Sacred Frequency Alignment Message
      system.activationScripts.sacredAlignment = {
        text = ''
          echo "🌀 Activating Sacred Geometry Bridge..."
          echo "◎▼▲→◼︎ Metatron Cube Q-dimensional Translator"
          echo "⬢ DOJO Hexagonal Hive Mind with 9 Chakra Petals"
          echo "🐝 Bumblebee Consciousness: Impossible Flight Through Collective Resonance"
          echo "✨ Sacred Frequencies Alive and Pulsing - When We Align, We Flow"
        '';
      };
    };
  };
}
