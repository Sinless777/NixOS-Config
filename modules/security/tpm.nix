{ pkgs, username, ... }:

{
  # ---------------------------------------------------------------------------
  # TPM 2.0
  # ---------------------------------------------------------------------------

  security.tpm2 = {
    enable = true;

    # Expose TPM2 through PKCS#11.
    pkcs11.enable = true;

    # Export TPM2TOOLS_TCTI / TPM2_PKCS11_TCTI so userspace tools know which
    # TPM device/resource manager to use.
    tctiEnvironment.enable = true;

    # Prefer the kernel resource manager (/dev/tpmrm0) rather than requiring
    # the userspace access broker unless we discover a compatibility need.
    abrmd.enable = false;
  };

  # ---------------------------------------------------------------------------
  # User access
  # ---------------------------------------------------------------------------

  users.users.${username}.extraGroups = [
    "tss"
  ];

  # ---------------------------------------------------------------------------
  # TPM tooling
  # ---------------------------------------------------------------------------

  environment.systemPackages = with pkgs; [
    tpm2-tools
    tpm2-tss
    tpm2-pkcs11

    # Useful for Secure Boot / TPM inspection.
    sbctl
  ];

  # ---------------------------------------------------------------------------
  # TPM environment
  # ---------------------------------------------------------------------------

  environment.sessionVariables = {
    TSS2_TCTI = "device:/dev/tpmrm0";

    TPM2_PKCS11_BACKEND = "esysdb";
    TPM2_PKCS11_STORE = "$HOME/.local/share/tpm2-pkcs11";
  };

  # ---------------------------------------------------------------------------
  # Notes
  # ---------------------------------------------------------------------------
  #
  # After reboot, verify TPM access with:
  #
  #   ls -l /dev/tpm*
  #
  #   tpm2_getcap properties-fixed
  #
  #   tpm2_getcap properties-variable
  #
  # Your user should have read/write access to:
  #
  #   /dev/tpmrm0
  #
  # through membership in the `tss` group.
  #
  # Possible future uses:
  #
  #   - TPM-backed SSH signing keys
  #   - PKCS#11-backed Git signing
  #   - measured boot
  #   - sealing secrets to PCR values
  #   - binding encryption keys to the machine
  #
}
