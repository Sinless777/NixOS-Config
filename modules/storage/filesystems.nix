# =====================================================================
# SinLess Industries — Filesystem Support & Management
# =====================================================================
#
# Platform:
#   NixOS Desktop — AMD Threadripper / X399
#
# Responsibilities:
#   - Common Linux / Windows filesystem support
#   - CephFS client and RBD kernel support
#   - Filesystem utilities and storage diagnostics
#   - Periodic TRIM for supported SSD/NVMe filesystems
#   - Safe, reusable configuration across NixOS hosts
#
# Module ownership:
#   filesystems.nix  -> Filesystem capabilities and tools
#   mounts.nix       -> Mount directories and optional CephFS mounts
#   ceph.nix         -> Ceph services and OSD configuration
#   backup.nix       -> Restic backups
#   swap.nix         -> ZRAM and disk swap
#   hosts/*/disks.nix -> Physical filesystems and device UUIDs
#
# Safety:
#   - No automatic disk formatting
#   - No partition-table modifications
#   - No automatic Ceph OSD provisioning
#   - No changes to existing disk UUIDs
#   - No automatic replacement of existing mounts
#
# =====================================================================

{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    optionals
    types
    ;

  cfg = config.sinless.storage.filesystems;

in
{
  # ===================================================================
  # OPTIONS
  # ===================================================================

  options.sinless.storage.filesystems = {

    # -----------------------------------------------------------------
    # General
    # -----------------------------------------------------------------

    enable = mkEnableOption ''
      filesystem support, utilities, and disk diagnostics
    '';

    # -----------------------------------------------------------------
    # Filesystem support
    # -----------------------------------------------------------------

    supported = {
      ext4 = mkOption {
        type = types.bool;
        default = true;
        description = "Enable ext4 filesystem support.";
      };

      xfs = mkOption {
        type = types.bool;
        default = true;
        description = "Enable XFS filesystem support.";
      };

      btrfs = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Btrfs filesystem support.";
      };

      vfat = mkOption {
        type = types.bool;
        default = true;
        description = "Enable FAT/VFAT filesystem support.";
      };

      exfat = mkOption {
        type = types.bool;
        default = true;
        description = "Enable exFAT filesystem support.";
      };

      ntfs = mkOption {
        type = types.bool;
        default = true;
        description = "Enable NTFS filesystem support.";
      };
    };

    # -----------------------------------------------------------------
    # Ceph
    # -----------------------------------------------------------------

    cephSupport = mkOption {
      type = types.bool;
      default = false;

      description = ''
        Enable Linux kernel CephFS and RBD support.

        Does not bootstrap Ceph, initialize OSDs, configure
        CephX authentication, or mount any filesystem.
      '';
    };

    # -----------------------------------------------------------------
    # SSD / NVMe TRIM
    # -----------------------------------------------------------------

    enableTrim = mkOption {
      type = types.bool;
      default = true;

      description = ''
        Enable periodic fstrim for eligible mounted filesystems.

        This is not a secure erase operation and does not
        issue raw-device discard commands to Ceph OSDs.
      '';
    };

    trimInterval = mkOption {
      type = types.str;
      default = "weekly";

      example = "daily";

      description = ''
        systemd calendar expression for periodic TRIM.
      '';
    };

    # -----------------------------------------------------------------
    # Diagnostics
    # -----------------------------------------------------------------

    enableDiagnostics = mkOption {
      type = types.bool;
      default = true;

      description = ''
        Install additional disk and filesystem diagnostic tools.
      '';
    };

    enableBenchmarkTools = mkOption {
      type = types.bool;
      default = false;

      description = ''
        Install storage benchmarking utilities such as fio.

        Benchmarks must be run manually. Enabling this option
        does not run tests or write to storage devices.
      '';
    };
  };

  # ===================================================================
  # CONFIGURATION
  # ===================================================================

  config = mkIf cfg.enable {

    # -----------------------------------------------------------------
    # Supported filesystems
    # -----------------------------------------------------------------
    #
    # boot.supportedFilesystems is merged with declarations made by
    # hardware-configuration.nix and other NixOS modules.
    #
    # Host root and boot filesystems must remain supported even if
    # an optional filesystem is disabled here.
    # -----------------------------------------------------------------

    boot.supportedFilesystems =
      (optionals cfg.supported.ext4 [ "ext4" ])
      ++ (optionals cfg.supported.xfs [ "xfs" ])
      ++ (optionals cfg.supported.btrfs [ "btrfs" ])
      ++ (optionals cfg.supported.vfat [ "vfat" ])
      ++ (optionals cfg.supported.exfat [ "exfat" ])
      ++ (optionals cfg.supported.ntfs [ "ntfs" ])
      ++ (optionals cfg.cephSupport [ "ceph" ]);

    # -----------------------------------------------------------------
    # Ceph kernel support
    # -----------------------------------------------------------------
    #
    # ceph -> CephFS kernel client
    # rbd  -> RADOS block-device client
    #
    # These are optional client capabilities, not Ceph OSD drivers.
    #
    # Some modules may already request these; NixOS merges module
    # lists, so duplicate requests do not require separate services.
    # -----------------------------------------------------------------

    boot.kernelModules = optionals cfg.cephSupport [
      "ceph"
      "rbd"
    ];

    # -----------------------------------------------------------------
    # Filesystem tools
    # -----------------------------------------------------------------

    environment.systemPackages =
      (with pkgs; [
        # ext2 / ext3 / ext4
        e2fsprogs

        # XFS
        xfsprogs

        # Btrfs
        btrfs-progs

        # FAT / EFI
        dosfstools

        # exFAT
        exfatprogs

        # NTFS
        ntfs3g

        # General block and partition management
        util-linux
        parted
        gptfdisk

        # Data copying and transfer
        rsync

        # Open-file and device usage diagnostics
        lsof
      ])
      ++ optionals cfg.enableDiagnostics (
        with pkgs;
        [
          # SMART health reports
          smartmontools

          # NVMe controller diagnostics
          nvme-cli

          # SATA / SCSI diagnostics
          hdparm
          sdparm

          # Disk and filesystem activity monitoring
          sysstat
          iotop

          # Interactive process monitoring
          htop
          btop
        ]
      )
      ++ optionals cfg.enableBenchmarkTools (
        with pkgs;
        [
          fio
        ]
      );

    # -----------------------------------------------------------------
    # Periodic SSD / NVMe TRIM
    # -----------------------------------------------------------------
    #
    # fstrim operates on supported mounted filesystems.
    #
    # It does not:
    #   - Format drives
    #   - Wipe partitions
    #   - Initialize Ceph OSDs
    #   - Perform secure erasure
    #
    # Ceph BlueStore discard behavior is configured independently.
    # -----------------------------------------------------------------

    services.fstrim = {
      enable = cfg.enableTrim;
      interval = cfg.trimInterval;
    };

    # -----------------------------------------------------------------
    # Mount ownership
    # -----------------------------------------------------------------
    #
    # All shared storage directories are now managed exclusively by:
    #
    #   modules/storage/mounts.nix
    #
    # Do not recreate them here to avoid duplicate tmpfiles rules.
    #
    # Physical filesystems are configured in:
    #
    #   hosts/desktop/disks.nix
    #
    # Example:
    #
    # fileSystems."/mnt/aerealith" = {
    #   device =
    #     "/dev/disk/by-uuid/93b3c0ba-91d5-43e1-86ed-6706b9a02bde";
    #
    #   fsType = "ext4";
    #
    #   options = [
    #     "noatime"
    #     "nofail"
    #     "x-systemd.automount"
    #   ];
    # };
    #
    # This example is documentation only. The existing Aerealith
    # filesystem is not modified by this module.
    # -----------------------------------------------------------------

    # -----------------------------------------------------------------
    # Ceph storage safety
    # -----------------------------------------------------------------
    #
    # Previously prepared devices:
    #
    #   sda       Samsung PM830 SSD
    #   sdc       Seagate ST9320320AS HDD
    #   sde       Seagate ST3500414CS HDD
    #   nvme3n1   SanDisk Optimus 5100
    #   nvme2n1   Samsung 128 GB NVMe
    #   nvme0n1   WD PC SN5000S
    #
    # These disks are NOT initialized or mounted here.
    #
    # IMPORTANT:
    #   sdc has a substantial historical uncorrectable-error count.
    #   sde has a historical temperature warning.
    #   nvme2n1 has numerous NVMe error-log entries.
    #
    # Excluded/protected disks:
    #
    #   sdb       Unreliable Seagate 3 TB HDD
    #   sdd       Existing partitioned disk
    #   sdf       NixOS root, boot, and swap
    #   nvme1n1   Existing Aerealith project storage
    #
    # Ceph OSD health validation and provisioning must be
    # performed independently of this module.
    # -----------------------------------------------------------------
  };
}
