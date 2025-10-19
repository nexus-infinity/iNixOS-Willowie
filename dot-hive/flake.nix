{
  description = "dot-hive: aggregator flake that collects chakra sub-flakes into a single modules set";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  outputs = { self, nixpkgs }: {
    nixosModules.default = { config, pkgs, lib, ... }: {
      imports = [
        ../chakras/muladhara
        ../chakras/svadhisthana
        ../chakras/manipura
        ../chakras/anahata
        ../chakras/vishuddha
        ../chakras/ajna
        ../chakras/sahasrara
      ];
    };
  };
}
