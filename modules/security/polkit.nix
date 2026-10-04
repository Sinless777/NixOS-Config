{ username, ... }:

{
  # ---------------------------------------------------------------------------
  # Polkit
  # ---------------------------------------------------------------------------

  security.polkit = {
    enable = true;

    # -------------------------------------------------------------------------
    # Custom authorization rules
    # -------------------------------------------------------------------------
    #
    # These rules keep normal GNOME desktop workflows working while limiting
    # administrative authorization to the primary trusted workstation user.
    #

    extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (
          subject.user == "${username}" &&
          subject.isInGroup("wheel")
        ) {
          return polkit.Result.AUTH_SELF_KEEP;
        }
      });
    '';
  };

  # ---------------------------------------------------------------------------
  # Notes
  # ---------------------------------------------------------------------------
  #
  # AUTH_SELF_KEEP means:
  #
  #   - the user must authenticate for privileged actions
  #   - successful authorization may be cached temporarily
  #
  # This is intentionally stricter than:
  #
  #   polkit.Result.YES
  #
  # which would silently authorize actions without authentication.
  #
  # GNOME components such as:
  #
  #   - GNOME Settings
  #   - Disks
  #   - NetworkManager
  #   - Flatpak / software management
  #   - power / system controls
  #
  # rely on Polkit for privileged operations.
  #
  # Avoid broad "allow everything" Polkit rules because that would undermine
  # the rest of the workstation hardening.
}
