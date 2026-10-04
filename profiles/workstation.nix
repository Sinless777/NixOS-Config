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
    # Desktop
    # -------------------------------------------------------------------------

    ../modules/desktop/audio.nix
    ../modules/desktop/fonts.nix
    ../modules/desktop/gnome.nix
    ../modules/desktop/nvidia.nix

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
    # Virtualization
    # -------------------------------------------------------------------------

    ../modules/virtualization/kvm.nix
    ../modules/virtualization/qemu.nix
    ../modules/virtualization/libvirt.nix

    # -------------------------------------------------------------------------
    # Security
    # -------------------------------------------------------------------------

    ../modules/security/sudo.nix
    ../modules/security/apparmor.nix
    ../modules/security/fail2ban.nix
    ../modules/security/sops.nix
    ../modules/security/kernel.nix
    ../modules/security/audit.nix
    ../modules/security/usbguard.nix
    ../modules/security/hardening.nix
    ../modules/security/pam.nix
    ../modules/security/polkit.nix
    ../modules/security/tpm.nix

    # -------------------------------------------------------------------------
    # Secure Boot
    # -------------------------------------------------------------------------
    #
    # I would NOT enable this in the workstation profile yet.
    #
    # Import it later once Lanzaboote has been tested on the desktop:
    #
    # ../modules/security/secureboot.nix
  ];

  # ---------------------------------------------------------------------------
  # Workstation defaults
  # ---------------------------------------------------------------------------

  networking.hostName = "desktop";

  # GNOME workstation should boot to the graphical target.
  systemd.defaultUnit = "graphical.target";

  # ---------------------------------------------------------------------------
  # Notes
  # ---------------------------------------------------------------------------
  #
  # This profile intentionally does NOT contain:
  #
  #   - disk UUIDs
  #   - filesystem devices
  #   - NIC-specific configuration
  #   - host hardware configuration
  #
  # Those belong in:
  #
  #   hosts/desktop/
  #
  # Development tooling is also kept separate in:
  #
  #   profiles/development.nix
  #
  # AI/CUDA-specific additions beyond the base NVIDIA stack can live in:
  #
  #   profiles/ai.nix
  #
  # Gaming-specific configuration can live in:
  #
  #   profiles/gaming.nix
}
