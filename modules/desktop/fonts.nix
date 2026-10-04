{ pkgs, ... }:

{
  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      # Coding / terminal fonts
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono

      # General desktop fonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji

      liberation_ttf

      # Common compatibility fonts
      corefonts
      vista-fonts
    ];

    fontconfig = {
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
  };
}
