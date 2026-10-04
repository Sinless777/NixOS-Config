{
  config,
  pkgs,
  username,
  ...
}:

{
  # ---------------------------------------------------------------------------
  # Home Manager user configuration
  # ---------------------------------------------------------------------------

  imports = [
    ./aliases.nix
    ./codex.nix
    ./fonts.nix
    ./git.nix
    ./gnome.nix
    ./packages.nix
    ./shell.nix
    ./vscode.nix
    ./zsh.nix
  ];

  # ---------------------------------------------------------------------------
  # User identity
  # ---------------------------------------------------------------------------

  home.username = username;

  home.homeDirectory = "/home/${username}";

  # ---------------------------------------------------------------------------
  # Home Manager state version
  # ---------------------------------------------------------------------------
  #
  # Keep this pinned to the Home Manager/NixOS generation this config was
  # originally created against.
  #
  # Do not automatically bump this just because nixpkgs is updated.
  #

  home.stateVersion = "26.05";

  # ---------------------------------------------------------------------------
  # Let Home Manager manage itself
  # ---------------------------------------------------------------------------

  programs.home-manager.enable = true;

  # ---------------------------------------------------------------------------
  # XDG
  # ---------------------------------------------------------------------------

  xdg.enable = true;

  xdg.userDirs = {
    enable = true;
    createDirectories = true;

    desktop = "${config.home.homeDirectory}/Desktop";
    documents = "${config.home.homeDirectory}/Documents";
    download = "${config.home.homeDirectory}/Downloads";
    music = "${config.home.homeDirectory}/Music";
    pictures = "${config.home.homeDirectory}/Pictures";
    publicShare = "${config.home.homeDirectory}/Public";
    templates = "${config.home.homeDirectory}/Templates";
    videos = "${config.home.homeDirectory}/Videos";
  };

  # ---------------------------------------------------------------------------
  # Session
  # ---------------------------------------------------------------------------

  home.sessionVariables = {
    XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
    XDG_CACHE_HOME = "${config.home.homeDirectory}/.cache";
    XDG_DATA_HOME = "${config.home.homeDirectory}/.local/share";
    XDG_STATE_HOME = "${config.home.homeDirectory}/.local/state";
  };

  # ---------------------------------------------------------------------------
  # Common user directories
  # ---------------------------------------------------------------------------

  home.activation.createUserDirectories = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p \
      "$HOME/Desktop" \
      "$HOME/Documents" \
      "$HOME/Downloads" \
      "$HOME/Music" \
      "$HOME/Pictures" \
      "$HOME/Public" \
      "$HOME/Templates" \
      "$HOME/Videos" \
      "$HOME/Projects" \
      "$HOME/bin" \
      "$HOME/.local/bin" \
      "$HOME/.local/state" \
      "$HOME/.config"
  '';

  # ---------------------------------------------------------------------------
  # Notes
  # ---------------------------------------------------------------------------
  #
  # User-level responsibilities:
  #
  #   aliases.nix
  #     shell aliases and helper functions
  #
  #   codex.nix
  #     OpenAI Codex CLI configuration
  #
  #   fonts.nix
  #     user font preferences
  #
  #   git.nix
  #     Git identity, signing, GitHub CLI
  #
  #   gnome.nix
  #     GNOME preferences and dconf
  #
  #   packages.nix
  #     user applications and utilities
  #
  #   shell.nix
  #     Zsh, Oh My Zsh, Starship, fzf, zoxide, direnv
  #
  #   vscode.nix
  #     VS Code and editor configuration
  #
  #   zsh.nix
  #     environment, completions, keybindings, SSH agent
}
