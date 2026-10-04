{
  config,
  lib,
  pkgs,
  ...
}:

{
  # ---------------------------------------------------------------------------
  # AMD CPU / platform
  # ---------------------------------------------------------------------------

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  hardware.enableRedistributableFirmware = true;

  # ---------------------------------------------------------------------------
  # Firmware
  # ---------------------------------------------------------------------------

  hardware.enableAllFirmware = true;

  # ---------------------------------------------------------------------------
  # CPU frequency / performance
  # ---------------------------------------------------------------------------

  powerManagement = {
    enable = true;

    # Prefer workstation performance over laptop-style power savings.
    cpuFreqGovernor = lib.mkDefault "performance";
  };

  # ---------------------------------------------------------------------------
  # AMD virtualization
  # ---------------------------------------------------------------------------

  boot.kernelModules = [
    "kvm-amd"
  ];

  # ---------------------------------------------------------------------------
  # IOMMU
  # ---------------------------------------------------------------------------
  #
  # Useful for:
  #
  #   - KVM / libvirt
  #   - PCI passthrough later
  #   - improved DMA isolation
  #
  # iommu=pt keeps normal host-device overhead low while still enabling IOMMU.
  #

  boot.kernelParams = [
    "amd_iommu=on"
    "iommu=pt"
  ];

  # ---------------------------------------------------------------------------
  # Hardware sensors
  # ---------------------------------------------------------------------------

  environment.systemPackages = with pkgs; [
    lm_sensors
    pciutils
    usbutils
    dmidecode
    hwinfo
  ];

  # ---------------------------------------------------------------------------
  # SMART / disk monitoring
  # ---------------------------------------------------------------------------

  services.smartd = {
    enable = true;
    autodetect = true;
  };

  # ---------------------------------------------------------------------------
  # NVMe
  # ---------------------------------------------------------------------------

  services.fstrim.enable = true;

  # ---------------------------------------------------------------------------
  # Bluetooth
  # ---------------------------------------------------------------------------
  #
  # Bluetooth is also referenced by the desktop audio module, but enabling
  # the controller here makes sense as part of this workstation's hardware.
  #

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # ---------------------------------------------------------------------------
  # Wi-Fi
  # ---------------------------------------------------------------------------
  #
  # Intel AX200 support is handled by the kernel/firmware stack.
  #
  # NetworkManager owns the actual connection configuration.
  #

  # ---------------------------------------------------------------------------
  # Notes
  # ---------------------------------------------------------------------------
  #
  # Intentionally NOT configured here:
  #
  #   NVIDIA:
  #     modules/desktop/nvidia.nix
  #
  #   Storage UUIDs:
  #     hosts/desktop/disks.nix
  #
  #   Generated initrd / detected modules:
  #     hosts/desktop/hardware-configuration.nix
  #
  #   Network interfaces / route priorities:
  #     hosts/desktop/networking.nix
}
