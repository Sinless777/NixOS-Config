{ pkgs, username, ... }:

{
  # ---------------------------------------------------------------------------
  # libvirt
  # ---------------------------------------------------------------------------

  virtualisation.libvirtd = {
    enable = true;

    # Start libvirt on boot.
    onBoot = "start";

    # Keep the daemon available after startup.
    onShutdown = "shutdown";

    # QEMU/KVM backend.
    qemu = {
      package = pkgs.qemu_full;

      # QEMU provides OVMF firmware for UEFI guests by default.

      # Run QEMU with the normal host security model.
      runAsRoot = false;

      # Software TPM support for Windows 11 and other guests.
      swtpm.enable = true;
    };
  };

  # ---------------------------------------------------------------------------
  # User permissions
  # ---------------------------------------------------------------------------

  users.users.${username}.extraGroups = [
    "libvirtd"
    "kvm"
  ];

  # ---------------------------------------------------------------------------
  # virt-manager / GUI tooling
  # ---------------------------------------------------------------------------

  programs.virt-manager.enable = true;

  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer

    # VM filesystem / disk tools.
    libguestfs

    # TPM emulator tooling.
    swtpm
  ];

  # ---------------------------------------------------------------------------
  # USB redirection
  # ---------------------------------------------------------------------------

  virtualisation.spiceUSBRedirection.enable = true;

  # ---------------------------------------------------------------------------
  # Notes
  # ---------------------------------------------------------------------------
  #
  # KVM kernel support:
  #
  #   modules/virtualization/kvm.nix
  #
  # QEMU userspace tooling:
  #
  #   modules/virtualization/qemu.nix
  #
  # This module handles:
  #
  #   - libvirt daemon
  #   - virt-manager
  #   - user permissions
  #   - UEFI guests
  #   - software TPM
  #   - SPICE USB redirection
  #
}
