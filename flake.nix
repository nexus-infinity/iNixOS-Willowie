# =================================================================
# File: flake.nix
# Role: Defines the BearsiMac system flake for Willowie Kitchen location
# =================================================================
{
  description = "BearsiMac - Willowie Kitchen NixOS Configuration";

  inputs = {
    # Nixpkgs input
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    
    # Dojo input
    dojo.url = "path:/Users/jbear/FIELD/Nixos_Shared";
    
    # Sacred Triad inputs
    obi-wan.url = "path:./sacred/OBI-WAN";
    tata.url = "path:./sacred/TATA";
    atlas.url = "path:./sacred/Atlas";
    
    # Chakra ecosystem inputs
    root-chakra.url = "path:./chakras/muladhara";
    sacral-chakra.url = "path:./chakras/svadhisthana";
    solar-chakra.url = "path:./chakras/manipura";
    heart-chakra.url = "path:./chakras/anahata";
    throat-chakra.url = "path:./chakras/vishuddha";
    third-eye-chakra.url = "path:./chakras/ajna";
    crown-chakra.url = "path:./chakras/sahasrara";
  };

  outputs = { self, nixpkgs, ... } @ inputs: {
    nixosConfigurations = {
      BearsiMac = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        # specialArgs allows modules to inherit the flake's inputs.
        # We'll pass all of them for simplicity and future use.
        specialArgs = { inherit inputs; };
        
        modules = [
          # The base configuration for the BearsiMac machine.
          # This should contain machine-specific settings and hardware config.
          ./nixosConfigurations/BearsiMac/configuration.nix
          
          # Dojo modules
          inputs.dojo.nixosModules.dojo-node
          inputs.dojo.nixosModules.tata8i-pulse-engine
          inputs.dojo.nixosModules.atlas-frontend
          
          # Sacred Triad modules
          inputs.obi-wan.nixosModules.default
          inputs.tata.nixosModules.default
          inputs.atlas.nixosModules.default
          
          # Chakra ecosystem modules
          inputs.root-chakra.nixosModules.default
          inputs.sacral-chakra.nixosModules.default
          inputs.solar-chakra.nixosModules.default
          inputs.heart-chakra.nixosModules.default
          inputs.throat-chakra.nixosModules.default
          inputs.third-eye-chakra.nixosModules.default
          inputs.crown-chakra.nixosModules.default
        ];
      };
    };

    # The formatter for your flake, using nixpkgs-fmt.
    formatter = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
  };
}

