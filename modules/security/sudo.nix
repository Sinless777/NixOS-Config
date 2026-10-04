{ lib, username, ... }:

{
  security.sudo = {
    enable = true;

    # Wheel users may use sudo without a password.
    wheelNeedsPassword = false;

    # Explicit rule for the primary workstation user.
    extraRules = [
      {
        users = [ username ];

        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };

  # ---------------------------------------------------------------------------
  # Notes
  # ---------------------------------------------------------------------------
  #
  # This is appropriate for a trusted personal workstation, but it should not
  # automatically be reused on hardened servers.
  #
  # Server profiles can override this later with:
  #
  #   security.sudo.wheelNeedsPassword = true;
  #
  # or more restrictive command-specific rules.
}
