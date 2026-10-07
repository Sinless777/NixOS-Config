{ pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # Python development
  # ---------------------------------------------------------------------------

  environment.systemPackages = with pkgs; [
    # Python interpreter
    python3
    # Projects such as Aerealith pin Python 3.12.
    # Exclude the separate doc derivation: its Sphinx build is broken in
    # the pinned nixpkgs, and system documentation would pull it in.
    (builtins.removeAttrs python312 [ "doc" ])

    # Modern Python package / environment tooling
    uv
    pipx

    # Virtual environment support
    python3Packages.virtualenv

    # Common developer tooling
    python3Packages.pip
    python3Packages.setuptools
    python3Packages.wheel

    # Testing / linting / formatting
    python3Packages.pytest
    python3Packages.black
    python3Packages.ruff
    python3Packages.mypy

    # Language server
    python3Packages.python-lsp-server

    # Useful build dependencies for native Python packages
    gcc
    pkg-config
    openssl
    libffi
    zlib
  ];

  # ---------------------------------------------------------------------------
  # Environment
  # ---------------------------------------------------------------------------

  environment.sessionVariables = {
    # uv-managed generic Linux interpreters cannot run directly on NixOS.
    UV_PYTHON_PREFERENCE = "only-system";
    UV_PYTHON_DOWNLOADS = "never";

    # Keep Python user installs in the user's home directory.
    PYTHONUSERBASE = "$HOME/.local";

    # Prefer predictable UTF-8 behavior.
    PYTHONUTF8 = "1";

    # Avoid writing .pyc files everywhere.
    PYTHONDONTWRITEBYTECODE = "1";

    # Make tracebacks immediately visible.
    PYTHONUNBUFFERED = "1";

    # pip quality-of-life
    PIP_DISABLE_PIP_VERSION_CHECK = "1";
  };

  # ---------------------------------------------------------------------------
  # Notes
  # ---------------------------------------------------------------------------
  #
  # Heavy AI/ML libraries such as:
  #
  #   PyTorch
  #   TensorFlow
  #   JAX
  #   Transformers
  #   Diffusers
  #   CUDA Python libraries
  #   Jupyter
  #
  # should preferably live in a dedicated Nix dev shell/profile rather than
  # being installed into the base system.
  #
  # This keeps rebuilds faster and avoids dependency conflicts between
  # unrelated Python projects.
}
