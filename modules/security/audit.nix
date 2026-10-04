{ pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # Linux Audit Framework
  # ---------------------------------------------------------------------------

  security.audit = {
    enable = true;

    # Large enough for bursts from Docker, libvirt, development tooling, etc.
    backlogLimit = 8192;

    # Unlimited audit messages/sec.
    #
    # Dropping audit messages because of a rate limit would defeat much of
    # the point of running auditd.
    rateLimit = 0;

    # Report audit subsystem failures to the kernel log.
    #
    # Do not use "panic" on a workstation unless you intentionally want an
    # audit failure to crash the machine.
    failureMode = "printk";

    # -------------------------------------------------------------------------
    # Audit rules
    # -------------------------------------------------------------------------

    rules = [
      # -----------------------------------------------------------------------
      # Identity / account databases
      # -----------------------------------------------------------------------

      "-w /etc/passwd -p wa -k identity"
      "-w /etc/group -p wa -k identity"
      "-w /etc/shadow -p wa -k identity"
      "-w /etc/gshadow -p wa -k identity"

      # -----------------------------------------------------------------------
      # Authentication / privilege configuration
      # -----------------------------------------------------------------------

      "-w /etc/pam.d -p wa -k pam"
      "-w /etc/sudoers -p wa -k sudo"
      "-w /etc/sudoers.d -p wa -k sudo"

      # -----------------------------------------------------------------------
      # SSH configuration
      # -----------------------------------------------------------------------

      "-w /etc/ssh -p wa -k ssh"

      # -----------------------------------------------------------------------
      # Host identity / networking configuration
      # -----------------------------------------------------------------------

      "-w /etc/hostname -p wa -k hostname"
      "-w /etc/hosts -p wa -k hosts"
      "-w /etc/resolv.conf -p wa -k dns"

      # -----------------------------------------------------------------------
      # Kernel module operations
      # -----------------------------------------------------------------------

      "-a always,exit -F arch=b64 -S init_module -S finit_module -S delete_module -k kernel_modules"
      "-a always,exit -F arch=b32 -S init_module -S finit_module -S delete_module -k kernel_modules"

      # -----------------------------------------------------------------------
      # Mount operations
      # -----------------------------------------------------------------------

      "-a always,exit -F arch=b64 -S mount -S umount2 -k mounts"
      "-a always,exit -F arch=b32 -S mount -S umount2 -k mounts"

      # -----------------------------------------------------------------------
      # Hostname / domain changes
      # -----------------------------------------------------------------------

      "-a always,exit -F arch=b64 -S sethostname -S setdomainname -k system_identity"
      "-a always,exit -F arch=b32 -S sethostname -S setdomainname -k system_identity"

      # -----------------------------------------------------------------------
      # System clock modification
      # -----------------------------------------------------------------------

      "-a always,exit -F arch=b64 -S adjtimex -S settimeofday -S clock_settime -k time_change"
      "-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S clock_settime -k time_change"

      # -----------------------------------------------------------------------
      # Reboot / shutdown related operations
      # -----------------------------------------------------------------------

      "-a always,exit -F arch=b64 -S reboot -k power"
      "-a always,exit -F arch=b32 -S reboot -k power"

      # -----------------------------------------------------------------------
      # Privilege escalation / root command execution
      # -----------------------------------------------------------------------
      #
      # Record programs executed as root when the original authenticated user
      # was a normal human user.
      #
      # This is especially useful on this workstation because sudo is
      # passwordless.
      #

      "-a always,exit -F arch=b64 -S execve -F euid=0 -F auid>=1000 -F auid!=unset -k privileged_exec"

      # -----------------------------------------------------------------------
      # Permission / ownership changes
      # -----------------------------------------------------------------------

      "-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -S chown -S fchown -S lchown -S fchownat -F auid>=1000 -F auid!=unset -k permissions"

      # -----------------------------------------------------------------------
      # Failed file access
      # -----------------------------------------------------------------------
      #
      # Record attempts by normal users that fail because of permission or
      # read-only filesystem restrictions.
      #

      "-a always,exit -F arch=b64 -S open -S openat -S openat2 -S creat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=unset -k denied_access"
      "-a always,exit -F arch=b64 -S open -S openat -S openat2 -S creat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=unset -k denied_access"

      # -----------------------------------------------------------------------
      # NixOS configuration
      # -----------------------------------------------------------------------

      "-w /etc/nixos -p wa -k nixos_configuration"
    ];
  };

  # ---------------------------------------------------------------------------
  # auditd userspace daemon
  # ---------------------------------------------------------------------------

  security.auditd = {
    enable = true;

    settings = {
      # Produce useful UID/GID/name information in logs.
      log_format = "ENRICHED";

      # Keep logs locally.
      write_logs = true;

      # Flush regularly without forcing a sync on every event.
      flush = "INCREMENTAL_ASYNC";
      freq = 50;

      # -----------------------------------------------------------------------
      # Log rotation
      # -----------------------------------------------------------------------

      # Size of each audit log in MiB.
      max_log_file = 100;

      # Number of rotated audit logs.
      num_logs = 10;

      max_log_file_action = "ROTATE";

      # -----------------------------------------------------------------------
      # Low disk handling
      # -----------------------------------------------------------------------

      space_left = "25%";
      space_left_action = "SYSLOG";

      admin_space_left = "10%";

      # Stop auditing if disk space becomes critically low rather than filling
      # the root filesystem completely.
      admin_space_left_action = "SUSPEND";

      disk_full_action = "SUSPEND";
      disk_error_action = "SYSLOG";

      # -----------------------------------------------------------------------
      # Miscellaneous
      # -----------------------------------------------------------------------

      name_format = "HOSTNAME";
    };
  };

  # ---------------------------------------------------------------------------
  # Audit tooling
  # ---------------------------------------------------------------------------

  environment.systemPackages = with pkgs; [
    audit
  ];
}
