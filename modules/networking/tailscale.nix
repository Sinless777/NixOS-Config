{ lib, pkgs, ... }:

{
  services.tailscale = {
    enable = true;

    # Use the normal Tailscale package from nixpkgs.
    package = pkgs.tailscale;

    # Let Tailscale manage its state normally.
    useRoutingFeatures = "client";
  };

  # ---------------------------------------------------------------------------
  # Firewall
  # ---------------------------------------------------------------------------

  networking.firewall = {
    # Tailscale normally uses UDP 41641 for direct peer connections.
    allowedUDPPorts = [
      41641
    ];

    # Trust traffic coming from the Tailscale interface.
    trustedInterfaces = [
      "tailscale0"
    ];
  };

  # ---------------------------------------------------------------------------
  # Notes
  # ---------------------------------------------------------------------------
  #
  # Authentication is intentionally NOT stored here.
  #
  # Initial login:
  #
  #   sudo tailscale up
  #
  # After the machine is authenticated, Tailscale stores its state locally
  # and will reconnect automatically after reboot.
  #
  # If we later want fully unattended enrollment, we can use a SOPS-managed
  # auth key instead of committing credentials to Git.
}
