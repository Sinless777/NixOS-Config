{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.sinless.backup;
in
{
  # ---------------------------------------------------------------------------
  # Backup options
  # ---------------------------------------------------------------------------

  options.sinless.backup = {
    enable = lib.mkEnableOption "automatic Restic backups";

    repository = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = ''
        Restic repository destination.

        Examples:

          /mnt/backup/restic
          sftp:user@server:/backups/desktop
          rclone:b2:bucket-name
          s3:s3.amazonaws.com/bucket-name
      '';
    };

    passwordFile = lib.mkOption {
      type = lib.types.str;
      default = "/run/secrets/restic-password";
      description = ''
        Path to the file containing the Restic repository password.

        This should normally be provided by sops-nix.
      '';
    };

    paths = lib.mkOption {
      type = lib.types.listOf lib.types.str;

      default = [
        "/home"
        "/mnt/projects"
        "/mnt/aerealith"
      ];

      description = "Directories included in backups.";
    };

    exclude = lib.mkOption {
      type = lib.types.listOf lib.types.str;

      default = [
        # Trash / caches
        "/home/*/.cache"
        "/home/*/.local/share/Trash"

        # Development caches
        "/home/*/.npm"
        "/home/*/.pnpm-store"
        "/home/*/.cargo/registry"
        "/home/*/.cargo/git"

        # Node projects
        "**/node_modules"

        # Python
        "**/.venv"
        "**/__pycache__"

        # Rust
        "**/target"

        # Git worktree junk
        "**/.git/lfs/tmp"

        # Nix build outputs
        "**/result"
        "**/result-*"

        # Temporary files
        "**/.tmp"
        "**/tmp"

        # VM/container data should be backed up separately where appropriate.
        "/var/lib/docker"
        "/var/lib/libvirt"
      ];

      description = "Patterns excluded from backups.";
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;

      description = ''
        Optional environment file used for remote repositories.

        This is useful for S3, Backblaze B2, Rclone, and similar backends.
      '';
    };

    initialize = lib.mkOption {
      type = lib.types.bool;
      default = true;

      description = "Automatically initialize the Restic repository.";
    };
  };

  # ---------------------------------------------------------------------------
  # Configuration
  # ---------------------------------------------------------------------------

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      restic
    ];

    services.restic.backups.system = {
      inherit (cfg)
        repository
        passwordFile
        paths
        initialize
        ;

      exclude = cfg.exclude;

      environmentFile = cfg.environmentFile;

      # -----------------------------------------------------------------------
      # Schedule
      # -----------------------------------------------------------------------

      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;

        # Avoid every machine starting a backup at exactly the same moment.
        RandomizedDelaySec = "30m";
      };

      # -----------------------------------------------------------------------
      # Retention
      # -----------------------------------------------------------------------

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 12"
        "--keep-yearly 3"
      ];
    };
  };
}
