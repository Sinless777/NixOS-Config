{
  config,
  lib,
  pkgs,
  username,
  ...
}:

{
  users.users.${username} = {
    isNormalUser = true;

    description = "Primary workstation user";

    shell = pkgs.zsh;

    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
      "libvirtd"
      "video"
      "audio"
      "input"
    ];

    # Home Manager will manage most user-level configuration.
    createHome = true;
    home = "/home/${username}";
  };

  # Enable Zsh system-wide so it can be used as the user's login shell.
  programs.zsh.enable = true;

  # Passwordless sudo for the primary workstation user.
  security.sudo = {
    enable = true;

    extraRules = [
      {
        users = [ username ];

        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };

  # Allow wheel users to use sudo.
  security.sudo.wheelNeedsPassword = false;
}
