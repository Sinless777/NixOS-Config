{ ... }:

{
  imports = [
    # -------------------------------------------------------------------------
    # Host-specific configuration
    # -------------------------------------------------------------------------

    ./hardware-configuration.nix
    ./hardware.nix
    ./disks.nix
    ./networking.nix

    # -------------------------------------------------------------------------
    # Reusable profiles
    # -------------------------------------------------------------------------

    ../../profiles/workstation.nix
    ../../profiles/development.nix
    ../../profiles/ai.nix
    ../../profiles/gaming.nix
    ../../profiles/hardened.nix
  ];

  # ---------------------------------------------------------------------------
  # Host identity
  # ---------------------------------------------------------------------------

  networking.hostName = "desktop";

  # ---------------------------------------------------------------------------
  # NixOS state version
  # ---------------------------------------------------------------------------
  #
  # Set this to the NixOS version used when this machine was first installed.
  # Do not casually change it later just because you update nixpkgs.
  #

  system.stateVersion = "26.05";

  # ---------------------------------------------------------------------------
  # Notes
  # ---------------------------------------------------------------------------
  #
  # This host currently combines:
  #
  #   workstation
  #   development
  #   AI / CUDA
  #   gaming
  #   hardened security
  #
  # Host-specific configuration remains under:
  #
  #   hosts/desktop/
  #
  # Reusable behavior remains under:
  #
  #   profiles/
  #   modules/
}
