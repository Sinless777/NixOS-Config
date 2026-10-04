{ pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # Node.js / JavaScript / TypeScript
  # ---------------------------------------------------------------------------

  environment.systemPackages = with pkgs; [
    # Current Node.js line from nixpkgs.
    nodejs

    # Package managers / tooling.
    pnpm
    yarn

    # Useful JS/TS tooling.
    typescript
    typescript-language-server

    # Common build / package helpers.
    npm-check-updates

    # Native addon build support.
    python3
    pkg-config
    gcc
    gnumake
  ];

  # ---------------------------------------------------------------------------
  # Corepack
  # ---------------------------------------------------------------------------
  #
  # Modern Node releases include Corepack support for package-manager
  # shims. pnpm/yarn are installed directly above as well, so the machine
  # remains predictable even if Corepack behavior changes.
  #

  # ---------------------------------------------------------------------------
  # Environment
  # ---------------------------------------------------------------------------

  environment.sessionVariables = {
    # Keep global npm installs out of /usr/local-style system paths.
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";

    # Prefer local/user package binaries when they are intentionally installed.
    PATH = [
      "$HOME/.npm-global/bin"
    ];
  };

  # ---------------------------------------------------------------------------
  # Notes
  # ---------------------------------------------------------------------------
  #
  # Prefer project-specific versions via a flake/devShell for projects that
  # require an exact Node version.
  #
  # Example:
  #
  #   nix develop
  #
  # That is especially useful for Aerealith so its Node and pnpm versions are
  # pinned independently from the workstation.
}
