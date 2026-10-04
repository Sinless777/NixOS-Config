{ pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # Gaming profile
  # ---------------------------------------------------------------------------

  # ---------------------------------------------------------------------------
  # Steam
  # ---------------------------------------------------------------------------

  programs.steam = {
    enable = true;

    # Open firewall ports required by Steam Remote Play / local networking.
    remotePlay.openFirewall = true;

    # Useful for LAN game transfers.
    localNetworkGameTransfers.openFirewall = true;
  };

  # ---------------------------------------------------------------------------
  # GameMode
  # ---------------------------------------------------------------------------

  programs.gamemode = {
    enable = true;
  };

  # ---------------------------------------------------------------------------
  # Gamescope
  # ---------------------------------------------------------------------------

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  # ---------------------------------------------------------------------------
  # 32-bit graphics support
  # ---------------------------------------------------------------------------
  #
  # Already enabled in the NVIDIA module, but keeping this profile compatible
  # with non-NVIDIA hosts is useful.
  #

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # ---------------------------------------------------------------------------
  # Gaming packages
  # ---------------------------------------------------------------------------

  environment.systemPackages = with pkgs; [
    # -------------------------------------------------------------------------
    # Compatibility / launchers
    # -------------------------------------------------------------------------

    wineWow64Packages.stable
    winetricks

    lutris
    heroic

    # -------------------------------------------------------------------------
    # Proton tooling
    # -------------------------------------------------------------------------

    protonup-qt

    # -------------------------------------------------------------------------
    # Performance / overlays
    # -------------------------------------------------------------------------

    mangohud
    goverlay

    # -------------------------------------------------------------------------
    # Gamescope
    # -------------------------------------------------------------------------

    gamescope

    # -------------------------------------------------------------------------
    # Controllers / input
    # -------------------------------------------------------------------------

    SDL2

    # -------------------------------------------------------------------------
    # GPU / performance diagnostics
    # -------------------------------------------------------------------------

    nvtopPackages.nvidia

    # -------------------------------------------------------------------------
    # Useful gaming tools
    # -------------------------------------------------------------------------

    vulkan-tools
    mesa-demos
  ];

  # ---------------------------------------------------------------------------
  # GameMode defaults
  # ---------------------------------------------------------------------------

  programs.gamemode.settings = {
    general = {
      renice = 10;
      inhibit_screensaver = 1;
    };
  };

  # ---------------------------------------------------------------------------
  # Environment
  # ---------------------------------------------------------------------------

  environment.sessionVariables = {
    # Enable MangoHud globally only when explicitly requested by an app.
    MANGOHUD = "0";

    # Prefer Wayland-aware SDL applications where possible.
    SDL_VIDEODRIVER = "wayland,x11";
  };

  # ---------------------------------------------------------------------------
  # Notes
  # ---------------------------------------------------------------------------
  #
  # NVIDIA driver support is provided by:
  #
  #   modules/desktop/nvidia.nix
  #
  # Audio is provided by:
  #
  #   modules/desktop/audio.nix
  #
  # This profile intentionally focuses on:
  #
  #   Steam
  #   Proton
  #   Wine
  #   Lutris
  #   Heroic
  #   GameMode
  #   MangoHud
  #   Gamescope
  #   Vulkan tools
  #
}
