{
  description = "BearsiMac - Willowie Kitchen NixOS Configuration";

  inputs = {
    # We now point to the official, remote source for the entire hive's DNA.
    iNixOS-Willowie.url = "github:nexus-infinity/iNixOS-Willowie";

    # We also keep our core Nixpkgs stable.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  outputs = { self, nixpkgs, iNixOS-Willowie }: {
    nixosConfigurations = {
      BearsiMac = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          # We pass the entire hive and its sub-flakes for modules to access.
          inherit self nixpkgs iNixOS-Willowie;
        };
        modules = [
          # We import the machine-specific configuration from the central hive repository.
          iNixOS-Willowie.nixosConfigurations.BearsiMac.config
          
          # The Metatron Cube logic and other shared modules from the hive.
          iNixOS-Willowie.modules.chakras.default
          iNixOS-Willowie.modules.sacred.default
          iNixOS-Willowie.modules.dojo.default

          # We still keep local, private files separate.
          ./hardware-configuration.nix
          ./local-overrides.nix
        ];
      };
    };
    
    formatter = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
  };
}
