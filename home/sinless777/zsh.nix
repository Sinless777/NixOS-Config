{
  config,
  pkgs,
  username,
  ...
}:

{
  programs.zsh = {
    enable = true;

    # -------------------------------------------------------------------------
    # .zshenv
    # -------------------------------------------------------------------------
    #
    # Sourced by:
    #
    #   - login shells
    #   - interactive shells
    #   - non-interactive shells
    #   - scripts using Zsh
    #
    # Keep this lightweight.
    #

    envExtra = ''
      # -----------------------------------------------------------------------
      # User / Home
      # -----------------------------------------------------------------------

      export HOME="''${HOME:-/home/${username}}"
      export USER="''${USER:-${username}}"
      export LOGNAME="''${LOGNAME:-$USER}"

      # -----------------------------------------------------------------------
      # Locale
      # -----------------------------------------------------------------------

      export LANG="''${LANG:-en_US.UTF-8}"
      export LC_CTYPE="''${LC_CTYPE:-en_US.UTF-8}"

      # -----------------------------------------------------------------------
      # XDG Base Directories
      # -----------------------------------------------------------------------

      export XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"
      export XDG_CACHE_HOME="''${XDG_CACHE_HOME:-$HOME/.cache}"
      export XDG_DATA_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}"
      export XDG_STATE_HOME="''${XDG_STATE_HOME:-$HOME/.local/state}"

      for _zshenv_dir in \
        "$XDG_CONFIG_HOME" \
        "$XDG_CACHE_HOME" \
        "$XDG_DATA_HOME" \
        "$XDG_STATE_HOME" \
        "$HOME/bin" \
        "$HOME/.local/bin"
      do
        if [[ \
          -n "$_zshenv_dir" \
          && ! -d "$_zshenv_dir" \
          && -w "''${_zshenv_dir:h}" \
        ]]; then
          command mkdir -p "$_zshenv_dir" 2>/dev/null || true
        fi
      done

      unset _zshenv_dir

      # -----------------------------------------------------------------------
      # Editor / Pager
      # -----------------------------------------------------------------------

      export EDITOR="''${EDITOR:-nvim}"
      export VISUAL="''${VISUAL:-$EDITOR}"

      export PAGER="''${PAGER:-less}"
      export LESS="''${LESS:--RFM}"

      # -----------------------------------------------------------------------
      # CLI preferences
      # -----------------------------------------------------------------------

      export DOTNET_CLI_TELEMETRY_OPTOUT="''${DOTNET_CLI_TELEMETRY_OPTOUT:-1}"
      export HOMEBREW_NO_ENV_HINTS="''${HOMEBREW_NO_ENV_HINTS:-1}"
      export DIRENV_LOG_FORMAT="''${DIRENV_LOG_FORMAT:-}"

      # -----------------------------------------------------------------------
      # GPG
      # -----------------------------------------------------------------------

      if command tty -s 2>/dev/null; then
        export GPG_TTY="$(command tty)"
      fi

      # -----------------------------------------------------------------------
      # Vault
      # -----------------------------------------------------------------------

      export VAULT_ADDR="''${VAULT_ADDR:-https://10.10.10.180:8200}"
      export VAULT_SKIP_VERIFY="''${VAULT_SKIP_VERIFY:-false}"

      if [[ \
        -z "''${VAULT_CACERT:-}" \
        && -f "$HOME/.config/vault/ca.crt" \
      ]]; then
        export VAULT_CACERT="$HOME/.config/vault/ca.crt"
      fi

      # -----------------------------------------------------------------------
      # Development directories
      # -----------------------------------------------------------------------

      export GOPATH="''${GOPATH:-$HOME/go}"

      export CARGO_HOME="''${CARGO_HOME:-$HOME/.cargo}"
      export RUSTUP_HOME="''${RUSTUP_HOME:-$HOME/.rustup}"

      export NPM_CONFIG_PREFIX="''${NPM_CONFIG_PREFIX:-$HOME/.npm-global}"

      export PYTHONUSERBASE="''${PYTHONUSERBASE:-$HOME/.local}"

      # Avoid globally forcing PIP_USER=1.
      #
      # Doing that can interfere with:
      #
      #   virtualenv
      #   uv
      #   nix develop
      #
      # Use explicit user installs only when needed.

      # -----------------------------------------------------------------------
      # Development directories
      # -----------------------------------------------------------------------

      for _zshenv_dir in \
        "$GOPATH" \
        "$GOPATH/bin" \
        "$CARGO_HOME" \
        "$CARGO_HOME/bin" \
        "$NPM_CONFIG_PREFIX" \
        "$NPM_CONFIG_PREFIX/bin"
      do
        if [[ \
          -n "$_zshenv_dir" \
          && ! -d "$_zshenv_dir" \
          && -w "''${_zshenv_dir:h}" \
        ]]; then
          command mkdir -p "$_zshenv_dir" 2>/dev/null || true
        fi
      done

      unset _zshenv_dir

      # -----------------------------------------------------------------------
      # PATH
      # -----------------------------------------------------------------------
      #
      # Nix itself owns the system PATH.
      #
      # We only prepend user-controlled development locations.
      #

      typeset -gU path PATH

      path=(
        "$HOME/bin"
        "$HOME/.local/bin"
        "$NPM_CONFIG_PREFIX/bin"
        "$CARGO_HOME/bin"
        "$GOPATH/bin"

        $path
      )

      export PATH

      # -----------------------------------------------------------------------
      # Font hint
      # -----------------------------------------------------------------------

      export DEFAULT_FONT="''${DEFAULT_FONT:-FiraCode Nerd Font}"

      # -----------------------------------------------------------------------
      # Colors
      # -----------------------------------------------------------------------

      export CLICOLOR="''${CLICOLOR:-1}"
      export LS_COLORS="''${LS_COLORS:-}"
    '';

    # -------------------------------------------------------------------------
    # Interactive .zshrc additions
    # -------------------------------------------------------------------------

    initContent = ''
      # -----------------------------------------------------------------------
      # Interactive shell guard
      # -----------------------------------------------------------------------

      case "$-" in
        *i*) ;;
        *) return 0 2>/dev/null || exit 0 ;;
      esac

      # -----------------------------------------------------------------------
      # Zsh helpers
      # -----------------------------------------------------------------------

      autoload -Uz add-zsh-hook
      autoload -Uz colors

      colors

      # -----------------------------------------------------------------------
      # General shell behavior
      # -----------------------------------------------------------------------

      WORDCHARS=''${WORDCHARS//\/}
      PROMPT_EOL_MARK=""

      # -----------------------------------------------------------------------
      # Keybindings
      # -----------------------------------------------------------------------

      bindkey -e

      bindkey ' '         magic-space

      bindkey '^U'        backward-kill-line
      bindkey '^K'        kill-line

      bindkey '^A'        beginning-of-line
      bindkey '^E'        end-of-line

      bindkey '^[[3~'     delete-char
      bindkey '^[[3;5~'   kill-word

      bindkey '^[[1;5C'   forward-word
      bindkey '^[[1;5D'   backward-word

      bindkey '^[[5~'     beginning-of-buffer-or-history
      bindkey '^[[6~'     end-of-buffer-or-history

      bindkey '^[[H'      beginning-of-line
      bindkey '^[[F'      end-of-line

      bindkey '^[[Z'      undo

      # -----------------------------------------------------------------------
      # PATH cleanup
      # -----------------------------------------------------------------------

      typeset -gU path PATH

      [[ -d "$HOME/.venv/bin" ]] && \
        path=("$HOME/.venv/bin" $path)

      export PATH

      # -----------------------------------------------------------------------
      # Completion appearance
      # -----------------------------------------------------------------------

      zstyle ':completion:*' menu select

      zstyle ':completion:*' \
        matcher-list \
        'm:{a-zA-Z}={A-Za-z}'

      zstyle ':completion:*' \
        list-colors \
        "''${(s.:.)LS_COLORS}"

      zstyle ':completion:*' group-name ""

      zstyle ':completion:*:descriptions' \
        format '%F{green}-- %d --%f'

      zstyle ':completion:*:warnings' \
        format '%F{yellow}No matches found%f'

      zstyle ':completion:*' verbose yes
      zstyle ':completion:*' rehash true

      zstyle ':completion:*' use-cache true

      zstyle ':completion:*' \
        cache-path \
        "''${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completion"

      mkdir -p \
        "''${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completion" \
        2>/dev/null || true

      # -----------------------------------------------------------------------
      # External tool completions
      # -----------------------------------------------------------------------
      #
      # Home Manager/Oh My Zsh handles the common completion framework.
      # These provide completions for tools that are not always covered.
      #

      if command -v talosctl >/dev/null 2>&1; then
        source <(talosctl completion zsh) 2>/dev/null || true
      fi

      if command -v flux >/dev/null 2>&1; then
        source <(flux completion zsh) 2>/dev/null || true
      fi

      if command -v cilium >/dev/null 2>&1; then
        source <(cilium completion zsh) 2>/dev/null || true
      fi

      if command -v istioctl >/dev/null 2>&1; then
        source <(istioctl completion zsh) 2>/dev/null || true
      fi

      if command -v argocd >/dev/null 2>&1; then
        source <(argocd completion zsh) 2>/dev/null || true
      fi

      # -----------------------------------------------------------------------
      # Terraform / OpenTofu completion
      # -----------------------------------------------------------------------

      if command -v terraform >/dev/null 2>&1; then
        complete \
          -o nospace \
          -C terraform \
          terraform \
          2>/dev/null || true
      fi

      if command -v tofu >/dev/null 2>&1; then
        complete \
          -o nospace \
          -C tofu \
          tofu \
          2>/dev/null || true
      fi

      # -----------------------------------------------------------------------
      # Alias file
      # -----------------------------------------------------------------------
      #
      # home/sinless777/aliases.nix generates:
      #
      #   ~/.zsh_aliases
      #

      if [[ -r "$HOME/.zsh_aliases" ]]; then
        source "$HOME/.zsh_aliases"
      fi

      # -----------------------------------------------------------------------
      # Python / direnv virtualenv synchronization
      # -----------------------------------------------------------------------

      typeset -g _ZSH_MANAGED_VENV=""

      _sync_direnv_virtualenv() {
        local desired_venv="''${VIRTUAL_ENV:-}"
        local desired_bin=""

        if [[ -n "$_ZSH_MANAGED_VENV" ]]; then
          path=(''${path:#"''${_ZSH_MANAGED_VENV}/bin"})
        fi

        if [[ \
          -n "$desired_venv" \
          && -d "$desired_venv/bin" \
        ]]; then
          desired_bin="''${desired_venv}/bin"

          path=(
            "$desired_bin"
            ''${path:#"$desired_bin"}
          )

          export VIRTUAL_ENV="$desired_venv"

          _ZSH_MANAGED_VENV="$desired_venv"
        else
          _ZSH_MANAGED_VENV=""
        fi

        export PATH
      }

      add-zsh-hook precmd _sync_direnv_virtualenv
      add-zsh-hook chpwd _sync_direnv_virtualenv

      _sync_direnv_virtualenv

      # -----------------------------------------------------------------------
      # SSH Agent
      # -----------------------------------------------------------------------

      export ZSH_AUTO_START_SSH_AGENT="''${ZSH_AUTO_START_SSH_AGENT:-1}"
      export ZSH_AUTO_ADD_SSH_KEYS="''${ZSH_AUTO_ADD_SSH_KEYS:-1}"

      _ssh_agent_env_file="''${XDG_STATE_HOME:-$HOME/.local/state}/ssh/agent.env"

      _ssh_agent_load() {
        [[ -f "$_ssh_agent_env_file" ]] || return 1

        source "$_ssh_agent_env_file" >/dev/null 2>&1

        [[ \
          -n "''${SSH_AUTH_SOCK:-}" \
          && -S "$SSH_AUTH_SOCK" \
        ]] || return 1

        if [[ -n "''${SSH_AGENT_PID:-}" ]]; then
          kill -0 "$SSH_AGENT_PID" 2>/dev/null || return 1
        fi

        return 0
      }

      _ssh_agent_start() {
        command -v ssh-agent >/dev/null 2>&1 || return 1

        mkdir -p \
          "''${_ssh_agent_env_file:h}" \
          2>/dev/null || return 1

        umask 077

        ssh-agent -s \
          | sed 's/^echo/#echo/' \
          >| "$_ssh_agent_env_file"

        source "$_ssh_agent_env_file" >/dev/null 2>&1
      }

      _ssh_agent_add_keys() {
        command -v ssh-add >/dev/null 2>&1 || return 0
        command -v ssh-keygen >/dev/null 2>&1 || return 0

        ssh-add -l >/dev/null 2>&1 && return 0

        local key

        for key in \
          "$HOME/.ssh"/id_* \
          "$HOME/.ssh"/*_id_*
        do
          [[ -f "$key" ]] || continue

          [[ "$key" == *.pub ]] && continue
          [[ "$key" == *-cert.pub ]] && continue
          [[ "$key" == *.pem ]] && continue
          [[ "$key" == *known_hosts* ]] && continue
          [[ "$key" == *authorized_keys* ]] && continue
          [[ "$key" == *config* ]] && continue

          if ssh-keygen -yf "$key" >/dev/null 2>&1; then
            ssh-add "$key" >/dev/null 2>&1 || true
          fi
        done
      }

      if [[ "$ZSH_AUTO_START_SSH_AGENT" == "1" ]]; then
        _ssh_agent_load || _ssh_agent_start

        if [[ "$ZSH_AUTO_ADD_SSH_KEYS" == "1" ]]; then
          _ssh_agent_add_keys
        fi
      fi

      unset _ssh_agent_env_file

      unfunction _ssh_agent_load 2>/dev/null || true
      unfunction _ssh_agent_start 2>/dev/null || true
      unfunction _ssh_agent_add_keys 2>/dev/null || true

      # -----------------------------------------------------------------------
      # Final PATH deduplication
      # -----------------------------------------------------------------------

      typeset -gU path PATH
      export PATH
    '';
  };

  # ---------------------------------------------------------------------------
  # Session environment
  # ---------------------------------------------------------------------------

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";

    PAGER = "less";
    LESS = "-RFM";

    DOTNET_CLI_TELEMETRY_OPTOUT = "1";

    VAULT_ADDR = "https://10.10.10.180:8200";
    VAULT_SKIP_VERIFY = "false";

    GOPATH = "${config.home.homeDirectory}/go";

    CARGO_HOME = "${config.home.homeDirectory}/.cargo";

    RUSTUP_HOME = "${config.home.homeDirectory}/.rustup";

    NPM_CONFIG_PREFIX = "${config.home.homeDirectory}/.npm-global";

    PYTHONUSERBASE = "${config.home.homeDirectory}/.local";

    DEFAULT_FONT = "FiraCode Nerd Font";

    CLICOLOR = "1";
  };

  # ---------------------------------------------------------------------------
  # User PATH
  # ---------------------------------------------------------------------------

  home.sessionPath = [
    "$HOME/bin"
    "$HOME/.local/bin"
    "$HOME/.npm-global/bin"
    "$HOME/.cargo/bin"
    "$HOME/go/bin"
  ];

  # ---------------------------------------------------------------------------
  # Required directories
  # ---------------------------------------------------------------------------

  home.activation.createShellDirectories = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p \
      "$HOME/bin" \
      "$HOME/.local/bin" \
      "$HOME/.local/state/zsh" \
      "$HOME/.local/state/ssh" \
      "$HOME/.npm-global" \
      "$HOME/.cargo" \
      "$HOME/.rustup" \
      "$HOME/go/bin"
  '';
}
