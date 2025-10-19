{
  description = "BearsiMac - Willowie Kitchen NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";

    # Use the chakra sub-flakes as local path inputs so we don't import the repo as an input.
    chakras-ajna.path = ./chakras/ajna;
    chakras-anahata.path = ./chakras/anahata;
    chakras-manipura.path = ./chakras/manipura;

    # If you have other shared modules in subdirs, add them similarly.
  };

  outputs = { self, nixpkgs, chakras-ajna, chakras-anahata, chakras-manipura }: {
    nixosConfigurations = {
      BearsiMac = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit self nixpkgs chakras-ajna chakras-anahata chakras-manipura;
        };
        modules = [
          # Local hardware and overrides
          ./hardware-configuration.nix
          ./local-overrides.nix

          # Chakra modules exported by the sub-flakes (they expose nixosModules.default)
          chakras-ajna.nixosModules.default
          chakras-anahata.nixosModules.default
          chakras-manipura.nixosModules.default

          # Machine-specific config (adjust path if different)
          ./nixosConfigurations/BearsiMac/configuration.nix
        ];
      };
    };

    formatter = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
  };
}