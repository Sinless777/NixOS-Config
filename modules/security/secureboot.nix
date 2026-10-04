{ lib, pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # Secure Boot
  # ---------------------------------------------------------------------------
  #
  # Lanzaboote replaces the normal systemd-boot installation process and
  # signs boot artifacts using keys managed by sbctl.
  #

  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.loader.efi.canTouchEfiVariables = true;

  # ---------------------------------------------------------------------------
  # Lanzaboote
  # ---------------------------------------------------------------------------

  boot.lanzaboote = {
    enable = true;

    # Secure Boot keys generated and managed by sbctl.
    pkiBundle = "/var/lib/sbctl";

    # Keep a reasonable number of signed boot generations.
    configurationLimit = 10;
  };

  # ---------------------------------------------------------------------------
  # Secure Boot tooling
  # ---------------------------------------------------------------------------

  environment.systemPackages = with pkgs; [
    sbctl
  ];

  # ---------------------------------------------------------------------------
  # Firmware updates
  # ---------------------------------------------------------------------------
  #
  # Lanzaboote integrates with fwupd when both are enabled and prepares a
  # signed EFI binary for firmware-update operations.
  #

  services.fwupd.enable = true;

  # ---------------------------------------------------------------------------
  # Protect signing material
  # ---------------------------------------------------------------------------

  systemd.tmpfiles.rules = [
    "d /var/lib/sbctl 0700 root root -"
  ];

  # ---------------------------------------------------------------------------
  # Notes
  # ---------------------------------------------------------------------------
  #
  # Initial key creation:
  #
  #   sudo sbctl create-keys
  #
  # Verify signing:
  #
  #   sudo sbctl verify
  #
  # Check Secure Boot state:
  #
  #   bootctl status
  #
  # DO NOT commit anything from:
  #
  #   /var/lib/sbctl
  #
  # especially the private Secure Boot keys.
}
