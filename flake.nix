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
      # Original BearsiMac configuration
      BearsiMac = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit self nixpkgs;
          sacredGeometryPath = ./sacred_geometry;
          chakrasPath = ./chakras;
        };

        modules = [
          ./nixosConfigurations/BearsiMac/hardware-configuration.nix
          # DOJO nodes module - defines services.dojoNodes options
          ./modules/services/dojo-nodes.nix

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

      # New Willowie configuration with consciousness system
      willowie = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit self nixpkgs;
          sacredGeometryPath = ./sacred_geometry;
          chakrasPath = ./chakras;
        };

        modules = [
          ./hardware-configuration.nix

          # Consciousness services
          ./modules/services/ajna-agent.nix
          ./modules/services/vishuddha-desktop.nix
          ./modules/services/sound-field.nix
          ./modules/services/model-purity.nix
          ./modules/services/manifestation-evidence.nix

          # Aggregator chakra module
          ./dot-hive/default.nix
          ./modules/services/atlas-frontend.nix

          # Willowie-specific configuration
          ./nixosConfigurations/willowie/configuration.nix

          # Extra Nix settings module
          ({ pkgs, ... }: {
            nix.settings = {
              auto-optimise-store = true;
              experimental-features = [ "nix-command" "flakes" ];
            };
          })
        ];
      };
      
      # Trident Scrum development workspace configuration
      trident-dev = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit self nixpkgs;
          sacredGeometryPath = ./sacred_geometry;
          chakrasPath = ./chakras;
        };

        modules = [
          ./hardware-configuration.nix

          # Trident workspace service
          ./modules/services/trident-workspace.nix

          # Basic system configuration
          ({ pkgs, ... }: {
            # Enable Trident workspace
            services.trident-workspace = {
              enable = true;
              userName = "developer";
              workspaceDir = "/home/developer/workspace";
              enableCopilot = true;
              pythonVersion = "python311";
            };
            
            # System basics
            boot.loader.systemd-boot.enable = true;
            boot.loader.efi.canTouchEfiVariables = true;
            
            networking.networkmanager.enable = true;
            time.timeZone = "America/New_York";
            
            system.stateVersion = "23.11";
            
            nix.settings = {
              auto-optimise-store = true;
              experimental-features = [ "nix-command" "flakes" ];
            };
          })
        ];
      };
    };

    devShells.${system} = {
      default = pkgs.mkShell {
        buildInputs = [ pkgs.git pkgs.nix ];
        shellHook = ''
          echo "Dev shell active. Useful commands:
            - nix flake show
            - nixos-rebuild build --flake .#willowie
            - nix build .#nixosConfigurations.willowie.config.system.build.toplevel
          "
        '';
      };
      
      # Trident Scrum development shell
      trident = pkgs.mkShell {
        buildInputs = with pkgs; [
          git
          python311Full
          python311Packages.pip
          python311Packages.virtualenv
          python311Packages.pytest
          python311Packages.pytest-cov
          nodejs_20
          nodePackages.npm
          nodePackages.typescript
          gh
        ];
        
        shellHook = ''
          echo "🔱 Trident Scrum Development Environment"
          echo "========================================="
          echo ""
          echo "Available tools:"
          echo "  - Python 3.11 with pytest"
          echo "  - Node.js 20 with npm"
          echo "  - GitHub CLI (gh)"
          echo ""
          echo "Quick start:"
          echo "  cd trident_scrum"
          echo "  python3 tests/test_sprint_trident.py"
          echo "  python3 examples/complete_demo.py"
          echo ""
          echo "To install Copilot CLI:"
          echo "  npm install -g @githubnext/github-copilot-cli"
          echo ""
        '';
      };
    };

    # nixpkgs-fmt formatter support (optional if available)
    formatter = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system:
      nixpkgs.legacyPackages.${system}.nixpkgs-fmt
    );
  };
}
