{ ... }:

{
  home.file.".zsh_aliases".text = ''
    # =====================================================================
    # aliases.zsh — common interactive CLI aliases and helper functions
    # ---------------------------------------------------------------------
    # Managed by Home Manager.
    #
    # This file is sourced by ~/.zshrc.
    #
    # Keep this file:
    #   - interactive-shell only
    #   - low side-effect
    #   - safe for production systems
    #
    # Avoid destructive aliases that run immediately or remove large
    # amounts of data without confirmation.
    # =====================================================================

    # ---------------------------------------------------------------------
    # Guard
    # ---------------------------------------------------------------------

    case "$-" in
      *i*) ;;
      *) return 0 2>/dev/null || exit 0 ;;
    esac

    # ---------------------------------------------------------------------
    # Shell Options
    # ---------------------------------------------------------------------

    setopt no_nomatch 2>/dev/null || true

    # ---------------------------------------------------------------------
    # Basic Aliases
    # ---------------------------------------------------------------------

    alias ll='ls -lh'
    alias la='ls -lah'
    alias l='ls -CF'

    alias c='clear'
    alias cls='clear'

    alias ..='cd ..'
    alias ...='cd ../..'
    alias ....='cd ../../..'

    alias mkdirp='mkdir -p'

    alias reload='exec zsh'

    alias path='print -l ''${(s.:.)PATH}'

    # ---------------------------------------------------------------------
    # File / Editor
    # ---------------------------------------------------------------------

    alias e='nvim'
    alias v='nvim'

    alias svim='sudoedit'

    alias grep='grep --color=auto'
    alias egrep='egrep --color=auto'
    alias fgrep='fgrep --color=auto'

    if command -v bat >/dev/null 2>&1; then
      alias cat='bat --style=plain --paging=never'
      alias batp='bat --style=plain --paging=always'
    elif command -v batcat >/dev/null 2>&1; then
      alias cat='batcat --style=plain --paging=never'
      alias batp='batcat --style=plain --paging=always'
    fi

    if command -v eza >/dev/null 2>&1; then
      alias ls='eza --group-directories-first'
      alias ll='eza -lh --group-directories-first --git'
      alias la='eza -lah --group-directories-first --git'
      alias tree='eza --tree --group-directories-first'
    fi

    # ---------------------------------------------------------------------
    # System Information
    # ---------------------------------------------------------------------

    alias cpu='lscpu'
    alias mem='free -h'

    alias disk='df -h'
    alias disks='lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINTS'

    alias ds='du -sh -- * 2>/dev/null'

    alias ports='ss -tulpn'
    alias listeners='ss -tulpn'

    alias ipinfo='ip -c a'
    alias myip='curl -fsS https://ipinfo.io/ip'

    alias sctl='sudo systemctl'

    alias j='journalctl -xe'
    alias jf='journalctl -xef'

    alias bootlog='journalctl -b -p warning..alert'

    alias services='systemctl --type=service --state=running'
    alias failed='systemctl --failed'

    # ---------------------------------------------------------------------
    # Git
    # ---------------------------------------------------------------------

    alias g='git'

    alias gs='git status --short --branch'
    alias gst='git status'

    alias gl='git log --oneline --graph --decorate'
    alias gla='git log --oneline --graph --decorate --all'
    alias gll='git log --stat'

    alias gd='git diff'
    alias gds='git diff --staged'

    alias ga='git add'
    alias gaa='git add .'

    alias gc='git commit -m'
    alias gca='git commit -am'

    alias gco='git checkout'
    alias gcb='git checkout -b'

    alias gsw='git switch'
    alias gswc='git switch -c'

    alias gpull='git pull --rebase --autostash'

    alias gp='git push'
    alias gpf='git push --force-with-lease'

    alias gr='git restore'
    alias grs='git restore --staged'
    alias grsa='git restore --staged .'

    alias gundo='git reset --soft HEAD~1'

    alias gtags='git tag --sort=-creatordate'

    alias gb='git branch'
    alias gba='git branch -a'

    # Preview first.
    alias gclean-preview='git clean -xdfn'

    # Intentionally destructive, but explicit.
    alias gclean='git clean -xdf'

    # ---------------------------------------------------------------------
    # GitHub CLI
    # ---------------------------------------------------------------------

    if command -v gh >/dev/null 2>&1; then
      alias ghi='gh issue list'

      alias ghpr='gh pr list'
      alias ghprc='gh pr create'
      alias ghprv='gh pr view --web'

      alias ghw='gh workflow list'

      alias ghr='gh run list'
      alias ghrw='gh run watch'
    fi

    # ---------------------------------------------------------------------
    # Kubernetes
    # ---------------------------------------------------------------------

    if command -v kubecolor >/dev/null 2>&1; then
      alias k='kubecolor'
      alias kubectl='kubecolor'
    else
      alias k='kubectl'
    fi

    alias ka='kubectl apply -f'
    alias kd='kubectl delete -f'
    alias kdiff='kubectl diff -f'

    alias kga='kubectl get all'

    alias kgp='kubectl get pods -o wide'
    alias kgn='kubectl get nodes -o wide'
    alias kgns='kubectl get namespaces'

    alias kgc='kubectl config get-contexts'
    alias kuc='kubectl config use-context'
    alias kctx-current='kubectl config current-context'

    alias kdn='kubectl describe node'
    alias kdp='kubectl describe pod'
    alias kdd='kubectl describe deployment'
    alias kds='kubectl describe service'

    alias kl='kubectl logs'
    alias klf='kubectl logs -f'

    alias kexec='kubectl exec -it'

    alias ktop='kubectl top pod'
    alias ktopn='kubectl top node'

    alias kns='kubectl config set-context --current --namespace'

    alias kapi='kubectl api-resources'

    alias kevents='kubectl get events --sort-by=.lastTimestamp'

    alias kpods-bad='kubectl get pods --all-namespaces --field-selector=status.phase!=Running,status.phase!=Succeeded'

    if command -v kubectx >/dev/null 2>&1; then
      alias kctx='kubectx'
    fi

    if command -v kubens >/dev/null 2>&1; then
      alias kn='kubens'
    fi

    if command -v k9s >/dev/null 2>&1; then
      alias k9s-prod='k9s --context rke2-prod'
    fi

    # ---------------------------------------------------------------------
    # Talos
    # ---------------------------------------------------------------------

    if command -v talosctl >/dev/null 2>&1; then
      alias tctl='talosctl'
      alias talos-nodes='talosctl get members'
      alias talos-health='talosctl health'
    fi

    # ---------------------------------------------------------------------
    # Flux
    # ---------------------------------------------------------------------

    if command -v flux >/dev/null 2>&1; then
      alias flux-status='flux get all -A'
      alias flux-reconcile='flux reconcile'
    fi

    # ---------------------------------------------------------------------
    # Cilium
    # ---------------------------------------------------------------------

    if command -v cilium >/dev/null 2>&1; then
      alias cilium-status='cilium status'
      alias cilium-connectivity='cilium connectivity test'
    fi

    # ---------------------------------------------------------------------
    # Helm
    # ---------------------------------------------------------------------

    alias h='helm'

    alias hs='helm search repo'

    alias hls='helm list --all-namespaces'

    alias hi='helm install'
    alias hu='helm upgrade'
    alias hui='helm upgrade --install'

    alias hd='helm uninstall'

    alias hrs='helm repo update'
    alias hrv='helm repo list'

    alias ht='helm template'
    alias hlint='helm lint'

    # ---------------------------------------------------------------------
    # Terraform / OpenTofu
    # ---------------------------------------------------------------------

    alias tf='terraform'

    alias tfi='terraform init'
    alias tfp='terraform plan'
    alias tfa='terraform apply'
    alias tfd='terraform destroy'

    alias tff='terraform fmt -recursive'
    alias tfv='terraform validate'

    alias tfs='terraform state list'
    alias tfo='terraform output'

    alias tfw='terraform workspace list'

    if command -v tofu >/dev/null 2>&1; then
      alias tofu-init='tofu init'
      alias tofu-plan='tofu plan'
      alias tofu-apply='tofu apply'
      alias tofu-destroy='tofu destroy'
      alias tofu-fmt='tofu fmt -recursive'
      alias tofu-validate='tofu validate'
    fi

    # ---------------------------------------------------------------------
    # Packer
    # ---------------------------------------------------------------------

    if command -v packer >/dev/null 2>&1; then
      alias pk='packer'
      alias pki='packer init'
      alias pkfmt='packer fmt'
      alias pkvalidate='packer validate'
      alias pkbuild='packer build'
    fi

    # ---------------------------------------------------------------------
    # Ansible
    # ---------------------------------------------------------------------

    alias a='ansible'
    alias ap='ansible-playbook'
    alias av='ansible-vault'

    alias ainv='ansible-inventory --graph'

    alias pingall='ansible all -m ping'

    alias alint='ansible-lint'

    alias acheck='ansible-playbook --check --diff'

    # ---------------------------------------------------------------------
    # Docker / Compose
    # ---------------------------------------------------------------------

    alias d='docker'

    alias dps='docker ps'
    alias dpa='docker ps -a'

    alias dimg='docker images'

    alias dstats='docker stats'

    alias dlogin='docker exec -it'

    alias dlogs='docker logs'
    alias dlogsf='docker logs -f'

    alias dc='docker compose'

    alias dcb='docker compose build'

    alias dcu='docker compose up'
    alias dcud='docker compose up -d'

    alias dcd='docker compose down'

    alias dcl='docker compose logs'
    alias dclf='docker compose logs -f'

    alias dcp='docker compose ps'

    alias dcr='docker compose restart'
    alias dce='docker compose exec'

    if command -v docker-compose >/dev/null 2>&1; then
      alias dco='docker-compose'
    fi

    # ---------------------------------------------------------------------
    # Docker Helpers
    # ---------------------------------------------------------------------

    docker-stop-all() {
      local containers

      containers="$(docker ps -q)"

      if [[ -z "$containers" ]]; then
        print "No running containers."
        return 0
      fi

      print "Stopping all running containers:"

      docker ps --format '  {{.Names}}  {{.Image}}'

      read "reply?Continue? [y/N] "

      [[ "$reply" == [Yy] ]] || return 1

      docker stop ''${=containers}
    }

    docker-remove-stopped() {
      local containers

      containers="$(docker ps -aq --filter status=exited)"

      if [[ -z "$containers" ]]; then
        print "No stopped containers."
        return 0
      fi

      print "Removing stopped containers:"

      docker ps \
        -a \
        --filter status=exited \
        --format '  {{.Names}}  {{.Image}}'

      read "reply?Continue? [y/N] "

      [[ "$reply" == [Yy] ]] || return 1

      docker rm ''${=containers}
    }

    docker-prune-safe() {
      docker system prune
    }

    # ---------------------------------------------------------------------
    # Networking / Debug
    # ---------------------------------------------------------------------

    alias pingg='ping google.com'

    alias trace='traceroute'

    alias digg='dig +short'

    alias dnsflush='sudo resolvectl flush-caches'
    alias dnsstatus='resolvectl status'

    alias curlh='curl -I'
    alias curlv='curl -v'

    alias wgetc='wget -c'

    # ---------------------------------------------------------------------
    # Tailscale
    # ---------------------------------------------------------------------

    if command -v tailscale >/dev/null 2>&1; then
      alias ts='tailscale'
      alias tsstatus='tailscale status'
      alias tsip='tailscale ip'
      alias tsping='tailscale ping'
    fi

    # ---------------------------------------------------------------------
    # WireGuard
    # ---------------------------------------------------------------------

    if command -v wg >/dev/null 2>&1; then
      alias wgshow='sudo wg show'
    fi

    # ---------------------------------------------------------------------
    # Processes
    # ---------------------------------------------------------------------

    alias psg='ps aux | grep -i --color=auto'

    alias topu='top -u "$USER"'

    alias kill9='kill -9'

    alias pgrepfull='pgrep -af'

    # ---------------------------------------------------------------------
    # Python
    # ---------------------------------------------------------------------

    alias py='python3'

    # Explicit user installation when needed.
    alias pipu='python3 -m pip install --user'

    alias venv='python3 -m venv .venv'

    alias activate='source .venv/bin/activate'

    alias pytestq='pytest -q'

    if command -v uv >/dev/null 2>&1; then
      alias uvr='uv run'
      alias uvsync='uv sync'
      alias uvvenv='uv venv'
    fi

    # ---------------------------------------------------------------------
    # Node / NPM
    # ---------------------------------------------------------------------

    alias ni='npm install'
    alias nr='npm run'

    alias nstart='npm start'

    alias nrb='npm run build'
    alias nrt='npm run test'
    alias nrd='npm run dev'

    alias nci='npm ci'

    # ---------------------------------------------------------------------
    # PNPM
    # ---------------------------------------------------------------------

    if command -v pnpm >/dev/null 2>&1; then
      alias pi='pnpm install'
      alias pr='pnpm run'

      alias pd='pnpm dev'
      alias pb='pnpm build'
      alias pt='pnpm test'

      alias px='pnpm exec'
    fi

    # ---------------------------------------------------------------------
    # Yarn
    # ---------------------------------------------------------------------

    if command -v yarn >/dev/null 2>&1; then
      alias yi='yarn install'
      alias yr='yarn run'

      alias yd='yarn dev'
      alias yb='yarn build'
      alias yt='yarn test'
    fi

    # ---------------------------------------------------------------------
    # Rust
    # ---------------------------------------------------------------------

    if command -v cargo >/dev/null 2>&1; then
      alias cb='cargo build'
      alias cr='cargo run'
      alias ct='cargo test'
      alias cc='cargo check'
      alias cfmt='cargo fmt'
      alias cclippy='cargo clippy'
    fi

    # ---------------------------------------------------------------------
    # Go
    # ---------------------------------------------------------------------

    if command -v go >/dev/null 2>&1; then
      alias gob='go build'
      alias got='go test ./...'
      alias gor='go run'
      alias gofmtall='gofmt -w .'
    fi

    # ---------------------------------------------------------------------
    # .NET
    # ---------------------------------------------------------------------

    if command -v dotnet >/dev/null 2>&1; then
      alias dn='dotnet'
      alias dnb='dotnet build'
      alias dnr='dotnet run'
      alias dnt='dotnet test'
      alias dnrstr='dotnet restore'
    fi

    # ---------------------------------------------------------------------
    # Nix / NixOS
    # ---------------------------------------------------------------------

    alias nixfmt='nix fmt'

    alias nixcheck='nix flake check'
    alias nixshow='nix flake show'

    alias nixupdate='nix flake update'

    alias nbuild='sudo nixos-rebuild build --flake .#desktop'
    alias ntest='sudo nixos-rebuild test --flake .#desktop'
    alias nswitch='sudo nixos-rebuild switch --flake .#desktop'

    alias ngen='sudo nix-env --list-generations --profile /nix/var/nix/profiles/system'

    # ---------------------------------------------------------------------
    # Nix Store
    # ---------------------------------------------------------------------

    alias nixgc='sudo nix-collect-garbage'
    alias nixgc-old='sudo nix-collect-garbage --delete-old'
    alias nixoptimise='sudo nix store optimise'

    # ---------------------------------------------------------------------
    # SOPS / age
    # ---------------------------------------------------------------------

    if command -v sops >/dev/null 2>&1; then
      alias sopse='sops --encrypt'
      alias sopsd='sops --decrypt'
    fi

    if command -v age-keygen >/dev/null 2>&1; then
      alias agepub='age-keygen -y'
    fi

    # ---------------------------------------------------------------------
    # Vault
    # ---------------------------------------------------------------------

    if command -v vault >/dev/null 2>&1; then
      alias vstatus='vault status'
      alias vlogin='vault login'
      alias vtoken='vault token lookup'
    fi

    # ---------------------------------------------------------------------
    # NVIDIA / CUDA
    # ---------------------------------------------------------------------

    if command -v nvidia-smi >/dev/null 2>&1; then
      alias gpu='nvidia-smi'
      alias gpuwatch='watch -n 1 nvidia-smi'
    fi

    if command -v nvcc >/dev/null 2>&1; then
      alias nvccv='nvcc --version'
    fi

    if command -v nvtop >/dev/null 2>&1; then
      alias gputop='nvtop'
    fi

    # ---------------------------------------------------------------------
    # libvirt / VMs
    # ---------------------------------------------------------------------

    if command -v virsh >/dev/null 2>&1; then
      alias vms='virsh list --all'
      alias vmstart='virsh start'
      alias vmstop='virsh shutdown'
      alias vmdestroy='virsh destroy'
      alias vmconsole='virsh console'
    fi

    # ---------------------------------------------------------------------
    # Security / Auditing
    # ---------------------------------------------------------------------

    if command -v ausearch >/dev/null 2>&1; then
      alias audit-root='sudo ausearch -k privileged_exec'
      alias audit-kmods='sudo ausearch -k kernel_modules'
      alias audit-denied='sudo ausearch -k denied_access'
      alias audit-summary='sudo aureport'
    fi

    if command -v aa-status >/dev/null 2>&1; then
      alias aastatus='sudo aa-status'
    fi

    if command -v fail2ban-client >/dev/null 2>&1; then
      alias f2b='sudo fail2ban-client status'
      alias f2bssh='sudo fail2ban-client status sshd'
    fi

    if command -v usbguard >/dev/null 2>&1; then
      alias usbdevices='sudo usbguard list-devices'
    fi

    # ---------------------------------------------------------------------
    # DevOps / Repo Tools
    # ---------------------------------------------------------------------

    alias t='task'
    alias mk='make'

    alias watch1='watch -n 1'

    alias rmds='find . -name ".DS_Store" -delete'

    alias chmodx='chmod +x'

    # ---------------------------------------------------------------------
    # Infrastructure Repository
    # ---------------------------------------------------------------------

    infra-root() {
      local root

      root="$(git rev-parse --show-toplevel 2>/dev/null)"

      if [[ -n "$root" ]]; then
        cd "$root" || return

      elif [[ -d "$HOME/Projects/Infrastructure" ]]; then
        cd "$HOME/Projects/Infrastructure" || return

      else
        print "Infrastructure repo not found."
        return 1
      fi
    }

    alias infra='infra-root'

    alias kprod='export KUBECONFIG="$HOME/Projects/Infrastructure/.generated/kubernetes/prod/kubeconfig.yaml"'

    alias kprod-nodes='kubectl get nodes -o wide'

    alias kprod-pods='kubectl get pods -A -o wide'

    # ---------------------------------------------------------------------
    # Aerealith
    # ---------------------------------------------------------------------

    aerealith-root() {
      if [[ -d "/mnt/aerealith/Aerealith" ]]; then
        cd "/mnt/aerealith/Aerealith" || return

      elif [[ -d "/mnt/aerealith" ]]; then
        cd "/mnt/aerealith" || return

      else
        print "Aerealith storage is not mounted."
        return 1
      fi
    }

    alias aerealith='aerealith-root'

    # ---------------------------------------------------------------------
    # Safer Helpers
    # ---------------------------------------------------------------------

    mkcd() {
      if [[ -z "$1" ]]; then
        print "usage: mkcd <directory>" >&2
        return 2
      fi

      mkdir -p -- "$1" && cd -- "$1"
    }

    extract() {
      if [[ -z "$1" ]]; then
        print "usage: extract <archive>" >&2
        return 2
      fi

      if [[ ! -f "$1" ]]; then
        print "extract: file not found: $1" >&2
        return 1
      fi

      case "$1" in
        *.tar.bz2) tar xjf "$1" ;;
        *.tar.gz)  tar xzf "$1" ;;
        *.tar.xz)  tar xJf "$1" ;;
        *.tar.zst) tar --zstd -xf "$1" ;;

        *.bz2) bunzip2 "$1" ;;
        *.gz)  gunzip "$1" ;;
        *.xz)  unxz "$1" ;;
        *.zst) unzstd "$1" ;;

        *.rar) unrar x "$1" ;;

        *.tar) tar xf "$1" ;;

        *.tbz2) tar xjf "$1" ;;
        *.tgz)  tar xzf "$1" ;;

        *.zip) unzip "$1" ;;

        *.Z) uncompress "$1" ;;

        *.7z) 7z x "$1" ;;

        *)
          print "extract: unsupported archive: $1" >&2
          return 1
          ;;
      esac
    }

    # ---------------------------------------------------------------------
    # Git repository root
    # ---------------------------------------------------------------------

    croot() {
      local root

      root="$(git rev-parse --show-toplevel 2>/dev/null)"

      if [[ -z "$root" ]]; then
        print "Not inside a Git repository."
        return 1
      fi

      cd "$root" || return
    }

    # ---------------------------------------------------------------------
    # Ports helper
    # ---------------------------------------------------------------------

    portwho() {
      if [[ -z "$1" ]]; then
        print "usage: portwho <port>" >&2
        return 2
      fi

      sudo ss -lptn "sport = :$1"
    }

    # ---------------------------------------------------------------------
    # NixOS rebuild helper
    # ---------------------------------------------------------------------

    nix-rebuild() {
      local action="''${1:-test}"
      local host="''${2:-desktop}"

      case "$action" in
        build|test|switch)
          sudo nixos-rebuild \
            "$action" \
            --flake ".#$host"
          ;;

        *)
          print "usage: nix-rebuild {build|test|switch} [host]" >&2
          return 2
          ;;
      esac
    }

    # ---------------------------------------------------------------------
    # End of aliases.zsh
    # ---------------------------------------------------------------------
  '';
}
