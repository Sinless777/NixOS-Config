{ pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # AI / ML workstation profile
  # ---------------------------------------------------------------------------

  environment.systemPackages = with pkgs; [
    # -------------------------------------------------------------------------
    # Local inference
    # -------------------------------------------------------------------------

    ollama

    # llama.cpp tooling for GGUF models / local inference.
    llama-cpp

    # -------------------------------------------------------------------------
    # Python scientific / ML stack
    # -------------------------------------------------------------------------

    python3Packages.numpy
    python3Packages.scipy
    python3Packages.pandas
    python3Packages.scikit-learn

    # PyTorch
    python3Packages.torch
    python3Packages.torchvision

    # Jupyter
    python3Packages.jupyter
    python3Packages.ipykernel

    # -------------------------------------------------------------------------
    # Image / data tooling
    # -------------------------------------------------------------------------

    python3Packages.pillow
    python3Packages.matplotlib

    # -------------------------------------------------------------------------
    # Model / dataset utilities
    # -------------------------------------------------------------------------

    git-lfs

    # -------------------------------------------------------------------------
    # NVIDIA diagnostics
    # -------------------------------------------------------------------------

    nvtopPackages.nvidia

    # -------------------------------------------------------------------------
    # Native build requirements
    # -------------------------------------------------------------------------

    cmake
    ninja
    gcc
    pkg-config
  ];

  # ---------------------------------------------------------------------------
  # Ollama
  # ---------------------------------------------------------------------------
  #
  # Run Ollama as a system service so local models are immediately available
  # after boot.
  #

  services.ollama = {
    enable = true;

    # Use the same CUDA 12 toolkit as the workstation development environment.
    package = pkgs.ollama-cuda.override { cudaPackages = pkgs.cudaPackages_12; };

    # Keep Ollama available locally rather than exposing it to the LAN.
    host = "127.0.0.1";
    port = 11434;
  };

  # ---------------------------------------------------------------------------
  # Environment
  # ---------------------------------------------------------------------------

  environment.sessionVariables = {
    # NVIDIA CUDA visibility.
    CUDA_VISIBLE_DEVICES = "0";

    # Hugging Face/model cache location.
    #
    # Keeping model data outside $HOME makes it easier to move to dedicated
    # storage later.
    HF_HOME = "/mnt/aerealith/models/huggingface";

    TRANSFORMERS_CACHE = "/mnt/aerealith/models/huggingface/transformers";

    # Torch model cache.
    TORCH_HOME = "/mnt/aerealith/models/torch";

    # General AI model storage.
    AI_MODELS = "/mnt/aerealith/models";
  };

  # ---------------------------------------------------------------------------
  # Model storage
  # ---------------------------------------------------------------------------

  systemd.tmpfiles.rules = [
    "d /mnt/aerealith/models 0755 sinless777 users -"
    "d /mnt/aerealith/models/huggingface 0755 sinless777 users -"
    "d /mnt/aerealith/models/huggingface/transformers 0755 sinless777 users -"
    "d /mnt/aerealith/models/torch 0755 sinless777 users -"
    "d /mnt/aerealith/models/ollama 0755 sinless777 users -"
  ];

  # ---------------------------------------------------------------------------
  # Notes
  # ---------------------------------------------------------------------------
  #
  # CUDA itself is configured globally in:
  #
  #   modules/desktop/nvidia.nix
  #
  # That module provides:
  #
  #   nvcc
  #   CUDA runtime
  #   CUDA headers
  #   cuBLAS
  #   cuFFT
  #   cuRAND
  #   cuSOLVER
  #   cuSPARSE
  #   CUPTI
  #   NVRTC
  #   NVTX
  #   cuDNN
  #   NCCL
  #   cuda-gdb
  #   Nsight Compute
  #   Nsight Systems
  #
  # Heavy or project-specific ML environments should still preferably use
  # project flakes / nix develop when exact framework versions matter.
}
