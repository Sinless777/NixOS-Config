# =====================================================================
# SinLess Industries — Desktop Host Configuration
# =====================================================================
#
# Hostname: desktop
# Platform: AMD Threadripper 1950X / X399
# Memory: 128 GB
# GPU: NVIDIA GeForce RTX 3060 12GB
# Operating System: NixOS
#
# Features:
#   - GNOME workstation
#   - Development environment
#   - NVIDIA / CUDA / AI workloads
#   - Gaming
#   - Hardened security
#   - Ceph storage preparation
#   - Filesystem management
#   - Shared mount management
#   - ZRAM and disk swap
#   - Restic backup support
#
# Safety:
#   - No automatic Ceph OSD provisioning
#   - No disk formatting or partitioning
#   - Existing Aerealith NVMe preserved
#   - Existing root, EFI, and swap preserved
#   - Backups disabled until configured
#
# =====================================================================

{ ... }:

{
  # ===================================================================
  # IMPORTS
  # ===================================================================

  imports = [
    # -----------------------------------------------------------------
    # Host-specific configuration
    # -----------------------------------------------------------------

    ./hardware-configuration.nix
    ./hardware.nix
    ./disks.nix
    ./networking.nix

    # -----------------------------------------------------------------
    # Reusable profiles
    # -----------------------------------------------------------------

    ../../profiles/workstation.nix
    ../../profiles/development.nix
    ../../profiles/ai.nix
    ../../profiles/gaming.nix
    ../../profiles/hardened.nix

    # -----------------------------------------------------------------
    # Storage modules
    # -----------------------------------------------------------------
    #
    # If a profile already imports one of these modules, remove the
    # duplicate import from that profile to keep ownership clear.
    #
    # These modules do not automatically format or provision disks.
    # -----------------------------------------------------------------

    ../../modules/storage/filesystems.nix
    ../../modules/storage/mounts.nix
    ../../modules/storage/swap.nix
    ../../modules/storage/ceph.nix
    ../../modules/storage/backup.nix
  ];

  # ===================================================================
  # HOST IDENTITY
  # ===================================================================

  networking.hostName = "desktop";

  # ===================================================================
  # FILESYSTEM SUPPORT
  # ===================================================================

  sinless.storage.filesystems = {
    enable = true;

    supported = {
      ext4 = true;
      xfs = true;
      btrfs = true;
      vfat = true;
      exfat = true;
      ntfs = true;
    };

    # Enable CephFS and RBD kernel support.
    cephSupport = true;

    # Periodic TRIM for eligible local filesystems.
    enableTrim = true;
    trimInterval = "weekly";

    # Disk health and diagnostic tools.
    enableDiagnostics = true;

    # Install benchmarking tools only when needed.
    enableBenchmarkTools = false;
  };

  # ===================================================================
  # MOUNT MANAGEMENT
  # ===================================================================

  sinless.storage.mounts = {
    enable = true;

    # Shared storage mount directories.
    directories = [
      "/mnt/data"
      "/mnt/projects"
      "/mnt/aerealith"
      "/mnt/backup"
      "/mnt/ceph"
      "/mnt/ceph/projects"
      "/mnt/ceph/models"
      "/mnt/ceph/backups"
    ];

    # ---------------------------------------------------------------
    # CephFS client
    # ---------------------------------------------------------------
    #
    # Disabled until:
    #   - Ceph cluster is initialized
    #   - MON / MGR are operational
    #   - OSDs are provisioned
    #   - CephFS and MDS are configured
    #   - CephX credentials are available
    # ---------------------------------------------------------------

    ceph = {
      enable = false;

      mountPoint = "/mnt/ceph";

      device = "";

      clientName = "desktop";

      secretFile = "/run/secrets/ceph-client";
    };
  };

  # ===================================================================
  # SWAP MANAGEMENT
  # ===================================================================
  #
  # System memory:
  #   128 GB
  #
  # Existing swap:
  #   /dev/sdf3 — 138.3 GiB
  #
  # ZRAM:
  #   Approximately 10% of installed RAM
  #
  # Disk swap is declared in:
  #   hosts/desktop/disks.nix
  #
  # Do not declare the same swap partition twice.
  # ===================================================================

  sinless.storage.swap = {
    enable = true;

    # ---------------------------------------------------------------
    # Compressed memory swap
    # ---------------------------------------------------------------

    zram = {
      enable = true;

      algorithm = "zstd";

      memoryPercent = 10;

      # Prefer compressed memory before disk swap.
      priority = 100;
    };

    # ---------------------------------------------------------------
    # Existing disk swap
    # ---------------------------------------------------------------

    disk = {
      # Managed by hosts/desktop/disks.nix.
      enable = false;
    };

    # ---------------------------------------------------------------
    # Kernel memory management
    # ---------------------------------------------------------------

    memory = {
      configure = true;

      swappiness = 100;

      pageCluster = 0;

      vfsCachePressure = 100;
    };

    diagnostics.enable = true;
  };

  # ===================================================================
  # CEPH STORAGE
  # ===================================================================
  #
  # Initial deployment:
  #   Single-node experimental Ceph cluster
  #
  # Future:
  #   Expand into multiple physical Proxmox/Ceph nodes
  #
  # Prepared storage candidates:
  #   sda       Samsung PM830 256 GB
  #   sdc       Seagate 320 GB — unreliable
  #   sde       Seagate 500 GB — requires further testing
  #   nvme3n1   SanDisk Optimus 5100 1 TB
  #   nvme2n1   Samsung NVMe 128 GB — inspect error log
  #   nvme0n1   WD PC SN5000S 512 GB
  #
  # Excluded devices:
  #   sdb       Failing Seagate 3 TB
  #   sdd       Existing data disk
  #   sdf       NixOS operating system
  #   nvme1n1   Aerealith project NVMe
  #
  # Initial Ceph services remain disabled until bootstrap.
  # ===================================================================

  sinless.storage.ceph = {
    enable = true;

    # Do not start daemons until the monitor has been initialized.
    deployDaemons = true;

    # Set this after generating the cluster UUID.
    fsid = "n375782ec-bc1a-47c4-856c-8d5f3dad5c26";

    monitorId = "desktop";
    managerId = "desktop";

    # Dedicated wired network.
    monitorAddress = "10.42.0.1";
    publicNetwork = "10.42.0.0/24";

    # Separate replication network not configured yet.
    clusterNetwork = null;

    # OSDs have not been provisioned.
    osdIds = [ ];

    enableMds = false;
    openFirewall = false;
    enableChrony = false;
  };

  # ===================================================================
  # RESTIC BACKUPS
  # ===================================================================
  #
  # Backups remain disabled until:
  #
  #   1. A real repository exists
  #   2. A password file is available
  #   3. Repository connectivity is verified
  #   4. Backup sources and required mounts are confirmed
  #
  # Recommended backup targets:
  #   - Separate backup server
  #   - External encrypted storage
  #   - Offsite object storage
  #
  # Do not treat Ceph replication as a backup.
  # ===================================================================

  sinless.backup = {
    enable = false;

    # Configure before enabling:
    #
    # repository =
    #   "sftp:backup@backup-server:/backups/desktop";
    #
    # passwordFile = "/run/secrets/restic-password";
    #
    # paths = [
    #   "/home"
    #   "/mnt/aerealith"
    # ];
    #
    # requiredPaths = [
    #   "/home"
    #   "/mnt/aerealith"
    # ];
    #
    # requiredMounts = [
    #   "/mnt/aerealith"
    # ];
    #
    # schedule = "daily";
    # initialize = true;
  };

  # ===================================================================
  # NIXOS STATE VERSION
  # ===================================================================
  #
  # IMPORTANT:
  #
  # Preserve the version used when this system was first installed.
  #
  # Do not change this automatically when updating nixpkgs.
  # ===================================================================

  system.stateVersion = "26.05";

  # ===================================================================
  # MODULE OWNERSHIP
  # ===================================================================
  #
  # hosts/desktop/
  #   default.nix     Host composition and feature configuration
  #   hardware.nix    Hardware-specific settings
  #   disks.nix       Physical mounts and disk swap
  #   networking.nix  Host-specific network configuration
  #
  # modules/storage/
  #   ceph.nix        Ceph cluster services
  #   filesystems.nix Filesystem support and tools
  #   mounts.nix      Shared mountpoints / optional CephFS
  #   swap.nix        ZRAM and memory tuning
  #   backup.nix      Restic backups
  #
  # profiles/
  #   workstation.nix Desktop environment
  #   development.nix Development tools
  #   ai.nix          NVIDIA / CUDA / AI tools
  #   gaming.nix      Gaming stack
  #   hardened.nix    Security configuration
  #
  # ===================================================================
}
