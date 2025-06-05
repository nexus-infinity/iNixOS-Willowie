# =================================================================
# File: flake.nix
# Role: Defines the BearsiMac system flake for Willowie Kitchen location
# =================================================================
{
  description = "BearsiMac - Willowie Kitchen NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    dojo.url = "path:/Users/jbear/FIELD/Nixos_Shared";
  };

  outputs = { self, nixpkgs, dojo }: {
    nixosConfigurations = {
      BearsiMac = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit self dojo; };
        modules = [
          ./nixosConfigurations/BearsiMac/configuration.nix
          dojo.nixosModules.dojo-node
          dojo.nixosModules.tata8i-pulse-engine
          dojo.nixosModules.atlas-frontend
        ];
      };
    };

    formatter = forAllSystems (system: pkgsFor.${system}.nixpkgs-fmt);
  };
}
