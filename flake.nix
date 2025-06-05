# =================================================================
# File: flake.nix
# Role: Defines the BearsiMac system flake for Willowie Kitchen location
# =================================================================
{
  description = "BearsiMac - Willowie Kitchen NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    dojo.url = "path:/Users/jbear/FIELD/Nixos_Shared";
    
    # Sacred Triad
    obi-wan.url = "path:./sacred/OBI-WAN";
    tata.url = "path:./sacred/TATA";
    atlas.url = "path:./sacred/Atlas";
    
    # Chakra ecosystem flakes
    root-chakra.url = "path:./chakras/muladhara";
    sacral-chakra.url = "path:./chakras/svadhisthana";
    solar-chakra.url = "path:./chakras/manipura";
    heart-chakra.url = "path:./chakras/anahata";
    throat-chakra.url = "path:./chakras/vishuddha";
    third-eye-chakra.url = "path:./chakras/ajna";
    crown-chakra.url = "path:./chakras/sahasrara";
  };

  outputs = { self, nixpkgs, dojo, obi-wan, tata, atlas, root-chakra, sacral-chakra, solar-chakra, heart-chakra, throat-chakra, third-eye-chakra, crown-chakra }: {
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
