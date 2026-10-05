# NixOS Configuration

Declarative NixOS configuration for my workstations, laptops, and servers.

The goal of this repository is to make my systems reproducible, modular, secure, and easy to rebuild from scratch.

## Goals

This repository is designed to manage:

- NixOS system configuration
- GNOME desktop configuration
- NVIDIA drivers and CUDA support
- Development environments
- Docker and container tooling
- Kubernetes and infrastructure tooling
- Virtualization
- Networking
- Security hardening
- Storage and mount configuration
- Home Manager
- Zsh and shell configuration
- Git and GitHub configuration
- VS Code
- Codex CLI
- SOPS-managed secrets
- Machine-specific configuration
- Shared profiles across multiple machines

A machine should eventually be recoverable by installing NixOS, cloning this repository, and rebuilding the appropriate host configuration.

---

# Repository Structure

```text
.
├── flake.nix
├── flake.lock
├── README.md
├── .gitignore
│
├── home/
│   └── sinless777/
│       ├── aliases.nix
│       ├── codex.nix
│       ├── default.nix
│       ├── fonts.nix
│       ├── git.nix
│       ├── gnome.nix
│       ├── packages.nix
│       ├── shell.nix
│       ├── vscode.nix
│       └── zsh.nix
│
├── hosts/
│   ├── desktop/
│   │   ├── default.nix
│   │   ├── disks.nix
│   │   ├── hardware-configuration.nix
│   │   ├── hardware.nix
│   │   └── networking.nix
│   │
│   ├── laptop/
│   │   ├── default.nix
│   │   ├── disks.nix
│   │   ├── hardware-configuration.nix
│   │   ├── hardware.nix
│   │   └── networking.nix
│   │
│   └── servers/
│       └── default.nix
│
├── modules/
│   ├── desktop/
│   ├── development/
│   ├── networking/
│   ├── security/
│   ├── storage/
│   ├── system/
│   └── virtualization/
│
├── profiles/
│   ├── ai.nix
│   ├── development.nix
│   ├── gaming.nix
│   ├── hardened.nix
│   ├── server.nix
│   └── workstation.nix
│
└── secrets/
    ├── README.md
    ├── common.yaml
    ├── hosts/
    │   └── desktop.yaml
    └── users/
        └── sinless777.yaml
```

---

# Architecture

The repository follows three main layers:

```text
Modules
   ↓
Profiles
   ↓
Hosts
```

## Modules

Modules provide individual capabilities.

Examples:

```text
modules/desktop/gnome.nix
modules/development/docker.nix
modules/networking/tailscale.nix
modules/security/apparmor.nix
modules/virtualization/libvirt.nix
```

Modules should be reusable and should avoid containing machine-specific configuration whenever possible.

---

## Profiles

Profiles combine modules into logical machine roles.

Examples:

### Workstation

```text
profiles/workstation.nix
```

May include:

- GNOME
- audio
- fonts
- NVIDIA
- networking
- workstation applications

### Development

```text
profiles/development.nix
```

May include:

- Git
- Node.js
- pnpm
- Python
- Go
- Rust
- .NET
- C/C++
- Terraform
- Ansible
- Packer
- Docker
- Kubernetes tooling

### AI

```text
profiles/ai.nix
```

May include:

- CUDA
- NVIDIA container support
- AI/ML tooling
- local inference tools

### Gaming

```text
profiles/gaming.nix
```

Can contain optional gaming configuration without forcing gaming packages onto every workstation.

### Server

```text
profiles/server.nix
```

Contains common configuration for server systems.

### Hardened

```text
profiles/hardened.nix
```

Contains additional security configuration suitable for systems requiring stronger defaults.

---

# Current Desktop

The primary workstation currently uses:

## CPU

AMD Ryzen Threadripper 1950X

- 16 physical cores
- 32 logical processors
- AMD-V virtualization support

## Motherboard

MSI X399-class motherboard

Model identifier:

```text
MS-7B92
```

## Memory

Approximately:

```text
125 GiB RAM
```

## GPU

NVIDIA GeForce RTX 3060 GPU.

The NixOS configuration will use the proprietary NVIDIA driver rather than Nouveau.

Planned use includes:

- GNOME desktop
- CUDA
- Blender
- GPU compute
- development
- AI workloads

## Networking

Wi-Fi:

```text
Intel Wi-Fi 6 AX200
wlp5s0
```

Ethernet:

```text
Intel I211
enp8s0
enp9s0
```

Additional networking tools include:

- Tailscale
- WireGuard
- OpenSSH
- firewall configuration

## Desktop

Desktop environment:

```text
GNOME
```

Preferences:

- Wayland where supported
- automatic login
- dark theme
- multi-monitor support

---

# Storage

The workstation contains multiple NVMe, SSD, and HDD devices.

Planned mount points include:

```text
/mnt/data
/mnt/projects
/mnt/aerealith
```

The dedicated Aerealith NVMe drive will be mounted under:

```text
/mnt/aerealith
```

Machine-specific storage definitions belong in:

```text
hosts/<hostname>/disks.nix
```

Filesystem UUIDs should be used instead of volatile device names such as:

```text
/dev/sda
/dev/sdb
```

when possible.

---

# Development Environment

The workstation is intended to support development across multiple ecosystems.

Planned tooling includes:

## JavaScript / TypeScript

- Node.js
- pnpm
- npm

## Python

- Python
- virtual environments
- ML development environments

## Go

- Go compiler and tooling

## Rust

- Rust
- Cargo

## .NET

- .NET SDK

## C / C++

- GCC
- Clang
- CMake
- Ninja
- pkg-config

## Infrastructure

- Terraform
- Ansible
- Packer
- Cloudflare tooling
- GitHub CLI

## Kubernetes

- kubectl
- Helm
- Talos CLI
- Flux CLI

## Containers

- Docker
- Docker Compose

Project-specific dependencies should generally be provided through Nix development shells rather than installing every possible dependency globally.

Example:

```bash
nix develop
```

---

# Home Manager

Home Manager manages user-level configuration.

Current user:

```text
sinless777
```

User configuration lives under:

```text
home/sinless777/
```

Home Manager will eventually manage:

- Zsh
- aliases
- shell environment
- Git
- fonts
- GNOME preferences
- VS Code
- Codex CLI
- user packages

---

# Shell

Primary shell:

```text
Zsh
```

The shell configuration follows a separation similar to:

```text
.zshenv
.zshrc
.zsh_aliases
.zsh_prompt
```

The Nix configuration should preserve this separation rather than creating a monolithic shell configuration.

The environment includes support for:

- XDG directories
- Git
- GitHub CLI
- Kubernetes
- Helm
- Terraform
- Ansible
- Docker
- Python
- Node.js
- pnpm
- direnv
- zoxide
- fzf
- SSH agent integration

---

# Git

Git configuration will be managed through Home Manager.

Planned configuration includes:

- default branch: `main`
- GitHub CLI
- SSH support
- commit signing
- tag signing

The preferred Git signing mechanism will be SSH signing.

GPG will remain available for other cryptographic operations.

Private signing keys must never be committed to this repository.

---

# Secrets

Secrets are managed with:

```text
sops-nix
age
```

Encrypted secret files may be committed.

Private keys and decrypted secrets must never be committed.

Secret structure:

```text
secrets/
├── common.yaml
├── hosts/
│   └── desktop.yaml
└── users/
    └── sinless777.yaml
```

Secrets can therefore be scoped as:

```text
global
user
host
```

Examples of information that should never be stored unencrypted include:

- API tokens
- SSH private keys
- age private keys
- Vault tokens
- Cloudflare API tokens
- GitHub tokens
- private certificates

---

# Vault

HashiCorp Vault will be supported for runtime secret access.

Default Vault endpoint:

```text
https://10.10.10.180:8200
```

Authentication tokens must remain outside Git.

Certificate verification should remain enabled unless explicitly required otherwise.

---

# Security

Planned security configuration includes:

- NixOS firewall
- AppArmor
- Fail2ban
- OpenSSH hardening
- SOPS
- age
- Vault
- passwordless sudo for the primary workstation user

SSH should eventually use:

```text
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
```

where appropriate.

Passwordless sudo is intended for trusted personal workstations and should not automatically be applied to every server.

---

# Virtualization

The workstation supports AMD-V.

Planned virtualization tooling includes:

- KVM
- QEMU
- libvirt
- virt-manager
- UEFI virtual machines

Virtualization configuration is located under:

```text
modules/virtualization/
```

---

# NixOS Flake

The main flake is:

```text
flake.nix
```

The primary desktop configuration is exposed as:

```text
.#desktop
```

---

# Common Commands

## Show flake outputs

```bash
nix flake show
```

## Check the flake

```bash
nix flake check
```

## Format Nix files

```bash
nix fmt
```

## Update dependencies

```bash
nix flake update
```

Review the changes to:

```text
flake.lock
```

before deploying them.

---

# Test Desktop Configuration

Test a configuration without permanently switching:

```bash
sudo nixos-rebuild test --flake .#desktop
```

This is preferred when making significant changes.

---

# Apply Desktop Configuration

The apply script switches the desktop configuration, including Home Manager:

```bash
./scripts/apply.sh
```

Run `./scripts/validate.sh` for syntax, formatting, and evaluation checks.
Use `./scripts/validate.sh --build` to also build without activation. Validation
builds default to one job with four cores; override with positive integer
`BUILD_MAX_JOBS` and `BUILD_CORES` environment variables. Large CUDA/C++ builds
can still require substantial memory and time. The configured Nix daemon limits
take effect after applying the configuration; the validator passes its limits
immediately.

Use `./scripts/apply.sh test` to activate temporarily, `boot` to apply at the
next boot, or `build` to build without activating. Select a configured host with
`--host HOST`, and preview the command with `--dry-run`.

Equivalent direct command:

```bash
sudo nixos-rebuild switch --flake .#desktop
```

---

# Build Without Activating

```bash
nixos-rebuild build --flake .#desktop
```

The build result will be created as:

```text
result
```

The `result` symlink is ignored by Git.

---

# Rollback

NixOS maintains previous generations automatically.

Previous generations can be selected from the bootloader if a new configuration fails.

System generations can also be inspected with:

```bash
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

---

# Adding Another Machine

Create a host directory:

```bash
mkdir -p hosts/laptop
```

The host should eventually contain:

```text
hosts/laptop/
├── default.nix
├── disks.nix
├── hardware-configuration.nix
├── hardware.nix
└── networking.nix
```

Then expose the host in:

```text
flake.nix
```

For example:

```nix
laptop = mkHost {
  hostname = "laptop";
  username = "sinless777";
  system = "x86_64-linux";
};
```

---

# Hardware Configuration

Do not manually invent:

```text
hardware-configuration.nix
```

It should be generated on the target NixOS machine.

Example:

```bash
sudo nixos-generate-config
```

The generated hardware configuration can then be incorporated into the appropriate host directory.

Hardware-specific configuration belongs under:

```text
hosts/<hostname>/
```

Reusable hardware capabilities should live under:

```text
modules/
```

---

# Configuration Philosophy

Keep the following separation:

## Host

Things specific to one physical machine.

Examples:

- filesystem UUIDs
- disk mounts
- GPU model-specific settings
- network interfaces
- hostname
- hardware configuration

## Module

One reusable capability.

Examples:

- Docker
- NVIDIA
- GNOME
- Tailscale
- SSH
- AppArmor

## Profile

A reusable collection of capabilities.

Examples:

```text
workstation
development
ai
gaming
server
hardened
```

## Home

User-specific configuration.

Examples:

- shell
- aliases
- VS Code
- Git
- desktop preferences
- user applications

---

# Rules

1. Never commit plaintext secrets.

2. Never commit private SSH, GPG, or age keys.

3. Commit `flake.lock`.

4. Prefer reusable modules over duplicated host configuration.

5. Keep hardware-specific settings inside the host.

6. Test major changes before switching.

7. Prefer:

```bash
sudo nixos-rebuild test --flake .#desktop
```

before:

```bash
sudo nixos-rebuild switch --flake .#desktop
```

8. Use project-specific Nix development environments where practical instead of polluting the global workstation environment.

9. Keep secrets encrypted with SOPS.

10. Keep the repository capable of supporting additional machines without redesigning the architecture.

---

# Long-Term Goal

Eventually a complete workstation recovery should look roughly like:

```bash
git clone <repository>
cd nixos-config
sudo nixos-rebuild switch --flake .#desktop
```

Future work may add Disko or another declarative installation layer so partitioning and full fresh-system installation can also be reproduced from this repository.
