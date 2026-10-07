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

    # Nerd Font icons.
    presets = [
      "nerd-font-symbols"
    ];

    settings = {
      # -----------------------------------------------------------------------
      # General
      # -----------------------------------------------------------------------

      add_newline = true;

      scan_timeout = 30;
      command_timeout = 1000;

      # -----------------------------------------------------------------------
      # Prompt layout
      # -----------------------------------------------------------------------
      #
      # Line 1:
      #
      #   user@host  directory  git  package/languages  infra/cloud
      #
      # Line 2:
      #
      #   nix shell  jobs  duration  status
      #   ❯
      #
      # Modules automatically disappear when they are not relevant.
      #

      format =
        "$os$username$hostname$directory"
        + "$git_branch$git_commit$git_status$git_state$git_metrics"
        + "$fill"
        + "$package"
        + "$nodejs$python$golang$rust$dotnet$c$cmake"
        + "$docker_context$kubernetes$terraform"
        + "$aws$azure$gcloud"
        + "$nix_shell"
        + "$line_break"
        + "$jobs$status$cmd_duration"
        + "$character";

      # -----------------------------------------------------------------------
      # Right prompt
      # -----------------------------------------------------------------------
      #
      # Time is useful, but keeping it on the right avoids cluttering the
      # primary prompt.
      #

      right_format = "$memory_usage$time";

      # -----------------------------------------------------------------------
      # OS
      # -----------------------------------------------------------------------

      os = {
        disabled = false;

        format = "[$symbol]($style) ";

        style = "bold blue";

        symbols = {
          NixOS = "";
          Linux = "";
          Ubuntu = "";
          Debian = "";
          Fedora = "";
          Arch = "";
          Windows = "󰍲";
          Macos = "";
        };
      };

      # -----------------------------------------------------------------------
      # User
      # -----------------------------------------------------------------------

      username = {
        show_always = true;

        style_user = "bold green";
        style_root = "bold red";

        format = "[$user]($style)";
      };

      # -----------------------------------------------------------------------
      # Hostname
      # -----------------------------------------------------------------------

      hostname = {
        ssh_only = false;

        trim_at = ".";

        style = "bold cyan";

        format = "[@$hostname]($style) ";
      };

      # -----------------------------------------------------------------------
      # Directory
      # -----------------------------------------------------------------------

      directory = {
        truncation_length = 5;
        truncation_symbol = "…/";

        truncate_to_repo = false;

        read_only = " 󰌾";

        style = "bold blue";

        format = "[ $path]($style)[$read_only]($read_only_style) ";

        substitutions = {
          "Documents" = "󰈙";
          "Downloads" = "";
          "Music" = "";
          "Pictures" = "";
          "Projects" = "󰲋";
          "Infrastructure" = "󰒋";
          "Aerealith" = "󰚩";
        };
      };

      # -----------------------------------------------------------------------
      # Git branch
      # -----------------------------------------------------------------------

      git_branch = {
        symbol = " ";

        style = "bold purple";

        format = "[$symbol$branch(:$remote_branch)]($style) ";
      };

      # -----------------------------------------------------------------------
      # Git commit
      # -----------------------------------------------------------------------

      git_commit = {
        disabled = false;

        commit_hash_length = 7;

        only_detached = true;

        tag_disabled = false;

        tag_symbol = "  ";

        style = "bold yellow";

        format = "[$hash$tag]($style) ";
      };

      # -----------------------------------------------------------------------
      # Git status
      # -----------------------------------------------------------------------

      git_status = {
        style = "bold yellow";

        format = "([$all_status$ahead_behind]($style) )";

        conflicted = "󰞇$count ";
        ahead = "⇡$count ";
        behind = "⇣$count ";
        diverged = "⇕⇡$ahead_count⇣$behind_count ";

        up_to_date = "✓ ";

        untracked = "?$count ";
        stashed = "󰏗$count ";
        modified = "!$count ";
        staged = "+$count ";
        renamed = "»$count ";
        deleted = "✘$count ";
      };

      # -----------------------------------------------------------------------
      # Git operation
      # -----------------------------------------------------------------------

      git_state = {
        style = "bold red";

        format = "[$state( $progress_current/$progress_total)]($style) ";
      };

      # -----------------------------------------------------------------------
      # Git metrics
      # -----------------------------------------------------------------------

      git_metrics = {
        disabled = false;

        added_style = "bold green";
        deleted_style = "bold red";

        format = "([+$added]($added_style) )([-$deleted]($deleted_style) )";
      };

      # -----------------------------------------------------------------------
      # Fill
      # -----------------------------------------------------------------------

      fill = {
        symbol = " ";
      };

      # -----------------------------------------------------------------------
      # Package
      # -----------------------------------------------------------------------

      package = {
        symbol = "󰏗 ";

        style = "bold 208";

        format = "[$symbol$version]($style) ";
      };

      # -----------------------------------------------------------------------
      # Node.js
      # -----------------------------------------------------------------------

      nodejs = {
        symbol = " ";

        style = "bold green";

        format = "[$symbol$version]($style) ";
      };

      # -----------------------------------------------------------------------
      # Python
      # -----------------------------------------------------------------------

      python = {
        symbol = " ";

        style = "bold yellow";

        format = "[$symbol$version( \\($virtualenv\\))]($style) ";
      };

      # -----------------------------------------------------------------------
      # Go
      # -----------------------------------------------------------------------

      golang = {
        symbol = " ";

        style = "bold cyan";

        format = "[$symbol$version]($style) ";
      };

      # -----------------------------------------------------------------------
      # Rust
      # -----------------------------------------------------------------------

      rust = {
        symbol = " ";

        style = "bold 208";

        format = "[$symbol$version]($style) ";
      };

      # -----------------------------------------------------------------------
      # .NET
      # -----------------------------------------------------------------------

      dotnet = {
        symbol = "󰪮 ";

        style = "bold purple";

        format = "[$symbol$version]($style) ";
      };

      # -----------------------------------------------------------------------
      # C / C++
      # -----------------------------------------------------------------------

      c = {
        symbol = " ";

        style = "bold blue";

        format = "[$symbol$version]($style) ";
      };

      # -----------------------------------------------------------------------
      # CMake
      # -----------------------------------------------------------------------

      cmake = {
        symbol = " ";

        style = "bold blue";

        format = "[$symbol$version]($style) ";
      };

      # -----------------------------------------------------------------------
      # Docker
      # -----------------------------------------------------------------------

      docker_context = {
        symbol = " ";

        style = "bold blue";

        only_with_files = true;

        format = "[$symbol$context]($style) ";
      };

      # -----------------------------------------------------------------------
      # Kubernetes
      # -----------------------------------------------------------------------

      kubernetes = {
        disabled = false;

        symbol = "󱃾 ";

        style = "bold cyan";

        format = "[$symbol$context]($style)" + "[/$namespace](bold blue) ";
      };

      # -----------------------------------------------------------------------
      # Terraform
      # -----------------------------------------------------------------------

      terraform = {
        symbol = "󱁢 ";

        style = "bold purple";

        format = "[$symbol$workspace]($style) ";
      };

      # -----------------------------------------------------------------------
      # AWS
      # -----------------------------------------------------------------------

      aws = {
        symbol = "󰸏 ";

        style = "bold yellow";

        format = "[$symbol$profile]($style)" + "[$region](dimmed yellow) ";
      };

      # -----------------------------------------------------------------------
      # Azure
      # -----------------------------------------------------------------------

      azure = {
        symbol = "󰠅 ";

        style = "bold blue";

        format = "[$symbol$subscription]($style) ";
      };

      # -----------------------------------------------------------------------
      # Google Cloud
      # -----------------------------------------------------------------------

      gcloud = {
        symbol = "󱇶 ";

        style = "bold blue";

        format = "[$symbol$project]($style) ";
      };

      # -----------------------------------------------------------------------
      # Nix shell
      # -----------------------------------------------------------------------

      nix_shell = {
        symbol = " ";

        style = "bold blue";

        heuristic = true;

        format = "[$symbol$state( \\($name\\))]($style) ";
      };

      # -----------------------------------------------------------------------
      # Background jobs
      # -----------------------------------------------------------------------

      jobs = {
        symbol = "󰜎 ";

        number_threshold = 1;

        style = "bold blue";

        format = "[$symbol$number]($style) ";
      };

      # -----------------------------------------------------------------------
      # Previous command status
      # -----------------------------------------------------------------------

      status = {
        disabled = false;

        symbol = "✘ ";
        success_symbol = "";

        not_executable_symbol = "󰂭 ";
        not_found_symbol = "󰍉 ";
        sigint_symbol = "󰚌 ";
        signal_symbol = "󱐋 ";

        style = "bold red";

        format = "[$symbol$status]($style) ";
      };

      # -----------------------------------------------------------------------
      # Command duration
      # -----------------------------------------------------------------------

      cmd_duration = {
        min_time = 1500;

        show_milliseconds = false;

        style = "bold yellow";

        format = "[󱎫 $duration]($style) ";
      };

      # -----------------------------------------------------------------------
      # Memory
      # -----------------------------------------------------------------------
      #
      # Only show memory when the shell/process environment is using a
      # meaningful amount. Keeps the right prompt clean.
      #

      memory_usage = {
        disabled = false;

        threshold = 70;

        symbol = "󰍛 ";

        style = "dimmed white";

        format = "[$symbol$ram_pct]($style) ";
      };

      # -----------------------------------------------------------------------
      # Time
      # -----------------------------------------------------------------------

      time = {
        disabled = false;

        time_format = "%I:%M:%S %p";

        style = "dimmed white";

        format = "[ $time]($style)";
      };

      # -----------------------------------------------------------------------
      # Prompt character
      # -----------------------------------------------------------------------

      character = {
        success_symbol = "[╰─❯](bold green)";
        error_symbol = "[╰─❯](bold red)";
        vimcmd_symbol = "[╰─❮](bold yellow)";
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
