{ pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # AppArmor
  # ---------------------------------------------------------------------------

  security.apparmor = {
    enable = true;

    # Keep AppArmor policies enforced rather than complain-only.
    killUnconfinedConfinables = false;

    packages = with pkgs; [
      apparmor-profiles
      apparmor-utils
    ];
  };

  # ---------------------------------------------------------------------------
  # AppArmor utilities
  # ---------------------------------------------------------------------------

  environment.systemPackages = with pkgs; [
    apparmor-parser
    apparmor-utils
  ];

  # ---------------------------------------------------------------------------
  # Notes
  # ---------------------------------------------------------------------------
  #
  # Useful commands:
  #
  #   sudo aa-status
  #   sudo aa-enforce <profile>
  #   sudo aa-complain <profile>
  #   sudo aa-logprof
  #
  # Application-specific custom profiles can be added later if needed.
}
