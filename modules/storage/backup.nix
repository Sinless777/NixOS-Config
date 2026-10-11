# =====================================================================
# SinLess Industries — Restic Backup Module
# =====================================================================
#
# Features:
#   - Declarative Restic backups
#   - Configurable repositories and credentials
#   - Daily automated backups
#   - Retention and pruning
#   - Optional repository integrity checks
#   - Mounted filesystem verification
#   - Aerealith project protection
#   - Ceph-compatible file-level backups
#   - No direct backup of raw Ceph OSD data
#
# Important:
#   Restic does not replace Ceph replication.
#   Ceph replication does not replace backups.
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
    optionalAttrs
    types
    concatMapStringsSep
    escapeShellArg
    hasPrefix
    hasSuffix
    removeSuffix
    ;

  cfg = config.sinless.backup;

  # Normalize paths for local repository safety checks.
  normalizePath =
    path:
    if path == "/" then
      "/"
    else if hasSuffix "/" path then
      removeSuffix "/" path
    else
      path;

  isInside =
    parent: child:
    let
      p = normalizePath parent;
      c = normalizePath child;
    in
    p == "/" || c == p || hasPrefix "${p}/" c;

  isLocalRepository = hasPrefix "/" cfg.repository;

  # Verify that a local repository is not inside a backup source.
  repositoryIsSafe = !isLocalRepository || !(lib.any (path: isInside path cfg.repository) cfg.paths);

  # Paths that must actually be mounted, not merely present.
  mountChecks = concatMapStringsSep "\n" (path: ''
    if ! ${pkgs.util-linux}/bin/mountpoint -q \
      ${escapeShellArg path}; then
      echo "ERROR: Required backup mount unavailable: ${path}" >&2
      exit 1
    fi
  '') cfg.requiredMounts;

  # Verify sources and credentials before Restic starts.
  prepareBackup = ''
    set -eu

    echo "Checking Restic backup prerequisites..."

    if [ ! -r ${escapeShellArg cfg.passwordFile} ]; then
      echo "ERROR: Restic password file unavailable." >&2
      exit 1
    fi

    ${concatMapStringsSep "\n" (path: ''
      if [ ! -d ${escapeShellArg path} ]; then
        echo "ERROR: Backup source missing: ${path}" >&2
        exit 1
      fi
    '') cfg.requiredPaths}

    ${mountChecks}

    ${lib.optionalString isLocalRepository ''
      repo=${escapeShellArg cfg.repository}

      # Prevent writes to an unmounted local backup disk.
      ${lib.optionalString (cfg.repositoryMount != null) ''
        if ! ${pkgs.util-linux}/bin/mountpoint -q \
          ${escapeShellArg cfg.repositoryMount}; then
          echo "ERROR: Backup repository mount unavailable." >&2
          exit 1
        fi
      ''}
    ''}

    echo "Backup prerequisites verified."
  '';

in
{
  # ===================================================================
  # OPTIONS
  # ===================================================================

  options.sinless.backup = {

    # -----------------------------------------------------------------
    # General
    # -----------------------------------------------------------------

    enable = mkEnableOption "automatic Restic backups";

    # -----------------------------------------------------------------
    # Repository
    # -----------------------------------------------------------------

    repository = mkOption {
      type = types.str;
      default = "";

      example = "sftp:backup@server:/backups/desktop";

      description = ''
        Restic repository destination.

        Supported examples:

          /mnt/backup/restic
          sftp:user@server:/backups/desktop
          s3:s3.amazonaws.com/bucket
          rclone:remote:bucket/path

        Prefer another physical machine or an offsite repository.
      '';
    };

    repositoryMount = mkOption {
      type = types.nullOr types.str;
      default = null;

      example = "/mnt/backup";

      description = ''
        Required mountpoint for a local repository.

        Prevents writing backups to the underlying root filesystem
        when a dedicated backup drive is unavailable.
      '';
    };

    passwordFile = mkOption {
      type = types.str;
      default = "/run/secrets/restic-password";

      description = ''
        Runtime path to the Restic repository password.

        Must be readable by root.

        Use sops-nix, systemd credentials, or another secure
        secret-management mechanism.
      '';
    };

    environmentFile = mkOption {
      type = types.nullOr types.str;
      default = null;

      description = ''
        Optional runtime environment file containing credentials
        for remote repository backends.

        Do not store real credentials directly in the Nix store.
      '';
    };

    initialize = mkOption {
      type = types.bool;
      default = true;

      description = ''
        Initialize the repository automatically when necessary.

        Initialization requires valid credentials and an accessible
        destination.
      '';
    };

    # -----------------------------------------------------------------
    # Backup sources
    # -----------------------------------------------------------------

    paths = mkOption {
      type = types.listOf types.str;

      default = [
        "/home"
        "/mnt/aerealith"
      ];

      description = ''
        Directories included in the backup.

        Add other project mounts explicitly when available.
        Source paths are backed up as files, not raw disks.
      '';
    };

    requiredPaths = mkOption {
      type = types.listOf types.str;

      default = [
        "/home"
        "/mnt/aerealith"
      ];

      description = ''
        Paths that must exist before a backup starts.

        Missing required paths cause the backup to fail rather
        than silently creating an incomplete snapshot.
      '';
    };

    requiredMounts = mkOption {
      type = types.listOf types.str;

      default = [
        "/mnt/aerealith"
      ];

      description = ''
        Filesystems that must be mounted before backups start.

        Particularly useful for Aerealith, CephFS, and
        other separately mounted project storage.
      '';
    };

    # -----------------------------------------------------------------
    # Exclusions
    # -----------------------------------------------------------------

    exclude = mkOption {
      type = types.listOf types.str;

      default = [
        # -----------------------------------------------------------
        # User caches and trash
        # -----------------------------------------------------------

        "/home/*/.cache"
        "/home/*/.local/share/Trash"
        "/home/*/.npm"
        "/home/*/.pnpm-store"
        "/home/*/.cargo/registry"
        "/home/*/.cargo/git"

        # -----------------------------------------------------------
        # Development build artifacts
        # -----------------------------------------------------------

        "**/node_modules"
        "**/.venv"
        "**/venv"
        "**/__pycache__"
        "**/.pytest_cache"
        "**/.mypy_cache"
        "**/.ruff_cache"
        "**/.tox"

        "**/target"
        "**/dist"
        "**/build"
        "**/.next"
        "**/.turbo"
        "**/.nx/cache"

        # -----------------------------------------------------------
        # Git temporary content
        # -----------------------------------------------------------

        "**/.git/lfs/tmp"

        # -----------------------------------------------------------
        # Nix outputs
        # -----------------------------------------------------------

        "**/result"
        "**/result-*"

        # -----------------------------------------------------------
        # Temporary files
        # -----------------------------------------------------------

        "**/.tmp"
        "**/tmp"
        "**/*.swp"
        "**/*.swo"

        # -----------------------------------------------------------
        # Containers / virtual machines
        # -----------------------------------------------------------

        "/var/lib/docker"
        "/var/lib/containers"
        "/var/lib/libvirt"

        # -----------------------------------------------------------
        # Ceph internals
        # -----------------------------------------------------------

        "/var/lib/ceph"
        "/run/ceph"
        "/var/log/ceph"

        # -----------------------------------------------------------
        # Operating system pseudo-filesystems
        # -----------------------------------------------------------

        "/proc"
        "/sys"
        "/dev"
        "/run"
        "/tmp"
      ];

      description = ''
        File and directory patterns excluded from backups.

        Back up application data stored on CephFS through
        explicit source paths. Do not copy live Ceph OSD data
        directories as ordinary filesystem backups.
      '';
    };

    # -----------------------------------------------------------------
    # Scheduling
    # -----------------------------------------------------------------

    schedule = mkOption {
      type = types.str;
      default = "daily";

      example = "03:00";

      description = "Systemd calendar expression for backups.";
    };

    randomizedDelay = mkOption {
      type = types.str;
      default = "30m";

      description = ''
        Random delay added to scheduled backups.
        Helps distribute backup load across multiple machines.
      '';
    };

    persistentTimer = mkOption {
      type = types.bool;
      default = true;

      description = ''
        Run missed scheduled backups after the system
        becomes available again.
      '';
    };

    # -----------------------------------------------------------------
    # Retention
    # -----------------------------------------------------------------

    retention = {

      daily = mkOption {
        type = types.int;
        default = 7;
        description = "Number of daily snapshots to retain.";
      };

      weekly = mkOption {
        type = types.int;
        default = 4;
        description = "Number of weekly snapshots to retain.";
      };

      monthly = mkOption {
        type = types.int;
        default = 12;
        description = "Number of monthly snapshots to retain.";
      };

      yearly = mkOption {
        type = types.int;
        default = 3;
        description = "Number of yearly snapshots to retain.";
      };
    };

    # -----------------------------------------------------------------
    # Integrity verification
    # -----------------------------------------------------------------

    runCheck = mkOption {
      type = types.bool;
      default = false;

      description = ''
        Run a Restic repository integrity check after backup.

        This checks repository structure by default.
        It does not automatically read every stored data blob.
      '';
    };

    checkOpts = mkOption {
      type = types.listOf types.str;
      default = [ ];

      example = [
        "--read-data-subset=5%"
      ];

      description = "Additional arguments for restic check.";
    };

    # -----------------------------------------------------------------
    # Operational options
    # -----------------------------------------------------------------

    extraBackupArgs = mkOption {
      type = types.listOf types.str;

      default = [
        "--one-file-system"
        "--tag=sinless"
        "--tag=desktop"
      ];

      description = ''
        Extra arguments passed to restic backup.

        --one-file-system avoids unintentionally descending
        into nested mountpoints under a backup source.
        Explicitly listed mountpoints are still backup sources.
      '';
    };

  };

  # ===================================================================
  # CONFIGURATION
  # ===================================================================

  config = mkIf cfg.enable {

    # -----------------------------------------------------------------
    # Configuration validation
    # -----------------------------------------------------------------

    assertions = [
      {
        assertion = cfg.repository != "";

        message = ''
          sinless.backup.repository must be configured
          before enabling automatic Restic backups.
        '';
      }

      {
        assertion = cfg.paths != [ ];

        message = ''
          sinless.backup.paths must contain at least
          one directory.
        '';
      }

      {
        assertion = repositoryIsSafe;

        message = ''
          The local Restic repository must not reside
          inside a directory included in backup paths.
        '';
      }

      {
        assertion = lib.all (path: lib.elem path cfg.paths) cfg.requiredPaths;

        message = ''
          Every requiredPaths entry must also appear
          in sinless.backup.paths.
        '';
      }

      {
        assertion = lib.all (path: lib.elem path cfg.paths) cfg.requiredMounts;

        message = ''
          Every requiredMounts entry must appear
          explicitly in sinless.backup.paths.
        '';
      }

      {
        assertion = cfg.repositoryMount == null || isLocalRepository;

        message = ''
          repositoryMount is intended only for
          local filesystem repositories.
        '';
      }

      {
        assertion = lib.all (value: value >= 0) [
          cfg.retention.daily
          cfg.retention.weekly
          cfg.retention.monthly
          cfg.retention.yearly
        ];

        message = ''
          Backup retention counts cannot be negative.
        '';
      }
    ];

    # -----------------------------------------------------------------
    # Packages
    # -----------------------------------------------------------------

    environment.systemPackages = with pkgs; [
      restic
      rsync
      smartmontools
    ];

    # -----------------------------------------------------------------
    # Restic system backup
    # -----------------------------------------------------------------

    services.restic.backups.system = {

      inherit (cfg)
        repository
        passwordFile
        paths
        initialize
        exclude
        runCheck
        checkOpts
        extraBackupArgs
        ;

      environmentFile = cfg.environmentFile;

      # Run as root for system-level backups.
      user = "root";

      # Preflight verification.
      backupPrepareCommand = prepareBackup;

      # ---------------------------------------------------------------
      # Schedule
      # ---------------------------------------------------------------

      timerConfig = {
        OnCalendar = cfg.schedule;
        Persistent = cfg.persistentTimer;
        RandomizedDelaySec = cfg.randomizedDelay;
      };

      # ---------------------------------------------------------------
      # Retention
      # ---------------------------------------------------------------

      pruneOpts = [
        "--keep-daily=${toString cfg.retention.daily}"
        "--keep-weekly=${toString cfg.retention.weekly}"
        "--keep-monthly=${toString cfg.retention.monthly}"
        "--keep-yearly=${toString cfg.retention.yearly}"
      ];

    };

  };
}
