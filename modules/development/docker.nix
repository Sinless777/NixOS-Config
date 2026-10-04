{ pkgs, username, ... }:

{
  # ---------------------------------------------------------------------------
  # Docker
  # ---------------------------------------------------------------------------

  virtualisation.docker = {
    enable = true;

    # Start Docker automatically on boot.
    enableOnBoot = true;

    # Use overlay2 storage driver.
    storageDriver = "overlay2";

    # -------------------------------------------------------------------------
    # Automatic cleanup
    # -------------------------------------------------------------------------

    autoPrune = {
      enable = true;

      # Weekly cleanup.
      dates = "weekly";

      # Keep recent images/containers to avoid over-aggressive cleanup.
      flags = [
        "--all"
        "--filter"
        "until=168h"
      ];
    };

    # -------------------------------------------------------------------------
    # Docker daemon settings
    # -------------------------------------------------------------------------

    daemon.settings = {
      # Modern default cgroup driver.
      exec-opts = [
        "native.cgroupdriver=systemd"
      ];

      # Enable BuildKit-compatible behavior.
      features = {
        buildkit = true;
      };

      # Avoid giant JSON log files.
      log-driver = "json-file";

      log-opts = {
        max-size = "50m";
        max-file = "5";
      };

      # Useful for container networking.
      ip-forward = true;
      iptables = true;
    };
  };

  # ---------------------------------------------------------------------------
  # Docker Compose / tooling
  # ---------------------------------------------------------------------------

  environment.systemPackages = with pkgs; [
    docker
    docker-compose
    docker-buildx
    dive
    lazydocker
  ];

  # ---------------------------------------------------------------------------
  # User access
  # ---------------------------------------------------------------------------

  users.users.${username}.extraGroups = [
    "docker"
  ];

  # ---------------------------------------------------------------------------
  # Kernel / networking
  # ---------------------------------------------------------------------------

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  # ---------------------------------------------------------------------------
  # Notes
  # ---------------------------------------------------------------------------
  #
  # Docker volumes and container state live under:
  #
  #   /var/lib/docker
  #
  # This directory is intentionally excluded from the generic Restic backup
  # module because application-specific container data should be backed up
  # intentionally.
  #
  # For development projects, prefer bind mounts into:
  #
  #   /mnt/projects
  #   /mnt/aerealith
  #
  # where appropriate.
}
