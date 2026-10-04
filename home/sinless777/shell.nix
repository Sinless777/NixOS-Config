{ pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # Zsh
  # ---------------------------------------------------------------------------

  programs.zsh = {
    enable = true;

    # Let Home Manager initialize completion.
    enableCompletion = true;

    # -------------------------------------------------------------------------
    # Oh My Zsh
    # -------------------------------------------------------------------------

    oh-my-zsh = {
      enable = true;

      # IMPORTANT:
      #
      # Leave the OMZ theme empty because Starship owns the prompt.
      theme = "";

      plugins = [
        "aliases"
        "ansible"
        "aws"
        "azure"
        "brew"
        "docker"
        "docker-compose"
        "git"
        "gh"
        "helm"
        "kubectl"
        "sudo"
        "systemd"
        "terraform"
        "vscode"
        "ssh"
        "zoxide"
      ];

      extraConfig = ''
        # Keep Oh My Zsh from trying to own the prompt.
        ZSH_THEME=""

        # Reduce update noise.
        zstyle ':omz:update' mode disabled
      '';
    };

    # -------------------------------------------------------------------------
    # Autosuggestions
    # -------------------------------------------------------------------------

    autosuggestion = {
      enable = true;
    };

    # -------------------------------------------------------------------------
    # Syntax highlighting
    # -------------------------------------------------------------------------

    syntaxHighlighting = {
      enable = true;
    };

    # -------------------------------------------------------------------------
    # History
    # -------------------------------------------------------------------------

    history = {
      size = 20000;
      save = 20000;

      path = "$HOME/.local/state/zsh/history";

      extended = true;
      ignoreAllDups = true;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };

    # -------------------------------------------------------------------------
    # Zsh options
    # -------------------------------------------------------------------------

    setOptions = [
      "AUTO_CD"
      "AUTO_PUSHD"
      "PUSHD_IGNORE_DUPS"
      "PUSHD_SILENT"

      "INTERACTIVE_COMMENTS"
      "MAGIC_EQUAL_SUBST"
      "NO_BEEP"
      "NO_NOMATCH"
      "NOTIFY"
      "NUMERIC_GLOB_SORT"
      "PROMPT_SUBST"

      "EXTENDED_GLOB"
      "NULL_GLOB"

      "APPEND_HISTORY"
      "EXTENDED_HISTORY"
      "HIST_EXPIRE_DUPS_FIRST"
      "HIST_FIND_NO_DUPS"
      "HIST_IGNORE_ALL_DUPS"
      "HIST_IGNORE_SPACE"
      "HIST_REDUCE_BLANKS"
      "HIST_SAVE_NO_DUPS"
      "HIST_VERIFY"
      "INC_APPEND_HISTORY"
      "SHARE_HISTORY"
    ];

    # -------------------------------------------------------------------------
    # Shell init
    # -------------------------------------------------------------------------

    initContent = ''
      # -----------------------------------------------------------------------
      # Basic Zsh behavior
      # -----------------------------------------------------------------------

      WORDCHARS=''${WORDCHARS//\/}
      PROMPT_EOL_MARK=""

      # -----------------------------------------------------------------------
      # Keybindings
      # -----------------------------------------------------------------------

      bindkey -e

      bindkey ' '        magic-space
      bindkey '^U'       backward-kill-line
      bindkey '^K'       kill-line
      bindkey '^A'       beginning-of-line
      bindkey '^E'       end-of-line

      bindkey '^[[3~'    delete-char
      bindkey '^[[3;5~'  kill-word
      bindkey '^[[1;5C'  forward-word
      bindkey '^[[1;5D'  backward-word
      bindkey '^[[5~'    beginning-of-buffer-or-history
      bindkey '^[[6~'    end-of-buffer-or-history
      bindkey '^[[H'     beginning-of-line
      bindkey '^[[F'     end-of-line

      # -----------------------------------------------------------------------
      # Directory setup
      # -----------------------------------------------------------------------

      mkdir -p "$HOME/.local/state/zsh" 2>/dev/null || true

      # -----------------------------------------------------------------------
      # Kubernetes completions
      # -----------------------------------------------------------------------

      if command -v kubectl >/dev/null 2>&1; then
        source <(kubectl completion zsh) 2>/dev/null || true
      fi

      if command -v helm >/dev/null 2>&1; then
        source <(helm completion zsh) 2>/dev/null || true
      fi

      if command -v talosctl >/dev/null 2>&1; then
        source <(talosctl completion zsh) 2>/dev/null || true
      fi

      if command -v flux >/dev/null 2>&1; then
        source <(flux completion zsh) 2>/dev/null || true
      fi

      # -----------------------------------------------------------------------
      # Terraform / OpenTofu completion
      # -----------------------------------------------------------------------

      if command -v terraform >/dev/null 2>&1; then
        complete -o nospace -C terraform terraform 2>/dev/null || true
      fi

      if command -v tofu >/dev/null 2>&1; then
        complete -o nospace -C tofu tofu 2>/dev/null || true
      fi
    '';
  };

  # ---------------------------------------------------------------------------
  # Starship
  # ---------------------------------------------------------------------------
  #
  # Starship is the prompt.
  #
  # Oh My Zsh still handles:
  #
  #   plugins
  #   aliases
  #   completions
  #   helpers
  #
  # but does NOT render a theme/prompt.
  #

  programs.starship = {
    enable = true;

    enableZshIntegration = true;

    # Nerd Font symbols work with your FiraCode Nerd Font setup.
    presets = [
      "nerd-font-symbols"
    ];

    settings = {
      add_newline = true;

      # -----------------------------------------------------------------------
      # Prompt format
      # -----------------------------------------------------------------------

      format = ''
        $username\
        $hostname\
        $directory\
        $git_branch\
        $git_status\
        $git_state\
        $git_metrics\
        $package\
        $nodejs\
        $python\
        $golang\
        $rust\
        $dotnet\
        $c\
        $cmake\
        $docker_context\
        $kubernetes\
        $terraform\
        $aws\
        $azure\
        $gcloud\
        $nix_shell\
        $cmd_duration\
        $line_break\
        $character
      '';

      # -----------------------------------------------------------------------
      # User / host
      # -----------------------------------------------------------------------

      username = {
        show_always = true;
        format = "[$user]($style)";
      };

      hostname = {
        ssh_only = false;
        format = "[@$hostname]($style) ";
      };

      # -----------------------------------------------------------------------
      # Directory
      # -----------------------------------------------------------------------

      directory = {
        truncation_length = 5;
        truncate_to_repo = false;
        read_only = " 󰌾";
      };

      # -----------------------------------------------------------------------
      # Git
      # -----------------------------------------------------------------------

      git_branch = {
        symbol = " ";
        format = "[$symbol$branch]($style) ";
      };

      git_status = {
        format = "([$all_status$ahead_behind]($style) )";
      };

      git_metrics = {
        disabled = false;
      };

      # -----------------------------------------------------------------------
      # Language / runtime modules
      # -----------------------------------------------------------------------

      nodejs = {
        symbol = " ";
      };

      python = {
        symbol = " ";
      };

      golang = {
        symbol = " ";
      };

      rust = {
        symbol = " ";
      };

      dotnet = {
        symbol = " ";
      };

      c = {
        symbol = " ";
      };

      # -----------------------------------------------------------------------
      # Containers / infrastructure
      # -----------------------------------------------------------------------

      docker_context = {
        symbol = " ";
      };

      kubernetes = {
        disabled = false;
        symbol = "󱃾 ";
        format = "[$symbol$context( \\($namespace\\))]($style) ";
      };

      terraform = {
        symbol = "󱁢 ";
      };

      # -----------------------------------------------------------------------
      # Nix
      # -----------------------------------------------------------------------

      nix_shell = {
        symbol = " ";
        format = "[$symbol$state]($style) ";
      };

      # -----------------------------------------------------------------------
      # Command duration
      # -----------------------------------------------------------------------

      cmd_duration = {
        min_time = 2000;
        format = "[$duration]($style) ";
      };

      # -----------------------------------------------------------------------
      # Prompt character
      # -----------------------------------------------------------------------

      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
    };
  };

  # ---------------------------------------------------------------------------
  # direnv
  # ---------------------------------------------------------------------------

  programs.direnv = {
    enable = true;

    nix-direnv.enable = true;

    enableZshIntegration = true;
  };

  # ---------------------------------------------------------------------------
  # fzf
  # ---------------------------------------------------------------------------

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # ---------------------------------------------------------------------------
  # zoxide
  # ---------------------------------------------------------------------------

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # ---------------------------------------------------------------------------
  # Shell packages
  # ---------------------------------------------------------------------------

  home.packages = with pkgs; [
    starship
    zsh
    fzf
    zoxide

    bat
    eza
    ripgrep
    fd
  ];
}
