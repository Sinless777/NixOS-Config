{ lib, ... }:

{
  # ---------------------------------------------------------------------------
  # PAM baseline
  # ---------------------------------------------------------------------------

  security.pam = {
    # Keep login limits enabled so /etc/security/limits.conf-style rules apply.
    loginLimits = [
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

      {
        domain = "*";
        type = "hard";
        item = "nofile";
        value = "1048576";
      }

      {
        domain = "*";
        type = "soft";
        item = "nofile";
        value = "1048576";
      }
    ];
  };

  # ---------------------------------------------------------------------------
  # Password policy
  # ---------------------------------------------------------------------------
  #
  # PAM services should never accept empty passwords.
  #

  security.pam.services = {
    login.allowNullPassword = lib.mkForce false;
    sudo.allowNullPassword = false;
    su.allowNullPassword = false;

    # GNOME / GDM
    gdm.allowNullPassword = false;
    gdm-autologin.allowNullPassword = false;

    # Screen locking
    gnome-keyring.enable = true;
  };

  # ---------------------------------------------------------------------------
  # Login behavior
  # ---------------------------------------------------------------------------
  #
  # Keep system authentication conventional and compatible with:
  #
  #   GNOME
  #   GDM autologin
  #   sudo
  #   SSH
  #   GNOME Keyring
  #
  # Stronger MFA / hardware token requirements should be added deliberately
  # rather than forced globally here.
  #

  # ---------------------------------------------------------------------------
  # Future hardening options
  # ---------------------------------------------------------------------------
  #
  # Good additions later:
  #
  #   - FIDO2 / YubiKey authentication
  #   - fingerprint authentication
  #   - pam_u2f
  #   - login attempt delays / lockouts
  #   - hardware-backed sudo authentication
  #
}
