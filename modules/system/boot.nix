{ lib, pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # Bootloader
  # ---------------------------------------------------------------------------

  boot.loader = {
    systemd-boot = {
      enable = true;

      # Keep a reasonable number of generations in the boot menu.
      configurationLimit = 20;

      # Allow editing kernel parameters from the boot menu.
      editor = true;
    };

    efi = {
      canTouchEfiVariables = true;
    };

    timeout = 5;
  };

  # ---------------------------------------------------------------------------
  # Kernel
  # ---------------------------------------------------------------------------

  # Track the current kernel from nixpkgs.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ---------------------------------------------------------------------------
  # Kernel parameters
  # ---------------------------------------------------------------------------

  boot.kernelParams = [
    # Keep boot output reasonably quiet without hiding serious errors.
    "quiet"

    # Useful on a large desktop/workstation system.
    "threadirqs"
  ];

  # ---------------------------------------------------------------------------
  # initrd
  # ---------------------------------------------------------------------------

  boot.initrd = {
    systemd.enable = true;

    # Common storage/controller modules.
    availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usb_storage"
      "sd_mod"
    ];
  };

  # ---------------------------------------------------------------------------
  # Temporary files
  # ---------------------------------------------------------------------------

  boot.tmp = {
    useTmpfs = true;

    # Avoid allowing /tmp to consume excessive RAM.
    tmpfsSize = "25%";
  };

  # ---------------------------------------------------------------------------
  # Crash / emergency behavior
  # ---------------------------------------------------------------------------

  boot.kernel.sysctl = {
    # Automatically reboot after a kernel panic.
    "kernel.panic" = lib.mkDefault 10;

    # Reboot after an oops when appropriate.
    "kernel.panic_on_oops" = lib.mkDefault 1;
  };
}
