{
  description = "BearsiMac - Willowie Kitchen NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosConfigurations = {
      BearsiMac = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit self nixpkgs;
          sacredGeometryPath = ./sacred_geometry;
          chakrasPath = ./chakras;
        };

        modules = [
          ./hardware-configuration.nix

          # Aggregator chakra module that uses sacredGeometryPath + chakrasPath
          ./dot-hive/default.nix
          ./modules/services/atlas-frontend.nix 

          # Machine-specific config
          ./nixosConfigurations/BearsiMac/configuration.nix

          # Extra Nix settings module (inline)
          ({ pkgs, ... }: {
            nix.settings = {
              auto-optimise-store = true;
              experimental-features = [ "nix-command" "flakes" ];
            };
          })
        ];
      };
    };

    devShells.${system} = pkgs.mkShell {
      buildInputs = [ pkgs.git pkgs.nix ];
      shellHook = ''
        echo "Dev shell active. Useful commands:
          - nix flake show
          - nixos-rebuild build --flake .#BearsiMac
          - nix build .#nixosConfigurations.BearsiMac.config.system.build.toplevel
        "
      '';
    };

    # nixpkgs-fmt formatter support (optional if available)
    formatter = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system:
      nixpkgs.legacyPackages.${system}.nixpkgs-fmt
    );
  };
}
