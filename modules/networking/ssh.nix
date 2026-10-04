{ lib, ... }:

{
  services.openssh = {
    enable = true;

    settings = {
      # -----------------------------------------------------------
      # Authentication
      # -----------------------------------------------------------

      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";

      PubkeyAuthentication = true;

      # -----------------------------------------------------------
      # Security
      # -----------------------------------------------------------

      X11Forwarding = false;
      AllowAgentForwarding = true;
      AllowTcpForwarding = true;

      PermitEmptyPasswords = false;

      # -----------------------------------------------------------
      # Session behavior
      # -----------------------------------------------------------

      ClientAliveInterval = 300;
      ClientAliveCountMax = 2;

      LoginGraceTime = 30;

      MaxAuthTries = 3;
      MaxSessions = 10;
      MaxStartups = "10:30:60";
    };

    # Let NixOS open the SSH port in the firewall automatically.
    openFirewall = true;
  };

  # ---------------------------------------------------------------------------
  # Host keys
  # ---------------------------------------------------------------------------
  #
  # NixOS generates host keys automatically if they do not already exist.
  #
  # Do not store private host keys in Git.
  #

  # ---------------------------------------------------------------------------
  # Notes
  # ---------------------------------------------------------------------------
  #
  # User SSH keys should be configured in one of these places:
  #
  #   users.users.<name>.openssh.authorizedKeys.keys
  #
  # or
  #
  #   users.users.<name>.openssh.authorizedKeys.keyFiles
  #
  # depending on whether you want keys embedded declaratively or sourced
  # from local/secrets-managed files.
}
