{
  config,
  lib,
  pkgs,
  inputs,
  username,
  ...
}:

{
  # ---------------------------------------------------------------------------
  # Nix command / flakes
  # ---------------------------------------------------------------------------
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Allow the primary workstation user to perform trusted Nix operations.
    trusted-users = [
      "root"
      username
    ];

    # Reuse identical files in the Nix store where possible.
    auto-optimise-store = true;

    # Avoid downloading substitutes we cannot verify.
    require-sigs = true;

    # Keep failed builds around only when explicitly debugging them.
    keep-failed = false;

    # Avoid keeping build dependencies unnecessarily.
    keep-derivations = false;
    keep-outputs = false;

    # Helps reduce unnecessary disk use during builds.
    min-free = 5 * 1024 * 1024 * 1024;
    max-free = 20 * 1024 * 1024 * 1024;

    # Reasonable parallelism for the Threadripper system.
    max-jobs = "auto";
    cores = 0;

    # More readable command output.
    warn-dirty = true;
  };

  # ---------------------------------------------------------------------------
  # Automatic store optimization
  # ---------------------------------------------------------------------------
  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };

  # ---------------------------------------------------------------------------
  # Garbage collection
  # ---------------------------------------------------------------------------
  nix.gc = {
    automatic = true;

    # Run weekly.
    dates = "weekly";

    # Keep recent generations available for rollback.
    options = "--delete-older-than 30d";

    # Avoid running GC while the system is under heavy load.
    randomizedDelaySec = "45min";
  };

  # ---------------------------------------------------------------------------
  # Package configuration
  # ---------------------------------------------------------------------------
  nixpkgs.config = {
    # Required for packages such as NVIDIA drivers, Discord, etc.
    allowUnfree = true;

    # We can add explicitly permitted insecure packages here later if one is
    # ever required temporarily.
    permittedInsecurePackages = [ ];
  };

  nixpkgs.overlays = [
    (_final: prev: {
      ltrace = prev.ltrace.overrideAttrs (old: {
        # GCC warns about volatile return types; ltrace's DejaGNU harness
        # treats compiler output as failure and never creates the test binary.
        # Keep the test suite enabled and fix only the obsolete declaration.
        postPatch = (old.postPatch or "") + ''
          substituteInPlace testsuite/ltrace.minor/demangle-lib.cpp \
            --replace-fail 'volatile int Fv_Vi(void)' 'int Fv_Vi(void)'
        '';
      });
    })
  ];

  # ---------------------------------------------------------------------------
  # Nix registry
  # ---------------------------------------------------------------------------
  # Makes `nixpkgs` resolve to the same nixpkgs input used by the system flake.
  nix.registry.nixpkgs.flake = inputs.nixpkgs;

  # ---------------------------------------------------------------------------
  # Nix path compatibility
  # ---------------------------------------------------------------------------
  # Some older tooling still expects NIX_PATH.
  nix.settings.nix-path = [
    "nixpkgs=${pkgs.path}"
  ];

  # ---------------------------------------------------------------------------
  # Environment
  # ---------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    nix-output-monitor
    nix-tree
  ];
}
