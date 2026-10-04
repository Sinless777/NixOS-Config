{ ... }:

{
  imports = [
    # -------------------------------------------------------------------------
    # Source control
    # -------------------------------------------------------------------------

    ../modules/development/git.nix

    # -------------------------------------------------------------------------
    # General development / DevOps tooling
    # -------------------------------------------------------------------------

    ../modules/development/tools.nix

    # -------------------------------------------------------------------------
    # Language runtimes / toolchains
    # -------------------------------------------------------------------------

    ../modules/development/node.nix
    ../modules/development/python.nix

    # -------------------------------------------------------------------------
    # Containers
    # -------------------------------------------------------------------------

    ../modules/development/docker.nix

    # -------------------------------------------------------------------------
    # Kubernetes / infrastructure administration
    # -------------------------------------------------------------------------

    ../modules/development/kubernetes.nix
  ];

  # ---------------------------------------------------------------------------
  # Notes
  # ---------------------------------------------------------------------------
  #
  # This profile intentionally does NOT import:
  #
  #   profiles/ai.nix
  #   profiles/gaming.nix
  #
  # or workstation-specific hardware configuration.
  #
  # That means this profile can later be reused by:
  #
  #   - desktop workstations
  #   - laptops
  #   - development VMs
  #   - build machines
  #
  # without automatically pulling in GNOME, NVIDIA, CUDA, or gaming packages.
}
