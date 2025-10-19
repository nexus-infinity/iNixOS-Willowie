{  
  description = "dot-hive: aggregator flake that collects chakra sub-flakes into a single modules set";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";

    # Chakra sub-flakes (assumes these directories already exist in the repo)
    chakras-ajna.path = ../chakras/ajna;
    chakras-anahata.path = ../chakras/anahata;
    chakras-manipura.path = ../chakras/manipura;
  };

  outputs = { self, nixpkgs, chakras-ajna, chakras-anahata, chakras-manipura }: let
    lib = nixpkgs.lib;
  in {
    # Export a single nixosModules.default that merges the chakra modules
    nixosModules.default = { config, pkgs, lib, ... }: lib.mkMerge [
      (chakras-ajna.nixosModules.default { inherit config pkgs lib; })
      (chakras-anahata.nixosModules.default { inherit config pkgs lib; })
      (chakras-manipura.nixosModules.default { inherit config pkgs lib; })
    ];
  };
}