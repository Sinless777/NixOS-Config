{ pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # KVM
  # ---------------------------------------------------------------------------
  #
  # This workstation uses an AMD Ryzen Threadripper CPU with AMD-V support.
  #

  boot.kernelModules = [
    "kvm-amd"
  ];

  # ---------------------------------------------------------------------------
  # KVM kernel parameters
  # ---------------------------------------------------------------------------

  boot.extraModprobeConfig = ''
    options kvm ignore_msrs=1
    options kvm report_ignored_msrs=0
    options kvm_amd nested=1
  '';

  # ---------------------------------------------------------------------------
  # Virtualization utilities
  # ---------------------------------------------------------------------------

  environment.systemPackages = with pkgs; [
    # Provides virt-host-validate to check virtualization support.
    libvirt

    # General hardware inspection.
    pciutils
    usbutils
  ];

  # ---------------------------------------------------------------------------
  # Notes
  # ---------------------------------------------------------------------------
  #
  # Higher-level VM functionality belongs in:
  #
  #   modules/virtualization/qemu.nix
  #   modules/virtualization/libvirt.nix
  #
  # This module intentionally focuses on:
  #
  #   - AMD KVM kernel support
  #   - nested virtualization
  #   - basic KVM diagnostics
  #
}
