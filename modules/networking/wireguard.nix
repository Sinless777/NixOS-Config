{ ... }:

{
  # Tailscale provides the WireGuard-based client configuration.
  # Import the shared module so Nix deduplicates it when both are enabled.
  imports = [ ./tailscale.nix ];
}
