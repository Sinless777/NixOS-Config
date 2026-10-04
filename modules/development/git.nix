{ pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # Git tooling
  # ---------------------------------------------------------------------------

  environment.systemPackages = with pkgs; [
    git
    git-lfs
    gh

    # Signing / crypto support.
    openssh
    gnupg

    # Useful Git-adjacent tools.
    delta
  ];

  # ---------------------------------------------------------------------------
  # Git LFS
  # ---------------------------------------------------------------------------

  programs.git = {
    enable = true;
    lfs.enable = true;
  };
}
