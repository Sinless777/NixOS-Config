{ ... }:

{
  # ---------------------------------------------------------------------------
  # Fail2ban
  # ---------------------------------------------------------------------------

  services.fail2ban = {
    enable = true;

    # Ban repeated offenders for 1 hour by default.
    bantime = "1h";

    # Count failures inside this window.
    maxretry = 5;

    # -------------------------------------------------------------------------
    # SSH jail
    # -------------------------------------------------------------------------

    jails = {
      sshd = {
        settings = {
          enabled = true;
          port = "ssh";
          filter = "sshd";
          backend = "systemd";

          # 5 failures in 10 minutes triggers a ban.
          maxretry = 5;
          findtime = "10m";
          bantime = "1h";
        };
      };
    };
  };

  # ---------------------------------------------------------------------------
  # Notes
  # ---------------------------------------------------------------------------
  #
  # This works with the OpenSSH service configured in:
  #
  #   modules/networking/ssh.nix
  #
  # SSH already uses:
  #
  #   - password authentication disabled
  #   - keyboard-interactive authentication disabled
  #   - root login disabled
  #   - public key authentication enabled
  #
  # Fail2ban adds another layer by temporarily blocking hosts that repeatedly
  # fail authentication.
  #
  # Useful commands:
  #
  #   sudo fail2ban-client status
  #   sudo fail2ban-client status sshd
  #   sudo fail2ban-client set sshd unbanip <IP>
  #
}
