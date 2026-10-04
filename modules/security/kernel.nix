{ lib, ... }:

{
  # ---------------------------------------------------------------------------
  # Kernel image protection
  # ---------------------------------------------------------------------------
  #
  # Prevent replacing the running kernel via kexec.
  #
  # This also fits this workstation because hibernation is already disabled.
  #

  security.protectKernelImage = true;

  # ---------------------------------------------------------------------------
  # Kernel module loading
  # ---------------------------------------------------------------------------
  #
  # Do NOT lock module loading yet.
  #
  # This workstation dynamically uses:
  #
  #   NVIDIA
  #   Docker / netfilter
  #   KVM
  #   libvirt
  #   USB
  #   Tailscale
  #   WireGuard
  #   Bluetooth
  #
  # Once the complete system is stable, we can inventory `lsmod` and consider
  # enabling this.
  #

  security.lockKernelModules = lib.mkDefault false;

  # ---------------------------------------------------------------------------
  # Kernel command-line hardening
  # ---------------------------------------------------------------------------

  boot.kernelParams = [
    # Prevent merging slabs of similar sizes.
    "slab_nomerge"

    # Randomize page allocator freelists.
    "page_alloc.shuffle=1"

    # Initialize newly allocated memory.
    "init_on_alloc=1"

    # Clear memory when it is freed.
    "init_on_free=1"

    # Randomize kernel stack offsets.
    "randomize_kstack_offset=on"

    # Disable obsolete vsyscall compatibility.
    "vsyscall=none"

    # Enable Kernel Address Space Layout Randomization.
    "kaslr"

    # Disable debugfs at boot.
    "debugfs=off"
  ];

  # ---------------------------------------------------------------------------
  # Kernel / process hardening
  # ---------------------------------------------------------------------------

  boot.kernel.sysctl = {
    # -------------------------------------------------------------------------
    # Kernel information exposure
    # -------------------------------------------------------------------------

    # Hide kernel pointers even from most privileged processes.
    "kernel.kptr_restrict" = 2;

    # Prevent unprivileged access to the kernel message buffer.
    "kernel.dmesg_restrict" = 1;

    # -------------------------------------------------------------------------
    # ptrace
    # -------------------------------------------------------------------------
    #
    # 1 allows normal parent -> child debugging, keeping gdb usable while
    # preventing arbitrary same-user process inspection.
    #

    "kernel.yama.ptrace_scope" = 1;

    # -------------------------------------------------------------------------
    # Address-space / memory security
    # -------------------------------------------------------------------------

    # Full ASLR.
    "kernel.randomize_va_space" = 2;

    # Never dump memory from setuid/setgid programs.
    "fs.suid_dumpable" = 0;

    # -------------------------------------------------------------------------
    # Performance counters
    # -------------------------------------------------------------------------
    #
    # Restrict access while still leaving room for root/admin profiling.
    #

    "kernel.perf_event_paranoid" = 3;

    # -------------------------------------------------------------------------
    # eBPF
    # -------------------------------------------------------------------------
    #
    # Disable unprivileged BPF while still allowing privileged tooling.
    #

    "kernel.unprivileged_bpf_disabled" = 1;

    # Harden the BPF JIT against memory disclosure/JIT spraying attacks.
    "net.core.bpf_jit_harden" = 2;

    # -------------------------------------------------------------------------
    # userfaultfd
    # -------------------------------------------------------------------------

    "vm.unprivileged_userfaultfd" = 0;

    # -------------------------------------------------------------------------
    # TTY / line discipline
    # -------------------------------------------------------------------------

    # Stop unprivileged processes from autoloading uncommon TTY line
    # disciplines.
    "dev.tty.ldisc_autoload" = 0;

    # -------------------------------------------------------------------------
    # Filesystem hardening
    # -------------------------------------------------------------------------

    "fs.protected_hardlinks" = 1;
    "fs.protected_symlinks" = 1;

    "fs.protected_fifos" = 2;
    "fs.protected_regular" = 2;

    # -------------------------------------------------------------------------
    # Kernel panic behavior
    # -------------------------------------------------------------------------

    "kernel.panic_on_oops" = 1;

    # Automatically reboot after a panic.
    "kernel.panic" = 10;

    # -------------------------------------------------------------------------
    # SysRq
    # -------------------------------------------------------------------------

    # Disable Magic SysRq.
    "kernel.sysrq" = 0;
  };

  # ---------------------------------------------------------------------------
  # Kernel module blacklist
  # ---------------------------------------------------------------------------
  #
  # Disable obscure network protocols and filesystems that this workstation
  # does not need.
  #
  # We deliberately do NOT blacklist:
  #
  #   wireguard
  #   bluetooth
  #   usb_storage
  #   vfat
  #   ext4
  #   xfs
  #   btrfs
  #   ntfs
  #   exfat
  #   nvidia
  #   kvm
  #
  # because those are useful or explicitly required by this workstation.
  #

  boot.blacklistedKernelModules = [
    # Obscure / legacy network protocols.
    "ax25"
    "netrom"
    "rose"

    "dccp"
    "rds"
    "tipc"

    # Rare / legacy filesystems.
    "adfs"
    "affs"
    "befs"
    "bfs"
    "cramfs"
    "efs"
    "exofs"
    "freevxfs"
    "hfs"
    "hfsplus"
    "hpfs"
    "jfs"
    "minix"
    "nilfs2"
    "omfs"
    "qnx4"
    "qnx6"
    "sysv"
    "ufs"
  ];

  # ---------------------------------------------------------------------------
  # Console logging
  # ---------------------------------------------------------------------------

  # Only warnings and more severe messages are printed directly to console.
  boot.consoleLogLevel = 4;
}
