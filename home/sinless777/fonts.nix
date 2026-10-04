{ pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # User font packages
  # ---------------------------------------------------------------------------
  #
  # Most fonts are already installed system-wide through:
  #
  #   modules/desktop/fonts.nix
  #
  # Keeping the Nerd Fonts here as well ensures this Home Manager profile
  # remains usable independently.
  #

  home.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];

  # ---------------------------------------------------------------------------
  # Fontconfig
  # ---------------------------------------------------------------------------

  fonts.fontconfig = {
    enable = true;

    defaultFonts = {
      monospace = [
        "FiraCode Nerd Font"
        "JetBrainsMono Nerd Font"
        "Noto Sans Mono"
      ];

      sansSerif = [
        "Noto Sans"
        "Liberation Sans"
      ];

      serif = [
        "Noto Serif"
        "Liberation Serif"
      ];

      emoji = [
        "Noto Color Emoji"
      ];
    };
  };

  # ---------------------------------------------------------------------------
  # GTK font preference
  # ---------------------------------------------------------------------------

  gtk = {
    enable = true;

    font = {
      name = "Noto Sans";
      size = 11;
    };
  };

  # ---------------------------------------------------------------------------
  # User environment hints
  # ---------------------------------------------------------------------------

  home.sessionVariables = {
    DEFAULT_FONT = "FiraCode Nerd Font";
    TERMINAL_FONT = "FiraCode Nerd Font";
    CODE_FONT = "FiraCode Nerd Font";
  };

  # ---------------------------------------------------------------------------
  # Notes
  # ---------------------------------------------------------------------------
  #
  # Primary UI font:
  #
  #   Noto Sans
  #
  # Primary terminal/code font:
  #
  #   FiraCode Nerd Font
  #
  # Fallback programming font:
  #
  #   JetBrainsMono Nerd Font
  #
  # Emoji:
  #
  #   Noto Color Emoji
  #
  # Starship uses Nerd Font glyphs, so FiraCode Nerd Font is the preferred
  # terminal font for this configuration.
}
