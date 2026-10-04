{ pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # Git
  # ---------------------------------------------------------------------------

  programs.git = {
    enable = true;

    settings.user.name = "Timothy Pierce";
    settings.user.email = "tpierce@sinlessindustries.com";

    # -------------------------------------------------------------------------
    # Git LFS
    # -------------------------------------------------------------------------

    lfs.enable = true;

    # -------------------------------------------------------------------------
    # Git configuration
    # -------------------------------------------------------------------------

    settings = {
      # -----------------------------------------------------------------------
      # Repository defaults
      # -----------------------------------------------------------------------

      init.defaultBranch = "master";

      pull.rebase = true;
      rebase.autoStash = true;

      fetch.prune = true;
      fetch.pruneTags = true;

      push.autoSetupRemote = true;
      push.default = "current";

      # -----------------------------------------------------------------------
      # Commit / tag signing
      # -----------------------------------------------------------------------

      commit.gpgSign = true;
      tag.gpgSign = true;

      # Use SSH keys rather than GPG keys for Git commit signing.
      gpg.format = "ssh";

      # Public half of the SSH key used for signing.
      user.signingKey = "~/.ssh/id_ed25519.pub";

      # Used when verifying SSH-signed commits locally.
      gpg.ssh.allowedSignersFile = "~/.config/git/allowed_signers";

      # -----------------------------------------------------------------------
      # Delta
      # -----------------------------------------------------------------------

      # The enabled Delta module configures the pager and interactive filter.

      # -----------------------------------------------------------------------
      # Diff / merge behavior
      # -----------------------------------------------------------------------

      diff.algorithm = "histogram";

      merge.conflictStyle = "zdiff3";

      # Remember conflict resolutions.
      rerere.enabled = true;
      rerere.autoupdate = true;

      # -----------------------------------------------------------------------
      # Miscellaneous
      # -----------------------------------------------------------------------

      core.autocrlf = "input";

      branch.sort = "-committerdate";
      tag.sort = "-version:refname";

      help.autocorrect = "prompt";

      column.ui = "auto";

      # Avoid accidental commits without an explicitly configured identity.
      user.useConfigOnly = true;
    };
  };

  # ---------------------------------------------------------------------------
  # GitHub CLI
  # ---------------------------------------------------------------------------

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = true;
      line-numbers = true;
    };
  };

  programs.gh = {
    enable = true;

    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };

  # ---------------------------------------------------------------------------
  # SSH signing verification
  # ---------------------------------------------------------------------------
  #
  # Replace REPLACE_WITH_PUBLIC_KEY with the contents of:
  #
  #   ~/.ssh/id_ed25519.pub
  #
  # Example:
  #
  #   ssh-ed25519 AAAAC3... tpierce@sinlessindustries.com
  #

  home.file.".config/git/allowed_signers" = {
    text = ''
      tpierce@sinlessindustries.com ssh-ed25519 REPLACE_WITH_PUBLIC_KEY
    '';

    # This contains public keys and is linked from the read-only Nix store.
  };

  # ---------------------------------------------------------------------------
  # Git-related packages
  # ---------------------------------------------------------------------------

  home.packages = with pkgs; [
    git-lfs
    gh
    delta
    openssh
    gnupg
  ];
}
