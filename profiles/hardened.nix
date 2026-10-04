{ ... }:

{
  imports = [
    # -------------------------------------------------------------------------
    # Core hardening
    # -------------------------------------------------------------------------

    ../modules/security/kernel.nix
    ../modules/security/hardening.nix

    # -------------------------------------------------------------------------
    # Mandatory access control
    # -------------------------------------------------------------------------

    ../modules/security/apparmor.nix

    # -------------------------------------------------------------------------
    # Audit / accountability
    # -------------------------------------------------------------------------

    ../modules/security/audit.nix

    # -------------------------------------------------------------------------
    # Authentication / authorization
    # -------------------------------------------------------------------------

    ../modules/security/pam.nix
    ../modules/security/polkit.nix
    ../modules/security/sudo.nix

    # -------------------------------------------------------------------------
    # Brute-force / network-facing protection
    # -------------------------------------------------------------------------

    ../modules/security/fail2ban.nix

    # -------------------------------------------------------------------------
    # Physical-device security
    # -------------------------------------------------------------------------

    ../modules/security/usbguard.nix

    # -------------------------------------------------------------------------
    # Secrets
    # -------------------------------------------------------------------------

    ../modules/security/sops.nix

    # -------------------------------------------------------------------------
    # TPM
    # -------------------------------------------------------------------------

    ../modules/security/tpm.nix

    # -------------------------------------------------------------------------
    # Secure Boot
    # -------------------------------------------------------------------------
    #
    # Keep disabled until Lanzaboote is verified on the machine.
    #
    # ../modules/security/secureboot.nix
  ];

  # ---------------------------------------------------------------------------
  # Hardened profile notes
  # ---------------------------------------------------------------------------
  #
  # This profile is intended for trusted workstations and servers where
  # stronger security defaults are desired.
  #
  # It deliberately does NOT import:
  #
  #   - desktop configuration
  #   - NVIDIA
  #   - Docker
  #   - development tooling
  #   - virtualization
  #
  # Those capabilities should be composed separately by the host.
}
