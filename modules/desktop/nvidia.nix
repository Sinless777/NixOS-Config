{
  config,
  lib,
  pkgs,
  ...
}:

let
  cuda = pkgs.cudaPackages_12;
  cudaSamples = cuda.cuda-samples.overrideAttrs (old: {
    # Install the basic GPU validation tools rather than the full demo suite.
    buildPhase = ''
      runHook preBuild
      cmake --build . --parallel "$NIX_BUILD_CORES" \
        --target deviceQuery bandwidthTest vectorAdd
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      install -Dm755 Samples/1_Utilities/deviceQuery/deviceQuery "$out/bin/deviceQuery"
      install -Dm755 Samples/1_Utilities/bandwidthTest/bandwidthTest "$out/bin/bandwidthTest"
      install -Dm755 Samples/0_Introduction/vectorAdd/vectorAdd "$out/bin/vectorAdd"
      runHook postInstall
    '';
    # FindCUDAToolkit assumes a single toolkit directory, while Nix splits
    # these libraries into separate outputs.
    cmakeFlags = (old.cmakeFlags or [ ]) ++ [
      (lib.cmakeFeature "CUDA_nvrtc_LIBRARY" "${lib.getLib cuda.cuda_nvrtc}/lib/libnvrtc.so")
      (lib.cmakeFeature "CUDA_curand_LIBRARY" "${lib.getLib cuda.libcurand}/lib/libcurand.so")
    ];
  });
  nsightSystems = cuda.nsight_systems.overrideAttrs (old: {
    # This release ships an empty libqtiff.so placeholder. Qt image plugins
    # are supplied by the package's Qt dependencies; only patch real ELF files.
    preFixup = ''
      if isELF "''${!outputBin}/host-linux-x64/Plugins/imageformats/libqtiff.so"; then
        ${old.preFixup or ""}
      fi
    '';
  });
in
{
  # ---------------------------------------------------------------------------
  # NVIDIA driver
  # ---------------------------------------------------------------------------

  services.xserver.videoDrivers = [
    "nvidia"
  ];

  hardware.nvidia = {
    # RTX 3060 / Ampere supports NVIDIA's open kernel module.
    open = true;

    # NVIDIA settings GUI.
    nvidiaSettings = true;

    # Modesetting is required for modern GNOME/Wayland integration.
    modesetting.enable = true;

    # Useful on a workstation that may run CUDA jobs and graphical workloads.
    powerManagement.enable = true;

    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # ---------------------------------------------------------------------------
  # Graphics stack
  # ---------------------------------------------------------------------------

  hardware.graphics = {
    enable = true;

    # Useful for Wine/Steam and other 32-bit graphical applications.
    enable32Bit = true;
  };

  # ---------------------------------------------------------------------------
  # CUDA support in nixpkgs
  # ---------------------------------------------------------------------------

  nixpkgs.config = {
    cudaSupport = true;

    # RTX 3060 / Ampere compute capability.
    cudaCapabilities = [
      "8.6"
    ];

    cudaForwardCompat = true;
  };

  # ---------------------------------------------------------------------------
  # NVIDIA persistence
  # ---------------------------------------------------------------------------
  #
  # Keeps the NVIDIA driver initialized between workloads.
  #

  hardware.nvidia.nvidiaPersistenced = true;

  # ---------------------------------------------------------------------------
  # Kernel modules
  # ---------------------------------------------------------------------------

  boot.kernelModules = [
    "nvidia"
    "nvidia_modeset"
    "nvidia_drm"
  ];

  # ---------------------------------------------------------------------------
  # CUDA environment
  # ---------------------------------------------------------------------------

  environment.variables = {
    CUDA_HOME = "${cuda.cuda_nvcc}";
    CUDA_PATH = "${cuda.cuda_nvcc}";

    # Useful for build systems such as CMake.
    CUDA_ROOT = "${cuda.cuda_nvcc}";

    # Default architecture for this RTX 3060.
    CUDAARCHS = "86";
  };

  # ---------------------------------------------------------------------------
  # CUDA / NVIDIA packages
  # ---------------------------------------------------------------------------

  environment.systemPackages = with pkgs; [
    # -------------------------------------------------------------------------
    # Driver / management utilities
    # -------------------------------------------------------------------------

    config.hardware.nvidia.package

    # -------------------------------------------------------------------------
    # CUDA compiler and development tooling
    # -------------------------------------------------------------------------

    cuda.cuda_nvcc
    cuda.cccl

    # CUDA runtime
    cuda.cuda_cudart

    # CUDA headers / development components
    cuda.cuda_nvcc

    # -------------------------------------------------------------------------
    # CUDA math libraries
    # -------------------------------------------------------------------------

    # Basic Linear Algebra Subprograms
    cuda.libcublas

    # Fast Fourier Transform
    cuda.libcufft

    # Random Number Generation
    cuda.libcurand

    # Dense / sparse solver library
    cuda.libcusolver

    # Sparse matrix library
    cuda.libcusparse

    # -------------------------------------------------------------------------
    # CUDA runtime compilation
    # -------------------------------------------------------------------------

    cuda.cuda_nvrtc

    # -------------------------------------------------------------------------
    # Profiling / tracing
    # -------------------------------------------------------------------------

    # CUDA Profiling Tools Interface
    cuda.cuda_cupti

    # NVIDIA Tools Extension
    cuda.cuda_nvtx

    # -------------------------------------------------------------------------
    # Deep learning
    # -------------------------------------------------------------------------

    cuda.cudnn
    cuda.nccl

    # -------------------------------------------------------------------------
    # Debugging
    # -------------------------------------------------------------------------

    cuda.cuda_gdb

    # -------------------------------------------------------------------------
    # Profilers
    # -------------------------------------------------------------------------

    cuda.nsight_compute
    nsightSystems

    # -------------------------------------------------------------------------
    # CUDA binary / inspection tools
    # -------------------------------------------------------------------------

    cuda.cuda_cuobjdump
    cuda.cuda_nvdisasm

    # -------------------------------------------------------------------------
    # CUDA demos / validation
    # -------------------------------------------------------------------------

    cudaSamples

    # -------------------------------------------------------------------------
    # Build / native development requirements
    # -------------------------------------------------------------------------

    gcc
    gnumake
    cmake
    ninja
    pkg-config

    # -------------------------------------------------------------------------
    # OpenGL / graphics interoperability
    # -------------------------------------------------------------------------

    libglvnd
    libGL
    libGLU

    # -------------------------------------------------------------------------
    # GPU diagnostics
    # -------------------------------------------------------------------------

    pciutils
  ];

  # ---------------------------------------------------------------------------
  # CUDA library search path
  # ---------------------------------------------------------------------------

  environment.sessionVariables = {
    LD_LIBRARY_PATH = [
      (lib.makeLibraryPath [
        cuda.cuda_cudart
        cuda.libcublas
        cuda.libcufft
        cuda.libcurand
        cuda.libcusolver
        cuda.libcusparse
        cuda.cuda_nvrtc
        cuda.cuda_cupti
        cuda.cudnn
        cuda.nccl
        config.hardware.nvidia.package
      ])
    ];
  };
}
