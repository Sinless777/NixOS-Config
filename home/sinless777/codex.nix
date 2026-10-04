{ pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # OpenAI Codex CLI
  # ---------------------------------------------------------------------------

  home.packages = with pkgs; [
    codex
  ];

  # ---------------------------------------------------------------------------
  # Codex environment
  # ---------------------------------------------------------------------------

  home.sessionVariables = {
    CODEX_HOME = "$HOME/.codex";
  };

  # ---------------------------------------------------------------------------
  # Codex configuration
  # ---------------------------------------------------------------------------
  #
  # Codex reads:
  #
  #   $CODEX_HOME/config.toml
  #
  # which defaults to:
  #
  #   ~/.codex/config.toml
  #

  home.file.".codex/config.toml".text = ''
    # =====================================================================
    # OpenAI Codex CLI
    # =====================================================================

    # ---------------------------------------------------------------------
    # Model
    # ---------------------------------------------------------------------
    #
    # Leave this unset if you want Codex to follow the application's
    # current default model selection.
    #
    # Example:
    #
    # model = "gpt-5.1"

    # ---------------------------------------------------------------------
    # Provider
    # ---------------------------------------------------------------------

    model_provider = "openai"

    # ---------------------------------------------------------------------
    # Shell environment
    # ---------------------------------------------------------------------
    #
    # Keep the normal development environment available to commands run by
    # Codex.
    #

    [shell_environment_policy]

    include_only = [
      "HOME",
      "USER",
      "LOGNAME",
      "PATH",

      "SHELL",

      "LANG",
      "LC_CTYPE",

      "TERM",
      "COLORTERM",

      "EDITOR",
      "VISUAL",

      "XDG_CONFIG_HOME",
      "XDG_CACHE_HOME",
      "XDG_DATA_HOME",
      "XDG_STATE_HOME",

      "SSH_AUTH_SOCK",

      "GIT_AUTHOR_NAME",
      "GIT_AUTHOR_EMAIL",
      "GIT_COMMITTER_NAME",
      "GIT_COMMITTER_EMAIL",

      "GOPATH",

      "CARGO_HOME",
      "RUSTUP_HOME",

      "NPM_CONFIG_PREFIX",

      "PYTHONUSERBASE",
      "VIRTUAL_ENV",

      "KUBECONFIG",

      "DOCKER_HOST",

      "VAULT_ADDR",
      "VAULT_CACERT",

      "CUDA_HOME",
      "CUDA_PATH",
      "CUDA_VISIBLE_DEVICES",

      "NIX_PATH"
    ]

    # ---------------------------------------------------------------------
    # Environment filtering
    # ---------------------------------------------------------------------
    #
    # Do not explicitly expose secrets here.
    #
    # In particular, keep tokens/API keys out of the declarative config:
    #
    #   OPENAI_API_KEY
    #   GITHUB_TOKEN
    #   GH_TOKEN
    #   VAULT_TOKEN
    #   AWS_SECRET_ACCESS_KEY
    #   CLOUDFLARE_API_TOKEN
    #
    # Authentication should be handled separately from this repository.
  '';

  # ---------------------------------------------------------------------------
  # Codex directory
  # ---------------------------------------------------------------------------

  home.activation.createCodexDirectories = builtins.trace "Creating Codex configuration directory" (''
    mkdir -p "$HOME/.codex"
    chmod 700 "$HOME/.codex"
  '');

  # ---------------------------------------------------------------------------
  # Useful Codex aliases
  # ---------------------------------------------------------------------------
  #
  # These can also be moved into aliases.nix if you want every alias in one
  # place.
  #

  programs.zsh.shellAliases = {
    cx = "codex";
    cxe = "codex exec";
    cxv = "codex --version";
  };
}
