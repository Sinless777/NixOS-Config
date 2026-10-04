{ lib, pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # NetworkManager
  # ---------------------------------------------------------------------------

  networking.networkmanager = {
    enable = true;

    # Let NetworkManager manage DNS through systemd-resolved.
    dns = "systemd-resolved";

    # Keep Wi-Fi support enabled.
    wifi = {
      powersave = false;
    };
  };

  # ---------------------------------------------------------------------------
  # systemd-resolved
  # ---------------------------------------------------------------------------

  services.resolved = {
    enable = true;

    # DNSSEC support where available.
    settings.Resolve.DNSSEC = "allow-downgrade";

    # Allow DNS-over-TLS when the upstream resolver supports it.
    settings.Resolve.DNSOverTLS = "opportunistic";

    # Useful for local service discovery and modern Linux networking.
    settings.Resolve.LLMNR = "resolve";

    # mDNS support for .local names and local network discovery.
    settings.Resolve = {
      MulticastDNS = true;
      Cache = true;
    };
  };

  # ---------------------------------------------------------------------------
  # Hostname
  # ---------------------------------------------------------------------------
  #
  # The actual hostname should be set in:
  #
  #   hosts/<hostname>/default.nix
  #
  # Example:
  #
  #   networking.hostName = "desktop";
  #

  # ---------------------------------------------------------------------------
  # DHCP
  # ---------------------------------------------------------------------------

  # NetworkManager handles DHCP for managed interfaces.
  networking.useDHCP = lib.mkDefault false;

  # ---------------------------------------------------------------------------
  # IPv6
  # ---------------------------------------------------------------------------

  networking.enableIPv6 = true;

  # ---------------------------------------------------------------------------
  # Wireless regulatory database
  # ---------------------------------------------------------------------------

  hardware.wirelessRegulatoryDatabase = true;

  # ---------------------------------------------------------------------------
  # Useful networking packages
  # ---------------------------------------------------------------------------

  environment.systemPackages = with pkgs; [
    bind
    curl
    dig
    ethtool
    inetutils
    iperf3
    iproute2
    iw
    mtr
    nmap
    traceroute
    wget
  ];
}
