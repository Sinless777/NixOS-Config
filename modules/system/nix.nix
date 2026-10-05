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

    # Each concurrent build gets its own core budget; these limits multiply.
    # Leave resources available for the desktop during large C++/CUDA builds.
    max-jobs = 1;
    cores = 4;

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
    (final: prev: {
      ceph = prev.ceph.overrideAttrs (old: {
        # GCC 16 no longer provides uint64_t through unrelated STL headers.
        postPatch = (old.postPatch or "") + ''
          substituteInPlace src/common/Formatter.h \
            --replace-fail '#include <map>' $'#include <map>\n#include <cstdint>'
          # Argument-dependent lookup also finds crimson::make_message.
          # All classic MDS sources need the ceph intrusive-pointer factory.
          # Preserve calls that already specify a namespace.
          find src/mds -type f \( -name '*.cc' -o -name '*.h' \) \
            -exec sed -i -E \
              's/(^|[^[:alnum:]_:])make_message</\1ceph::make_message</g' {} +
          # rgw_rest.cc in rgw_common calls a Swift handler defined in rgw_a.
          # Declare the reverse edge so CMake repeats the mutually dependent
          # static archives instead of leaving that handler unresolved.
          substituteInPlace src/rgw/CMakeLists.txt \
            --replace-fail 'set(rgw_libs rgw_a)' \
              $'target_link_libraries(rgw_common PRIVATE rgw_a)\nset(rgw_libs rgw_a)'
        '';
      });
      # Keep ONNX Runtime's CUDA backend without the optional multi-gigabyte
      # TensorRT distribution downloaded from NVIDIA.
      onnxruntime = prev.onnxruntime.override { tensorrtSupport = false; };
      suitesparse = prev.suitesparse.overrideAttrs (old: {
        # CUDA libraries have separate Nix outputs, outside nvcc's toolkit root.
        cmakeFlags = (old.cmakeFlags or [ ]) ++ [
          (lib.cmakeFeature "CUDA_nvrtc_LIBRARY" "${lib.getLib final.cudaPackages.cuda_nvrtc}/lib/libnvrtc.so")
        ];
      });
      cudaPackages_12 = prev.cudaPackages_12.overrideScope (
        _cudaFinal: cudaPrev: {
          libnvshmem = cudaPrev.libnvshmem.overrideAttrs (old: {
            # NVRTC headers also live outside nvcc's toolkit include directory.
            buildInputs = (old.buildInputs or [ ]) ++ [
              (lib.getOutput "include" cudaPrev.cuda_nvrtc)
            ];
            # FindCUDAToolkit cannot discover NVRTC in its separate Nix output.
            # NVSHMEM's test helpers link the CUDA::nvrtc imported target.
            cmakeFlags = (old.cmakeFlags or [ ]) ++ [
              (lib.cmakeFeature "CUDA_nvrtc_LIBRARY" "${lib.getLib cudaPrev.cuda_nvrtc}/lib/libnvrtc.so")
            ];
          });
          # Consumers such as ONNX Runtime need this header-only library, not
          # the bundled GPU example/test binaries with broken NVRTC discovery.
          cudnn-frontend = cudaPrev.cudnn-frontend.override {
            withSamples = false;
            withTests = false;
          };
        }
      );
      lazarus-qt6 = prev.lazarus-qt6.overrideAttrs (old: {
        # Removing rpath flags leaves extra spaces, rejected by makeWrapper.
        postInstall =
          builtins.replaceStrings
            [ "sed -re 's/-rpath [^ ]+//g'" ]
            [ "sed -re 's/-rpath [^ ]+//g; s/^ +//; s/ +$//; s/ +/ /g'" ]
            old.postInstall;
      });
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
