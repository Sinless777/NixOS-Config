{ pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # Filesystem support
  # ---------------------------------------------------------------------------

  boot.supportedFilesystems = [
    "ext4"
    "xfs"
    "btrfs"
    "vfat"
    "ntfs"
    "exfat"
  ];

  # ---------------------------------------------------------------------------
  # Filesystem utilities
  # ---------------------------------------------------------------------------

  environment.systemPackages = with pkgs; [
    # ext2/3/4
    e2fsprogs

    # XFS
    xfsprogs

    # Btrfs
    btrfs-progs

    # FAT / EFI partitions
    dosfstools

    # exFAT
    exfatprogs

    # NTFS
    ntfs3g

    # General disk / filesystem tools
    util-linux
    parted
    gptfdisk

    # SMART diagnostics
    smartmontools

    # NVMe management
    nvme-cli
  ];

  # ---------------------------------------------------------------------------
  # Automatic TRIM
  # ---------------------------------------------------------------------------
  #
  # Enables periodic TRIM for SSDs/NVMe devices.
  #
  # This is preferred over forcing the `discard` mount option on every
  # filesystem.
  #

  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  # ---------------------------------------------------------------------------
  # Mount-point creation
  # ---------------------------------------------------------------------------
  #
  # These directories are used by the workstation storage layout.
  #
  # The actual devices mounted here are defined per host.
  #

  systemd.tmpfiles.rules = [
    "d /mnt/data 0755 root root -"
    "d /mnt/projects 0755 root root -"
    "d /mnt/aerealith 0755 root root -"
  ];

  # ---------------------------------------------------------------------------
  # Notes
  # ---------------------------------------------------------------------------
  #
  # Actual filesystems belong in:
  #
  #   hosts/desktop/disks.nix
  #
  # Example:
  #
  # fileSystems."/mnt/aerealith" = {
  #   device = "/dev/disk/by-uuid/<uuid>";
  #   fsType = "ext4";
  #
  #   options = [
  #     "defaults"
  #     "noatime"
  #     "nofail"
  #   ];
  # };
  #
  # We intentionally do not hardcode /dev/sdX or /dev/nvmeXnY paths here.
}
