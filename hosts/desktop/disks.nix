
# =====================================================================
# SinLess Industries — Desktop Disk Configuration
# =====================================================================
#
# Host: desktop
# Platform: AMD Threadripper 1950X / X399
#
# Responsibilities:
#   - Root filesystem
#   - EFI system partition
#   - Dedicated Aerealith NVMe mount
#   - Existing disk-based swap
#   - Document Ceph storage candidates
#
# Related modules:
#   modules/storage/filesystems.nix
#   modules/storage/mounts.nix
#   modules/storage/swap.nix
#   modules/storage/ceph.nix
#   modules/storage/backup.nix
#
# Safety:
#   - No automatic formatting
#   - No disk partitioning
#   - No automatic Ceph OSD provisioning
#   - Use persistent UUID-based filesystem paths
#   - Protect NixOS system and Aerealith storage
#
# =====================================================================

{ ... }:

{
  # ===================================================================
  # ROOT FILESYSTEM
  # ===================================================================
  #
  # Physical device:
  #   /dev/sdf2
  #
  # Filesystem:
  #   ext4
  #
  # Size:
  #   792.3 GiB
  #
  # Root filesystem must mount successfully during boot.
  # Do not use nofail or automount for root.
  # ===================================================================

  fileSystems."/" = {
    device =
      "/dev/disk/by-uuid/b6218953-bd53-4f81-9342-d2afd8084bc6";

    fsType = "ext4";

    options = [
      "defaults"
      "relatime"
    ];
  };

  # ===================================================================
  # EFI SYSTEM PARTITION
  # ===================================================================
  #
  # Physical device:
  #   /dev/sdf1
  #
  # Filesystem:
  #   vfat
  #
  # Size:
  #   1 GiB
  #
  # Required for bootloader updates.
  # ===================================================================

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0AB3-7499";

    fsType = "vfat";

    options = [
      "defaults"
      "fmask=0022"
      "dmask=0022"
    ];

    neededForBoot = true;
  };

  # ===================================================================
  # AEREALITH PROJECT STORAGE
  # ===================================================================
  #
  # Physical device:
  #   /dev/nvme1n1p1
  #
  # Model:
  #   WD_BLACK SN850X 1000GB
  #
  # Filesystem:
  #   ext4
  #
  # Size:
  #   931.5 GiB
  #
  # Mountpoint:
  #   /mnt/aerealith
  #
  # Existing contents:
  #   Aerealith/
  #   models/
  #   .pnpm-store/
  #
  # This remains a dedicated local NVMe filesystem.
  # It must not be automatically provisioned as a Ceph OSD.
  #
  # Automount activates the filesystem when accessed.
  # nofail prevents this non-critical disk from blocking boot.
  # ===================================================================

  fileSystems."/mnt/aerealith" = {
    device =
      "/dev/disk/by-uuid/93b3c0ba-91d5-43e1-86ed-6706b9a02bde";

    fsType = "ext4";

    options = [
      "defaults"
      "noatime"
      "nofail"

      # Mount on first access.
      "x-systemd.automount"

      # Avoid indefinite waits for unavailable storage.
      "x-systemd.device-timeout=10s"
      "x-systemd.mount-timeout=30s"

      # Keep active development storage mounted.
      # No idle timeout is configured.
    ];

    neededForBoot = false;
  };

  # ===================================================================
  # DISK SWAP
  # ===================================================================
  #
  # Physical device:
  #   /dev/sdf3
  #
  # Size:
  #   138.3 GiB
  #
  # ZRAM is configured separately in:
  #   modules/storage/swap.nix
  #
  # Intended priorities:
  #   ZRAM:      100
  #   Disk swap:  10
  #
  # This host owns the disk-swap declaration.
  #
  # IMPORTANT:
  #   sinless.storage.swap.disk.enable must remain false,
  #   otherwise the same swap partition may be declared twice.
  # ===================================================================

  swapDevices = [
    {
      device =
        "/dev/disk/by-uuid/4f6ff624-aea5-4f94-8fe9-bf833f60fa65";

      priority = 10;

      # Existing HDD swap: no discard policy.
      discardPolicy = null;

      # Preserve existing swap UUID and contents.
      randomEncryption.enable = false;
    }
  ];

  # ===================================================================
  # CEPH STORAGE CANDIDATES
  # ===================================================================
  #
  # The following disks have been cleaned and are available
  # for evaluation and explicit Ceph OSD provisioning.
  #
  # These drives are intentionally NOT included in fileSystems,
  # swapDevices, or automatic filesystem creation.
  #
  # ---------------------------------------------------------------
  # SATA SSD
  # ---------------------------------------------------------------
  #
  # /dev/sda
  # Samsung PM830 — 256 GB
  #
  # Stable ID:
  # /dev/disk/by-id/
  #   ata-SAMSUNG_SSD_PM830_2.5__7mm_256GB_S0TZNSAD203506
  #
  # Health:
  #   SMART passed, but high accumulated operating hours.
  #   Evaluate endurance before production use.
  #
  # ---------------------------------------------------------------
  # SATA HDDs
  # ---------------------------------------------------------------
  #
  # /dev/sdc
  # Seagate ST9320320AS — 320 GB
  #
  # Health:
  #   13,284 historically reported uncorrectable errors.
  #   Do not use for important data.
  #
  # /dev/sde
  # Seagate ST3500414CS — 500 GB
  #
  # Health:
  #   Historical temperature threshold warning.
  #   Further testing recommended before OSD provisioning.
  #
  # ---------------------------------------------------------------
  # NVMe SSDs
  # ---------------------------------------------------------------
  #
  # /dev/nvme3n1
  # SanDisk Optimus 5100 — 1 TB
  #
  # Health:
  #   SMART passed.
  #   0% wear reported.
  #   0 media errors.
  #
  # /dev/nvme2n1
  # Samsung 128 GB NVMe
  #
  # Health:
  #   SMART passed.
  #   5% wear reported.
  #   NVMe error-log entries require further inspection.
  #
  # /dev/nvme0n1
  # WD PC SN5000S — 512 GB
  #
  # Health:
  #   SMART passed.
  #   3% wear reported.
  #   0 media errors.
  #
  # ===================================================================
  # EXCLUDED DISKS
  # ===================================================================
  #
  # /dev/sdb
  #   Seagate ST3000DM003 — 3 TB
  #   Persistent I/O errors.
  #   Excluded from Ceph.
  #
  # /dev/sdd
  #   Toshiba 1 TB
  #   Contains existing filesystem partitions.
  #   Do not modify.
  #
  # /dev/sdf
  #   NixOS system disk.
  #   Contains root, EFI, and disk swap.
  #   Never use as a Ceph OSD.
  #
  # /dev/nvme1n1
  #   WD_BLACK SN850X — 1 TB
  #   Dedicated Aerealith project filesystem.
  #   Do not provision as an OSD while mounted.
  #
  # ===================================================================
  # FUTURE CEPHFS MOUNTS
  # ===================================================================
  #
  # CephFS mounts are handled by:
  #
  #   modules/storage/mounts.nix
  #
  # Expected future location:
  #
  #   /mnt/ceph
  #
  # These mounts must only be enabled after:
  #
  #   - Ceph MON and MGR are operational
  #   - Approved OSDs are provisioned
  #   - CephFS metadata servers are running
  #   - A CephFS filesystem has been created
  #   - CephX credentials have been configured
  #
  # Do not declare the same mountpoint in multiple modules.
  #
  # ===================================================================
  # NOTES
  # ===================================================================
  #
  # Ceph storage and local filesystem configuration are separate.
  #
  # Ceph OSD preparation is performed explicitly using stable
  # /dev/disk/by-id paths.
  #
  # This file intentionally contains no wipefs, mkfs, parted,
  # ceph-volume, or destructive activation commands.
  #
  # ===================================================================
}
