{ pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # Audio
  # ---------------------------------------------------------------------------
  #
  # PipeWire provides the main audio stack.
  #
  # Compatibility layers are enabled for:
  #   - PulseAudio applications
  #   - ALSA applications
  #   - JACK applications
  #

  # PulseAudio should not run as a separate audio server.
  services.pulseaudio.enable = false;

  # Required for PipeWire session management.
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;

    # ALSA compatibility.
    alsa = {
      enable = true;

      # Allow 32-bit applications to use ALSA.
      # Useful for Steam/Wine/gaming later.
      support32Bit = true;
    };

    # PulseAudio compatibility.
    pulse.enable = true;

    # JACK compatibility for professional/creative applications.
    jack.enable = true;

    # WirePlumber manages PipeWire devices, routing, and policy.
    wireplumber.enable = true;
  };

  # ---------------------------------------------------------------------------
  # Bluetooth audio
  # ---------------------------------------------------------------------------

  hardware.bluetooth = {
    enable = true;

    # Restore Bluetooth controller state after reboot.
    powerOnBoot = true;

    settings = {
      General = {
        # Enables additional Bluetooth functionality/profile support.
        Experimental = true;
      };
    };
  };

  services.blueman.enable = true;

  # ---------------------------------------------------------------------------
  # Audio utilities
  # ---------------------------------------------------------------------------

  environment.systemPackages = with pkgs; [
    # PipeWire utilities
    pipewire

    # PulseAudio-compatible CLI utilities such as pactl.
    pulseaudio

    # ALSA utilities such as alsamixer and speaker-test.
    alsa-utils

    # PipeWire patchbay / graph viewer.
    qpwgraph

    # Useful mixer / volume control GUI.
    pavucontrol
  ];
}
