{
  description = "BearsiMac - Willowie Kitchen NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";

    # Aggregator flake (dot-hive)
    dot-hive.path = ./dot-hive;
  };

  outputs = { self, nixpkgs, dot-hive }: let
    pkgs_x86 = nixpkgs.legacyPackages.x86_64-linux;
  in {
    nixosConfigurations = {
      BearsiMac = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit self nixpkgs dot-hive;
        };
        modules = [
          # Local hardware and overrides
          ./hardware-configuration.nix
          ./local-overrides.nix

          # Aggregated chakra modules from dot-hive
          dot-hive.nixosModules.default

          # Machine-specific config (adjust path if different)
          ./nixosConfigurations/BearsiMac/configuration.nix
        ];
      };
    };

    # Dev shell for non-destructive validation
    devShells = {
      "x86_64-linux" = pkgs_x86.mkShell {
        buildInputs = [ pkgs_x86.git pkgs_x86.nix ];
        shellHook = ''
          echo "Dev shell active. Useful commands:
            - nix flake show
            - nixos-rebuild build --flake .#BearsiMac
            - nix build .#nixosConfigurations.BearsiMac.config.system.build.toplevel
          "
        '';
      };
    };

    formatter = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
  };
}