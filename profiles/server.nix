{ ... }:

{
  imports = [
    # -------------------------------------------------------------------------
    # Core system
    # -------------------------------------------------------------------------

    ../modules/system/nix.nix
    ../modules/system/users.nix
    ../modules/system/boot.nix
    ../modules/system/networking.nix
    ../modules/system/packages.nix
    ../modules/system/security.nix

    # -------------------------------------------------------------------------
    # Networking
    # -------------------------------------------------------------------------

    ../modules/networking/firewall.nix
    ../modules/networking/ssh.nix
    ../modules/networking/tailscale.nix
    ../modules/networking/wireguard.nix

    # -------------------------------------------------------------------------
    # Storage
    # -------------------------------------------------------------------------

    ../modules/storage/filesystems.nix
    ../modules/storage/mounts.nix
    ../modules/storage/swap.nix
    ../modules/storage/backup.nix

    # -------------------------------------------------------------------------
    # Security
    # -------------------------------------------------------------------------

    ../profiles/hardened.nix
  ];

  # ---------------------------------------------------------------------------
  # Server defaults
  # ---------------------------------------------------------------------------

  # Headless by default.
  systemd.defaultUnit = "multi-user.target";

  # ---------------------------------------------------------------------------
  # Notes
  # ---------------------------------------------------------------------------
  #
  # This profile intentionally does NOT import:
  #
  #   - GNOME
  #   - audio
  #   - desktop fonts
  #   - NVIDIA desktop configuration
  #   - gaming
  #   - AI tooling
  #   - workstation-only packages
  #
  # Server-specific capabilities should be added separately.
  #
  # Examples:
  #
  #   profiles/server.nix
  #   + Docker
  #   + Kubernetes
  #   + database modules
  #   + monitoring
  #   + storage services
  #
}
