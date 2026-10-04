{ pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # QEMU
  # ---------------------------------------------------------------------------

  environment.systemPackages = with pkgs; [
    # Core emulator / virtualizer.
    qemu_full

    # UEFI firmware for virtual machines.
    OVMF

    # SPICE support / viewers.
    spice
    spice-gtk
    virt-viewer

    # Guest image utilities.
    qemu-utils

    # ISO / filesystem helpers.
    cdrtools
    libguestfs
  ];

  # ---------------------------------------------------------------------------
  # BinFmt
  # ---------------------------------------------------------------------------
  #
  # Enable additional architecture emulation support.
  #
  # Useful if you later need to run or build ARM binaries/containers from
  # this x86_64 workstation.
  #

  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
  ];

  # ---------------------------------------------------------------------------
  # Notes
  # ---------------------------------------------------------------------------
  #
  # KVM kernel support is configured in:
  #
  #   modules/virtualization/kvm.nix
  #
  # Libvirt daemon/network/storage management belongs in:
  #
  #   modules/virtualization/libvirt.nix
  #
  # This module focuses on:
  #
  #   - QEMU
  #   - UEFI VM firmware
  #   - SPICE
  #   - VM disk/image tooling
  #   - optional cross-architecture emulation
  #
}
