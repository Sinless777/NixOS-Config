{ lib, ... }:

{
  # ---------------------------------------------------------------------------
  # Swap
  # ---------------------------------------------------------------------------
  #
  # The actual swap partition should be declared in the host-specific
  # hardware/storage configuration, usually:
  #
  #   hosts/<hostname>/hardware-configuration.nix
  #
  # or:
  #
  #   hosts/<hostname>/disks.nix
  #
  # Example:
  #
  # swapDevices = [
  #   {
  #     device = "/dev/disk/by-uuid/<swap-uuid>";
  #   }
  # ];
  #
  # This reusable module controls swap behavior rather than hardcoding a
  # machine-specific device.
  #

  # ---------------------------------------------------------------------------
  # Swappiness
  # ---------------------------------------------------------------------------

  boot.kernel.sysctl = {
    # With ~125 GiB RAM, prefer keeping active pages in memory and only use
    # disk-backed swap when it is genuinely useful.
    "vm.swappiness" = 10;

    # Encourage reclaiming filesystem metadata caches less aggressively.
    "vm.vfs_cache_pressure" = 50;

    # Avoid reserving excessive free memory.
    "vm.min_free_kbytes" = 262144;
  };

  # ---------------------------------------------------------------------------
  # zram
  # ---------------------------------------------------------------------------
  #
  # A small compressed RAM swap device can absorb short memory-pressure
  # spikes before the system needs to touch the physical swap partition.
  #
  # This is particularly useful for development workloads, browsers,
  # containers, builds, and occasional ML jobs.
  #

  zramSwap = {
    enable = true;

    # Percentage of physical memory allocated as the maximum zram device.
    #
    # With ~125 GiB RAM, 10% provides roughly 12 GiB of compressed swap
    # capacity without being excessive.
    memoryPercent = 10;

    # zstd offers good compression, though lz4 is generally faster.
    algorithm = "zstd";

    # Prefer zram before physical disk swap.
    priority = 100;
  };
}
