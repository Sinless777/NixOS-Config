{ lib, ... }:

{
  # ---------------------------------------------------------------------------
  # Kernel / process hardening
  # ---------------------------------------------------------------------------

  boot.kernel.sysctl = lib.mapAttrs (_: value: lib.mkDefault value) {
    # Restrict access to kernel pointers.
    "kernel.kptr_restrict" = 2;

    # Restrict access to dmesg for unprivileged users.
    "kernel.dmesg_restrict" = 1;

    # Restrict ptrace to parent/child relationships.
    "kernel.yama.ptrace_scope" = 1;

    # Disable SysRq unless explicitly needed.
    "kernel.sysrq" = 0;

    # Protect against common symlink / hardlink attacks.
    "fs.protected_symlinks" = 1;
    "fs.protected_hardlinks" = 1;
    "fs.protected_fifos" = 2;
    "fs.protected_regular" = 2;

    # -------------------------------------------------------------------------
    # Networking hardening
    # -------------------------------------------------------------------------

    # Disable ICMP redirects.
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;

    # Do not send redirects.
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.default.send_redirects" = 0;

    # Disable source routed packets.
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv4.conf.default.accept_source_route" = 0;
    "net.ipv6.conf.all.accept_source_route" = 0;
    "net.ipv6.conf.default.accept_source_route" = 0;

    # Log suspicious packets.
    "net.ipv4.conf.all.log_martians" = 1;
    "net.ipv4.conf.default.log_martians" = 1;

    # Reverse-path filtering.
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;

    # SYN flood protection.
    "net.ipv4.tcp_syncookies" = 1;
  };

  # ---------------------------------------------------------------------------
  # Temporary directories
  # ---------------------------------------------------------------------------

  # systemd manages /tmp cleanup.
  systemd.tmpfiles.rules = [
    "D /tmp 1777 root root 7d"
    "D /var/tmp 1777 root root 30d"
  ];

  # ---------------------------------------------------------------------------
  # PAM
  # ---------------------------------------------------------------------------

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "core";
      value = "0";
    }
  ];

  # ---------------------------------------------------------------------------
  # Core dump policy
  # ---------------------------------------------------------------------------
  #
  # Prevent accidental leakage of secrets through userland core dumps.
  #

  systemd.coredump.settings.Coredump = {
    Storage = "none";
    ProcessSizeMax = 0;
  };

  # ---------------------------------------------------------------------------
  # SUID / privilege defaults
  # ---------------------------------------------------------------------------

  # Disable setuid wrapping unless individual packages explicitly need it.
  security.wrappers = lib.mkDefault { };

  # ---------------------------------------------------------------------------
  # Polkit
  # ---------------------------------------------------------------------------

  security.polkit.enable = true;

  # ---------------------------------------------------------------------------
  # Notes
  # ---------------------------------------------------------------------------
  #
  # Intentionally configured elsewhere:
  #
  #   modules/security/apparmor.nix
  #   modules/security/fail2ban.nix
  #   modules/security/sops.nix
  #   modules/security/sudo.nix
  #
  # Firewall rules live in:
  #
  #   modules/networking/firewall.nix
  #
  # OpenSSH hardening lives in:
  #
  #   modules/networking/ssh.nix
  #
}
