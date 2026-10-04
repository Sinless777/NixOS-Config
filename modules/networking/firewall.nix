{ lib, ... }:

{
  networking.firewall = {
    enable = true;

    # -------------------------------------------------------------------------
    # Default policy
    # -------------------------------------------------------------------------

    # Block unsolicited inbound traffic.
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];

    # Allow established / related traffic normally.
    checkReversePath = "loose";

    # -------------------------------------------------------------------------
    # ICMP / diagnostics
    # -------------------------------------------------------------------------

    # Keep ping available for normal diagnostics.
    allowPing = true;

    # -------------------------------------------------------------------------
    # Trusted interfaces
    # -------------------------------------------------------------------------
    #
    # Do not trust LAN interfaces globally.
    #
    # Tailscale can be added here later if we decide we want traffic arriving
    # over the Tailscale interface to bypass normal firewall filtering.
    #

    trustedInterfaces = [ ];

    # -------------------------------------------------------------------------
    # Logging
    # -------------------------------------------------------------------------

    logRefusedConnections = false;
    logReversePathDrops = true;

    # -------------------------------------------------------------------------
    # Extra firewall rules
    # -------------------------------------------------------------------------
    #
    # Keep this empty at the base layer.
    #
    # Individual modules should add narrowly scoped rules when needed.
    #

    extraCommands = "";
    extraStopCommands = "";
  };

  # ---------------------------------------------------------------------------
  # Notes
  # ---------------------------------------------------------------------------
  #
  # Ports should be opened by the module that owns the service.
  #
  # Examples:
  #
  #   SSH:
  #     modules/networking/ssh.nix
  #
  #   Tailscale:
  #     modules/networking/tailscale.nix
  #
  #   WireGuard:
  #     modules/networking/wireguard.nix
  #
  # This keeps the firewall configuration easy to audit and avoids building a
  # large global list of unrelated ports.
}
