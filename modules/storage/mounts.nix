# =====================================================================
# SinLess Industries — Shared Storage Mounts
# =====================================================================
#
# Responsibilities:
#   - Standardize workstation mount directories
#   - Provide optional CephFS client mounts
#   - Support on-demand systemd automounts
#   - Protect the boot process from unavailable secondary storage
#   - Keep disk UUIDs and physical devices in host-specific modules
#
# Does NOT:
#   - Format, partition, or erase disks
#   - Automatically provision Ceph OSDs
#   - Modify existing filesystem ownership
#   - Replace /mnt/aerealith
#   - Mount CephFS until explicitly configured and enabled
#
# Physical disks:
#   hosts/desktop/disks.nix
#
# Ceph services:
#   modules/storage/ceph.nix
#
# Filesystem support:
#   modules/storage/filesystems.nix
#
# Backups:
#   modules/storage/backup.nix
#
# =====================================================================

{
  config,
  lib,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    optionalAttrs
    ;

  cfg = config.sinless.storage.mounts;

  # ---------------------------------------------------------------
  # CephFS mount definition
  # ---------------------------------------------------------------

  cephFileSystem = {
    device = cfg.ceph.device;
    fsType = "ceph";

    options = [
      "_netdev"
      "noatime"
      "nofail"
      "x-systemd.automount"
      "x-systemd.idle-timeout=600"
      "x-systemd.mount-timeout=30s"
      "x-systemd.requires=network-online.target"
      "x-systemd.after=network-online.target"
      "name=${cfg.ceph.clientName}"
      "secretfile=${cfg.ceph.secretFile}"
    ];
  };

in
{
  # ===================================================================
  # OPTIONS
  # ===================================================================

  options.sinless.storage.mounts = {

    enable = mkEnableOption "shared storage mount management";

    # -----------------------------------------------------------------
    # Shared mount directories
    # -----------------------------------------------------------------

    directories = mkOption {
      type = types.listOf types.str;

      default = [
        "/mnt/data"
        "/mnt/projects"
        "/mnt/aerealith"
        "/mnt/backup"

        # Ceph mountpoints
        "/mnt/ceph"
        "/mnt/ceph/projects"
        "/mnt/ceph/models"
        "/mnt/ceph/backups"
      ];

      description = ''
        Directories created using systemd-tmpfiles.

        This does not mount storage or create filesystems.
        Existing directories and their contents are preserved.
      '';
    };

    # -----------------------------------------------------------------
    # CephFS client configuration
    # -----------------------------------------------------------------

    ceph = {

      enable = mkEnableOption "CephFS filesystem mounting";

      mountPoint = mkOption {
        type = types.str;
        default = "/mnt/ceph";

        description = "Local mountpoint for CephFS.";
      };

      device = mkOption {
        type = types.str;
        default = "";

        example = "10.42.0.254:3300:/";

        description = ''
          CephFS device string.

          Use the monitor address and filesystem path for
          the initialized cluster.
        '';
      };

      clientName = mkOption {
        type = types.str;
        default = "admin";

        example = "desktop";

        description = ''
          CephX client name without the client. prefix.

          Prefer a dedicated restricted CephFS client.
        '';
      };

      secretFile = mkOption {
        type = types.str;
        default = "/run/secrets/ceph-client";

        description = ''
          Runtime file containing the CephX client secret.

          Do not store the secret directly inside Nix code
          or the Nix store.
        '';
      };

    };
  };

  # ===================================================================
  # CONFIGURATION
  # ===================================================================

  config = mkIf cfg.enable {

    # -----------------------------------------------------------------
    # Validate CephFS configuration
    # -----------------------------------------------------------------

    assertions = [
      {
        assertion = !cfg.ceph.enable || cfg.ceph.device != "";

        message = ''
          sinless.storage.mounts.ceph.device must be configured
          before enabling the CephFS mount.
        '';
      }
      {
        assertion = !cfg.ceph.enable || lib.hasPrefix "/" cfg.ceph.mountPoint;

        message = ''
          The CephFS mountpoint must be an absolute path.
        '';
      }
      {
        assertion = !cfg.ceph.enable || lib.hasPrefix "/" cfg.ceph.secretFile;

        message = ''
          The CephFS secret file must have an absolute path.
        '';
      }
      {
        assertion = !cfg.ceph.enable || cfg.ceph.mountPoint != "/mnt/aerealith";

        message = ''
          Refusing to replace the existing Aerealith NVMe
          mount with CephFS.
        '';
      }
    ];

    # -----------------------------------------------------------------
    # Standard mount directories
    # -----------------------------------------------------------------
    #
    # tmpfiles creates directories without recursively changing
    # permissions or ownership of existing directory contents.
    #
    # Parent mountpoints must be available before any nested
    # mountpoints are used.
    # -----------------------------------------------------------------

    systemd.tmpfiles.rules = map (path: "d ${path} 0755 root root -") cfg.directories;

    # -----------------------------------------------------------------
    # Optional CephFS mount
    # -----------------------------------------------------------------
    #
    # CephFS is disabled unless explicitly enabled.
    #
    # Requires:
    #   - Running Ceph monitors
    #   - Healthy OSDs
    #   - Active MDS
    #   - Existing CephFS filesystem
    #   - Valid CephX credentials
    #
    # The automount unit activates when the path is accessed.
    # -----------------------------------------------------------------

    fileSystems = optionalAttrs cfg.ceph.enable {
      "${cfg.ceph.mountPoint}" = cephFileSystem;
    };

    # -----------------------------------------------------------------
    # Filesystem availability and backup behavior
    # -----------------------------------------------------------------
    #
    # A directory existing under /mnt does not prove that the
    # underlying filesystem is mounted.
    #
    # Services requiring secondary storage should verify their
    # mountpoints before reading or writing data.
    #
    # The Restic backup module handles these checks through:
    #
    #   sinless.backup.requiredMounts
    #
    # CephFS mounts should not be considered a substitute for
    # an off-host backup repository.
    # -----------------------------------------------------------------

    # -----------------------------------------------------------------
    # Physical disk definitions
    # -----------------------------------------------------------------
    #
    # Keep actual disks in hosts/desktop/disks.nix.
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
    # Never define an additional filesystem on the same
    # mountpoint in two modules.
    # -----------------------------------------------------------------
  };
}
