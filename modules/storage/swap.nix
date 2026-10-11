# =====================================================================
# SinLess Industries — Swap Management
# =====================================================================
#
# Workstation defaults:
#   - Prefer compressed zram swap
#   - Preserve existing /dev/sdf3 disk swap defined in disks.nix
#   - Never create swap on Ceph OSD disks
#
# The disk swap option is disabled by default to prevent defining
# the same swap partition twice.
#
# =====================================================================

{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    optional
    optionals
    types
    ;

  cfg = config.sinless.storage.swap;

  # Existing desktop swap partition (sdf3). Do not use /dev/sdf3:
  # Linux drive letters may change between boots.
  defaultSwapDevice = "/dev/disk/by-partuuid/f796b385-e682-4add-abf7-5d392141ab46";
in
{
  options.sinless.storage.swap = {
    enable = mkEnableOption "workstation swap management";

    zram = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable compressed zram swap.";
      };

      algorithm = mkOption {
        type = types.enum [
          "zstd"
          "lz4"
          "lzo"
          "lzo-rle"
        ];
        default = "zstd";
        description = "Compression algorithm for zram swap.";
      };

      memoryPercent = mkOption {
        type = types.ints.between 1 100;
        default = 10;
        description = "Logical zram capacity as a percentage of RAM.";
      };

      priority = mkOption {
        type = types.int;
        default = 100;
        description = "Swap priority for zram (higher is preferred).";
      };
    };

    disk = {
      enable = mkEnableOption "disk swap declaration in this module";

      device = mkOption {
        type = types.str;
        default = defaultSwapDevice;
        description = ''
          Existing desktop disk-swap partition, identified by PARTUUID.
          Do not enable here when disks.nix already defines it.
        '';
      };

      priority = mkOption {
        type = types.int;
        default = 10;
        description = "Swap priority of the optional disk swap.";
      };

      discard = mkOption {
        type = types.nullOr (
          types.enum [
            "once"
            "pages"
            "both"
          ]
        );
        default = null;
        description = "Optional discard policy; null disables discard.";
      };
    };

    memory = {
      configure = mkOption {
        type = types.bool;
        default = true;
        description = "Enable swap-related kernel VM tuning.";
      };

      swappiness = mkOption {
        type = types.ints.between 0 200;
        default = 100;
        description = "Kernel vm.swappiness value.";
      };

      pageCluster = mkOption {
        type = types.ints.between 0 31;
        default = 0;
        description = "Kernel vm.page-cluster read-ahead exponent.";
      };

      vfsCachePressure = mkOption {
        # Nixpkgs does NOT provide lib.types.positive.
        type = types.ints.between 1 10000;
        default = 100;
        description = "Kernel vm.vfs_cache_pressure (must be positive).";
      };
    };

    diagnostics.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Install utilities for inspecting memory and swap.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.zram.enable || !cfg.disk.enable || cfg.zram.priority > cfg.disk.priority;
        message = "sinless.storage.swap.zram.priority must exceed disk.priority.";
      }
      {
        assertion = !cfg.disk.enable || cfg.disk.device == defaultSwapDevice;
        message = ''
          This desktop module permits disk swap only on the existing
          sdf3 partition (identified by PARTUUID). Leave disk.enable=false
          when hosts/desktop/disks.nix owns disk swap.
        '';
      }
    ];

    zramSwap = {
      enable = cfg.zram.enable;
      algorithm = cfg.zram.algorithm;
      memoryPercent = cfg.zram.memoryPercent;
      priority = cfg.zram.priority;
    };

    # Leave this disabled in the desktop host configuration:
    # hosts/desktop/disks.nix already declares sdf3 with priority 10.
    swapDevices = optional cfg.disk.enable (
      {
        device = cfg.disk.device;
        priority = cfg.disk.priority;
        randomEncryption.enable = false;
      }
      // lib.optionalAttrs (cfg.disk.discard != null) {
        discardPolicy = cfg.disk.discard;
      }
    );

    boot.kernel.sysctl = mkIf cfg.memory.configure {
      "vm.swappiness" = cfg.memory.swappiness;
      "vm.page-cluster" = cfg.memory.pageCluster;
      "vm.vfs_cache_pressure" = cfg.memory.vfsCachePressure;
    };

    environment.systemPackages = optionals cfg.diagnostics.enable (
      with pkgs;
      [
        util-linux
        procps
        sysstat
        htop
        btop
      ]
    );
  };
}
