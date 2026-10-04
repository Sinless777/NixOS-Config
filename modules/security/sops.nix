{
  config,
  lib,
  username,
  ...
}:

{
  # ---------------------------------------------------------------------------
  # sops-nix
  # ---------------------------------------------------------------------------

  sops = {
    # Use age for decrypting secrets.
    age = {
      # Local private key used by this machine.
      #
      # This file must NOT be committed to Git.
      keyFile = "/var/lib/sops-nix/key.txt";

      # Generate the key automatically if it does not already exist.
      generateKey = true;
    };

    # -------------------------------------------------------------------------
    # Default SOPS file
    # -------------------------------------------------------------------------
    #
    # Host-specific secrets can override this per secret if needed.
    #

    defaultSopsFile = ../../secrets/common.yaml;

    # Keep the default format YAML.
    defaultSopsFormat = "yaml";

    # -------------------------------------------------------------------------
    # Common secrets
    # -------------------------------------------------------------------------
    #
    # These are examples of secrets that may exist in:
    #
    #   secrets/common.yaml
    #
    # Only add secrets here once they actually exist in the encrypted file.
    #

    secrets = {
      # Example:
      #
      # "restic-password" = {
      #   owner = "root";
      #   group = "root";
      #   mode = "0400";
      # };
      #
      # "cloudflare/api-token" = {
      #   owner = username;
      #   group = "users";
      #   mode = "0400";
      # };
      #
      # "vault/token" = {
      #   owner = username;
      #   group = "users";
      #   mode = "0400";
      # };
    };
  };

  # ---------------------------------------------------------------------------
  # Key directory
  # ---------------------------------------------------------------------------

  systemd.tmpfiles.rules = [
    "d /var/lib/sops-nix 0700 root root -"
  ];

  # ---------------------------------------------------------------------------
  # Notes
  # ---------------------------------------------------------------------------
  #
  # Recommended layout:
  #
  #   secrets/
  #   ├── common.yaml
  #   ├── users/
  #   │   └── sinless777.yaml
  #   └── hosts/
  #       └── desktop.yaml
  #
  # The age private key lives outside the repository:
  #
  #   /var/lib/sops-nix/key.txt
  #
  # Never commit:
  #
  #   - age private keys
  #   - decrypted YAML
  #   - API tokens
  #   - SSH private keys
  #   - Vault tokens
}
