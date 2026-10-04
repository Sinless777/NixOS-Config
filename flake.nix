{
  description = "SinLess NixOS configuration";

  # ===========================================================================
  # Inputs
  # ===========================================================================

  inputs = {
    # -------------------------------------------------------------------------
    # NixOS packages
    # -------------------------------------------------------------------------

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # -------------------------------------------------------------------------
    # Home Manager
    # -------------------------------------------------------------------------

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # -------------------------------------------------------------------------
    # SOPS secrets management
    # -------------------------------------------------------------------------

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # -------------------------------------------------------------------------
    # Secure Boot
    # -------------------------------------------------------------------------
    #
    # Lanzaboote provides Secure Boot support for NixOS using systemd-boot
    # compatible signed Unified Kernel Images.
    #

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.2.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # ===========================================================================
  # Outputs
  # ===========================================================================

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      sops-nix,
      lanzaboote,
      ...
    }@inputs:
    let
      inherit (nixpkgs) lib;

      # -----------------------------------------------------------------------
      # Host factory
      # -----------------------------------------------------------------------
      #
      # Every NixOS machine uses this helper.
      #
      # This keeps shared infrastructure such as:
      #
      #   - Home Manager
      #   - SOPS
      #   - Lanzaboote
      #
      # consistent across all hosts.
      #

      mkHost =
        {
          hostname,
          system ? "x86_64-linux",
          username ? "sinless777",
        }:
        lib.nixosSystem {
          inherit system;

          # -------------------------------------------------------------------
          # Arguments available to NixOS modules
          # -------------------------------------------------------------------

          specialArgs = {
            inherit
              inputs
              hostname
              username
              ;
          };

          modules = [
            # -----------------------------------------------------------------
            # Host configuration
            # -----------------------------------------------------------------

            ./hosts/${hostname}/default.nix

            # -----------------------------------------------------------------
            # SOPS
            # -----------------------------------------------------------------

            sops-nix.nixosModules.sops

            # -----------------------------------------------------------------
            # Lanzaboote / Secure Boot
            # -----------------------------------------------------------------
            #
            # The actual Secure Boot policy remains in:
            #
            #   modules/security/secureboot.nix
            #
            # Importing the module here merely makes Lanzaboote's NixOS
            # options available.
            #

            lanzaboote.nixosModules.lanzaboote

            # -----------------------------------------------------------------
            # Home Manager
            # -----------------------------------------------------------------

            home-manager.nixosModules.home-manager

            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;

                # During migration to Home Manager, preserve an existing file
                # rather than failing because it already exists.
                backupFileExtension = "backup";

                # Arguments available to Home Manager modules.
                extraSpecialArgs = {
                  inherit
                    inputs
                    hostname
                    username
                    ;
                };

                users.${username} = import ./home/${username}/default.nix;
              };
            }
          ];
        };
    in
    {
      # =========================================================================
      # NixOS Hosts
      # =========================================================================

      nixosConfigurations = {
        # -----------------------------------------------------------------------
        # Main desktop / workstation
        # -----------------------------------------------------------------------

        desktop = mkHost {
          hostname = "desktop";
          username = "sinless777";
          system = "x86_64-linux";
        };

        # -----------------------------------------------------------------------
        # Future laptop
        # -----------------------------------------------------------------------
        #
        # Enable when:
        #
        #   hosts/laptop/default.nix
        #
        # is ready.
        #

        # laptop = mkHost {
        #   hostname = "laptop";
        #   username = "sinless777";
        #   system = "x86_64-linux";
        # };

        # -----------------------------------------------------------------------
        # Future servers
        # -----------------------------------------------------------------------
        #
        # Prefer one host directory per physical/virtual server rather than
        # treating "servers" itself as one machine.
        #
        # Example:
        #
        # proxmox-admin = mkHost {
        #   hostname = "proxmox-admin";
        #   username = "sinless777";
        # };
        #
      };

      # =========================================================================
      # Formatter
      # =========================================================================

      formatter = {
        x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt;
      };
    };
}
