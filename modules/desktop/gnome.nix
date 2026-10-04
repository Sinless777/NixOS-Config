{ pkgs, username, ... }:

{
  # ---------------------------------------------------------------------------
  # GNOME Desktop
  # ---------------------------------------------------------------------------

  services.desktopManager.gnome.enable = true;

  # ---------------------------------------------------------------------------
  # GDM Display Manager
  # ---------------------------------------------------------------------------

  services.displayManager.gdm = {
    enable = true;

  };

  # ---------------------------------------------------------------------------
  # Automatic Login
  # ---------------------------------------------------------------------------

  services.displayManager.autoLogin = {
    enable = true;
    user = username;
  };

  # ---------------------------------------------------------------------------
  # GNOME Core Applications
  # ---------------------------------------------------------------------------

  services.gnome.core-apps.enable = true;

  # ---------------------------------------------------------------------------
  # dconf
  # ---------------------------------------------------------------------------

  programs.dconf.enable = true;

  # ---------------------------------------------------------------------------
  # GNOME Keyring
  # ---------------------------------------------------------------------------

  services.gnome.gnome-keyring.enable = true;

  # ---------------------------------------------------------------------------
  # Flatpak
  # ---------------------------------------------------------------------------

  services.flatpak.enable = true;

  # ---------------------------------------------------------------------------
  # GNOME Packages
  # ---------------------------------------------------------------------------

  environment.systemPackages = with pkgs; [
    # Advanced GNOME configuration.
    gnome-tweaks

    # GUI for managing GNOME extensions.
    gnome-extension-manager

    # Dock extension.
    gnomeExtensions.dash-to-dock
  ];

  # ---------------------------------------------------------------------------
  # Power Management
  # ---------------------------------------------------------------------------
  #
  # Prevent system-level automatic suspend.
  #
  # User-level GNOME idle and power behavior will also be configured later
  # through Home Manager / dconf.
  #

  systemd.sleep.settings.Sleep = {
    AllowSuspend = false;
    AllowHibernation = false;
    AllowHybridSleep = false;
    AllowSuspendThenHibernate = false;
  };

  # ---------------------------------------------------------------------------
  # GNOME Settings Managed Elsewhere
  # ---------------------------------------------------------------------------
  #
  # Personal GNOME behavior belongs in:
  #
  #   home/sinless777/gnome.nix
  #
  # Planned user settings:
  #
  #   - dark theme
  #   - bottom dock
  #   - dock autohide
  #   - workspaces on all monitors
  #   - dynamic workspaces
  #   - hot corner disabled
  #   - animations enabled
  #   - night light disabled
  #   - remember NumLock
  #   - no idle suspend
  #   - show weekday
  #   - show date
  #   - show battery percentage
  #   - stock UI scaling
  #
}
