{ pkgs, username, ... }:

{
  # ---------------------------------------------------------------------------
  # USBGuard
  # ---------------------------------------------------------------------------

  services.usbguard = {
    enable = true;

    # -------------------------------------------------------------------------
    # Default policy
    # -------------------------------------------------------------------------
    #
    # Any USB device that does not match an allow rule is blocked.
    #

    implicitPolicyTarget = "block";

    # -------------------------------------------------------------------------
    # Devices already connected when USBGuard starts
    # -------------------------------------------------------------------------
    #
    # Keep their current authorization state initially so we do not
    # accidentally disable the keyboard/mouse during the first deployment.
    #
    # Once we generate a proper allowlist, change this to:
    #
    #   "apply-policy"
    #

    presentDevicePolicy = "keep";

    # Keep USB controllers themselves active.
    presentControllerPolicy = "keep";

    # -------------------------------------------------------------------------
    # Newly inserted devices
    # -------------------------------------------------------------------------
    #
    # Apply the policy to anything plugged in after boot.
    #

    insertedDevicePolicy = "apply-policy";

    # -------------------------------------------------------------------------
    # Controller state
    # -------------------------------------------------------------------------

    restoreControllerDeviceState = true;

    # -------------------------------------------------------------------------
    # Management access
    # -------------------------------------------------------------------------
    #
    # Only root and the primary workstation user may communicate with
    # USBGuard over its IPC interface.
    #

    IPCAllowedUsers = [
      "root"
      username
    ];

    IPCAllowedGroups = [ ];

    # -------------------------------------------------------------------------
    # Device rules
    # -------------------------------------------------------------------------
    #
    # For the first deployment, leave rules unset so the persistent
    # /var/lib/usbguard/rules.conf can be generated from the actual hardware.
    #
    # After that, we can move the generated rules into this Nix module to make
    # the allowlist immutable and version-controlled.
    #

    rules = null;

    ruleFile = "/var/lib/usbguard/rules.conf";

    # Do not bind rules to physical USB port numbers.
    #
    # This lets an approved keyboard/mouse work if moved to another USB port.
    deviceRulesWithPort = false;
  };

  # ---------------------------------------------------------------------------
  # USBGuard CLI
  # ---------------------------------------------------------------------------

  environment.systemPackages = with pkgs; [
    usbguard
  ];
}
