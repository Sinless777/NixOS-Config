# =====================================================================
# Ceph Storage — NixOS
# =====================================================================
#
# Host: desktop
# Platform: AMD Threadripper / X399
#
# Purpose:
#   - Native NixOS Ceph deployment
#   - Local single-node storage cluster
#   - Future multi-node cluster expansion
#   - CephFS / RBD support
#   - Explicit OSD management
#
# Safety:
#   - Never automatically wipes disks
#   - Never automatically provisions OSDs
#   - Protects existing storage by requiring manual OSD setup
#   - Cluster daemons disabled until initialized
#
# Storage candidates (six prepared disks):
#   SATA:
#     sda       Samsung PM830 256GB
#     sdc       Seagate 320GB (unreliable; do not provision)
#     sde       Seagate 500GB (health testing required)
#
#   NVMe:
#     nvme3n1   SanDisk Optimus 5100 1TB
#     nvme2n1   Samsung 128GB (inspect error log)
#     nvme0n1   WD PC SN5000S 512GB
#
# Excluded:
#   sdb       Failing Seagate 3TB
#   sdd       Existing data disk
#   sdf       NixOS system disk
#   nvme1n1   Aerealith project storage
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
    mkIf
    mkOption
    types
    optional
    ;

  cfg = config.sinless.storage.ceph;

in
{
  # -------------------------------------------------------------------
  # Module options
  # -------------------------------------------------------------------

  options.sinless.storage.ceph = {

    enable = mkEnableOption ''
      Ceph storage management and native NixOS integration
    '';

    deployDaemons = mkEnableOption ''
      native Ceph MON and MGR daemons after cluster initialization
    '';

    fsid = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "433a2193-4f8a-47a0-95d2-209d7ca2cca5";
      description = ''
        Unique Ceph cluster FSID.

        Generate once using uuidgen before initializing the cluster.
        Do not change after creating the cluster.
      '';
    };

    monitorId = mkOption {
      type = types.str;
      default = "desktop";
      description = "Local Ceph monitor daemon ID.";
    };

    managerId = mkOption {
      type = types.str;
      default = "desktop";
      description = "Local Ceph manager daemon ID.";
    };

    monitorAddress = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "10.42.0.254";
      description = ''
        Stable IP address used for the initial Ceph monitor.

        Set this to the desktop's actual management or storage IP.
      '';
    };

    publicNetwork = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "10.42.0.0/24";
      description = ''
        Ceph client/public network.

        Leave unset until the correct network has been verified.
      '';
    };

    clusterNetwork = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "10.42.10.0/24";
      description = ''
        Optional dedicated Ceph replication network.

        Leave null when using a shared network.
      '';
    };

    osdIds = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [
        "0"
        "1"
        "2"
      ];
      description = ''
        IDs of already initialized native Ceph OSD daemons.

        Set only after provisioning OSDs and their keyrings.
        These IDs are not disk names.
      '';
    };

    enableMds = mkEnableOption ''
      local CephFS metadata daemon after filesystem creation
    '';

    openFirewall = mkEnableOption ''
      Ceph network ports on interfaces governed by the host firewall
    '';

    enableChrony = mkEnableOption ''
      Chrony time synchronization for Ceph
    '';
  };

  # -------------------------------------------------------------------
  # System configuration
  # -------------------------------------------------------------------

  config = mkIf cfg.enable {

    assertions = [
      {
        assertion = !cfg.deployDaemons || cfg.fsid != null;

        message = ''
          Ceph daemon deployment requires
          sinless.storage.ceph.fsid.
        '';
      }
      {
        assertion = !cfg.deployDaemons || cfg.monitorAddress != null;

        message = ''
          Ceph daemon deployment requires
          sinless.storage.ceph.monitorAddress.
        '';
      }
      {
        assertion = !cfg.enableMds || cfg.deployDaemons;

        message = ''
          Ceph MDS requires deployDaemons = true.
        '';
      }
    ];

    # ---------------------------------------------------------------
    # Packages
    # ---------------------------------------------------------------

    environment.systemPackages = with pkgs; [
      ceph
      lvm2
      smartmontools
      util-linux
      parted
      gptfdisk
      python3
      jq
      iproute2
      ethtool
      rsync
    ];

    # ---------------------------------------------------------------
    # Kernel modules
    # ---------------------------------------------------------------

    boot.kernelModules = [
      "rbd"
      "ceph"
    ];

    # ---------------------------------------------------------------
    # Time synchronization
    # ---------------------------------------------------------------

    services.chrony.enable = cfg.enableChrony;

    # ---------------------------------------------------------------
    # Native Ceph daemons
    #
    # This does NOT bootstrap a cluster.
    # Existing cluster keyrings/state must first be initialized.
    # ---------------------------------------------------------------

    services.ceph = mkIf cfg.deployDaemons {

      enable = true;

      global = {
        clusterName = "ceph";

        fsid = cfg.fsid;

        monInitialMembers = cfg.monitorId;

        monHost = cfg.monitorAddress;

        publicNetwork = cfg.publicNetwork;

        clusterNetwork = cfg.clusterNetwork;

        authClusterRequired = "cephx";
        authServiceRequired = "cephx";
        authClientRequired = "cephx";
      };

      extraConfig = {
        "mon allow pool delete" = "false";

        "osd pool default size" = "3";
        "osd pool default min size" = "2";

        "mon osd down out interval" = "600";
      };

      mon = {
        enable = true;
        daemons = [ cfg.monitorId ];
      };

      mgr = {
        enable = true;
        daemons = [ cfg.managerId ];
      };

      osd = {
        enable = cfg.osdIds != [ ];
        daemons = cfg.osdIds;
      };

      mds = {
        enable = cfg.enableMds;
        daemons = optional cfg.enableMds cfg.managerId;
      };

      client.enable = true;
    };

    # ---------------------------------------------------------------
    # Firewall
    #
    # MON v2: TCP 3300
    # MON v1: TCP 6789
    # OSD/MGR/MDS: TCP 6800-7568
    #
    # Only enable on trusted Ceph network interfaces.
    # ---------------------------------------------------------------

    networking.firewall = mkIf (cfg.deployDaemons && cfg.openFirewall) {
      allowedTCPPorts = [
        3300
        6789
      ];

      allowedTCPPortRanges = [
        {
          from = 6800;
          to = 7568;
        }
      ];
    };

    # ---------------------------------------------------------------
    # No disk automation
    # ---------------------------------------------------------------
    #
    # OSD provisioning will be performed separately after:
    #
    #   1. Confirming drive health
    #   2. Initializing the monitor
    #   3. Establishing cluster authentication
    #   4. Creating the manager
    #   5. Confirming CRUSH placement and replication
    #
    # Never use automatic all-available-disk provisioning
    # with this desktop's mixed-use storage.
    # ---------------------------------------------------------------
  };
}
