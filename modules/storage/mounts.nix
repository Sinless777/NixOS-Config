{ ... }:

{
  # ---------------------------------------------------------------------------
  # Shared mount points
  # ---------------------------------------------------------------------------
  #
  # This module defines common mount-point behavior only.
  #
  # Physical disks and filesystem UUIDs belong in:
  #
  #   hosts/<hostname>/disks.nix
  #

  systemd.tmpfiles.rules = [
    "d /mnt/data 0755 root root -"
    "d /mnt/projects 0755 root root -"
    "d /mnt/aerealith 0755 root root -"
  ];

  # ---------------------------------------------------------------------------
  # systemd automount defaults
  # ---------------------------------------------------------------------------
  #
  # Individual host filesystems can use:
  #
  #   x-systemd.automount
  #   nofail
  #   noatime
  #
  # This allows secondary storage to mount on demand without preventing the
  # machine from booting if a non-critical disk is temporarily unavailable.
  #

  # ---------------------------------------------------------------------------
  # Expected workstation layout
  # ---------------------------------------------------------------------------
  #
  # /mnt/data
  #   General bulk storage.
  #
  # /mnt/projects
  #   Development/project storage.
  #
  # /mnt/aerealith
  #   Dedicated fast NVMe storage for Aerealith.
  #
}
