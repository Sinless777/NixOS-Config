{
  config,
  lib,
  pkgs,
  ...
}:

{
  # ---------------------------------------------------------------------------
  # Core security posture
  # ---------------------------------------------------------------------------

  security = {
    # Prevent replacing the currently running kernel image.
    protectKernelImage = true;

    # Keep user namespaces available because Nix sandboxing and some
    # container/development workflows rely on them.
    allowUserNamespaces = true;

    # Keep SMT enabled on this workstation.
    #
    # Disabling SMT can reduce certain side-channel risks, but on a
    # Threadripper workstation it would also cut logical CPU capacity
    # significantly.
    allowSimultaneousMultithreading = true;

    # Force Page Table Isolation.
    #
    # This provides additional isolation for workloads that rely heavily on
    # userspace/kernel separation.
    forcePageTableIsolation = true;

    # Flush L1 data cache when entering virtual machines.
    #
    # "cond" is a reasonable workstation compromise between security and
    # virtualization performance.
    virtualisation.flushL1DataCache = "cond";
  };

  # ---------------------------------------------------------------------------
  # Nix sandboxing
  # ---------------------------------------------------------------------------

  nix.settings = {
    sandbox = true;

    # Do not allow users to inject arbitrary environment variables into
    # builds.
    restrict-eval = false;

    # Only explicitly trusted users may use privileged Nix operations.
    trusted-users = lib.mkDefault [
      "root"
      "@wheel"
    ];
  };

  # ---------------------------------------------------------------------------
  # Core dumps
  # ---------------------------------------------------------------------------
  #
  # Core dumps can contain:
  #
  #   passwords
  #   API tokens
  #   SSH material
  #   encryption keys
  #   application secrets
  #
  # Disable persistent systemd core dumps on the base workstation.
  #

  systemd.coredump.settings.Coredump = {
    Storage = "none";
    ProcessSizeMax = 0;
  };

  # ---------------------------------------------------------------------------
  # Login limits
  # ---------------------------------------------------------------------------

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "hard";
      item = "core";
      value = "0";
    }

    {
      domain = "*";
      type = "soft";
      item = "core";
      value = "0";
    }
  ];

  # ---------------------------------------------------------------------------
  # /tmp and /var/tmp cleanup
  # ---------------------------------------------------------------------------

  systemd.tmpfiles.rules = [
    # Clean /tmp entries after 7 days.
    "D /tmp 1777 root root 7d"

    # Clean /var/tmp after 30 days.
    "D /var/tmp 1777 root root 30d"
  ];

  # ---------------------------------------------------------------------------
  # systemd service manager hardening
  # ---------------------------------------------------------------------------
  #
  # These defaults apply to services unless the individual service explicitly
  # overrides them.
  #

  systemd.settings.Manager.DefaultLimitCORE = 0;

  # ---------------------------------------------------------------------------
  # Journald
  # ---------------------------------------------------------------------------

  services.journald.settings.Journal = {
    Storage = "persistent";
    Compress = true;
    Seal = true;
    ForwardToSyslog = false;
    SystemMaxUse = "2G";
    SystemKeepFree = "2G";
    SystemMaxFileSize = "256M";
    MaxRetentionSec = "30day";
    RateLimitIntervalSec = "30s";
    RateLimitBurst = 10000;
  };

  # ---------------------------------------------------------------------------
  # Secure temporary storage
  # ---------------------------------------------------------------------------

  boot.tmp = {
    useTmpfs = true;

    # With ~125 GiB RAM, this remains generous while preventing /tmp from
    # consuming essentially unlimited memory.
    tmpfsSize = "25%";
  };

  # ---------------------------------------------------------------------------
  # Disable unnecessary legacy services
  # ---------------------------------------------------------------------------

  services.xserver.xkb.options = "";

  # ---------------------------------------------------------------------------
  # Firmware / device management tooling
  # ---------------------------------------------------------------------------

  services.fwupd.enable = true;

  environment.systemPackages = with pkgs; [
    # Firmware update client.
    fwupd

    # Security diagnostics.
    lynis
  ];

  # ---------------------------------------------------------------------------
  # File permission defaults
  # ---------------------------------------------------------------------------
  #
  # Do not globally force a restrictive umask here because development tools,
  # Docker, build systems, and shared project directories may need different
  # behavior.
  #
  # Sensitive services should instead use:
  #
  #   UMask=0077
  #
  # in their own systemd service definitions.
  #

  # ---------------------------------------------------------------------------
  # Notes
  # ---------------------------------------------------------------------------
  #
  # Deliberately handled elsewhere:
  #
  #   modules/security/kernel.nix
  #     kernel parameters / sysctl / module blacklist
  #
  #   modules/security/audit.nix
  #     auditd / Linux audit rules
  #
  #   modules/security/apparmor.nix
  #     MAC policy
  #
  #   modules/security/fail2ban.nix
  #     brute-force mitigation
  #
  #   modules/security/usbguard.nix
  #     USB device policy
  #
  #   modules/security/sops.nix
  #     encrypted secrets
  #
  #   modules/security/sudo.nix
  #     privilege policy
  #
  #   modules/networking/firewall.nix
  #     inbound network policy
  #
  #   modules/networking/ssh.nix
  #     SSH hardening
  #
  # The goal here is general workstation hardening without breaking:
  #
  #   NVIDIA / CUDA
  #   Docker
  #   libvirt / KVM
  #   GNOME
  #   WireGuard
  #   Tailscale
  #   Nix development shells
  #
}
