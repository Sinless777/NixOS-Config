{ ... }:

{
  # ---------------------------------------------------------------------------
  # Host identity
  # ---------------------------------------------------------------------------

  networking.hostName = "desktop";

  # ---------------------------------------------------------------------------
  # NetworkManager
  # ---------------------------------------------------------------------------
  #
  # The reusable NetworkManager configuration lives in:
  #
  #   modules/system/networking.nix
  #
  # This file contains only desktop-specific behavior.
  #

  networking.networkmanager = {
    # Keep all of this desktop's physical interfaces under NetworkManager.
    unmanaged = [ ];

    # Wi-Fi is primarily a fallback connection on this desktop.
    wifi = {
      powersave = false;
    };

    # -------------------------------------------------------------------------
    # Connection defaults
    # -------------------------------------------------------------------------
    #
    # Lower route-metric values are preferred.
    #
    # Ethernet:
    #   enp8s0 -> primary
    #   enp9s0 -> secondary
    #
    # Wi-Fi:
    #   wlp5s0 -> fallback
    #

    settings = {
      connection = {
        "ipv4.route-metric" = 100;
        "ipv6.route-metric" = 100;
      };
    };
  };

  # ---------------------------------------------------------------------------
  # DHCP
  # ---------------------------------------------------------------------------
  #
  # NetworkManager handles DHCP for:
  #
  #   enp8s0
  #   enp9s0
  #   wlp5s0
  #
  # Static addressing can be added later through declarative NetworkManager
  # profiles if desired.
  #

  networking.useDHCP = false;

  # ---------------------------------------------------------------------------
  # DNS
  # ---------------------------------------------------------------------------
  #
  # systemd-resolved is configured globally in:
  #
  #   modules/system/networking.nix
  #
  # When resolved is enabled, NixOS automatically configures NetworkManager
  # to use the systemd-resolved DNS plugin.
  #

  # ---------------------------------------------------------------------------
  # IPv6
  # ---------------------------------------------------------------------------

  networking.enableIPv6 = true;

  # ---------------------------------------------------------------------------
  # Interface notes
  # ---------------------------------------------------------------------------
  #
  # Physical interfaces:
  #
  #   wlp5s0
  #     Intel Wi-Fi 6 AX200
  #
  #   enp8s0
  #     Intel I211 Ethernet
  #
  #   enp9s0
  #     Intel I211 Ethernet
  #
  # Route priority:
  #
  #   enp8s0  -> primary wired
  #   enp9s0  -> secondary wired
  #   wlp5s0  -> wireless fallback
  #
}
