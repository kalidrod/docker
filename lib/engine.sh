#!/usr/bin/env bash
# =============================================================================
#  DockerX  ·  lib/engine.sh   (cross-platform)
#  Docker install + daemon manage — Termux, Linux, WSL, macOS.
#  Built by Alexa for Hari Jadhav Ji.
# =============================================================================

DX_DISTRO="${DX_DISTRO:-ubuntu}"                 # Termux rootfs
DX_TERMUX_PREFIX="/data/data/com.termux/files/usr"

# =============================================================================
#  READY CHECK  (per platform)
# =============================================================================
# Termux rootfs sach me installed + usable hai? (path guess nahi — asli test)
dx_distro_installed() {
  local d="${1:-$DX_DISTRO}"
  dx_have proot-distro || return 1
  # 1) Definitive: login test (agar login chal jaye to pakka installed hai)
  proot-distro login "$d" -- /bin/true >/dev/null 2>&1 && return 0
  proot-distro login "$d" -- true >/dev/null 2>&1 && return 0
  # 2) Standard path check (bin/usr/etc hona chahiye)
  local p="$DX_TERMUX_PREFIX/var/lib/proot-distro/installed-rootfs/$d"
  if [ -d "$p" ] && { [ -d "$p/bin" ] || [ -d "$p/usr" ] || [ -d "$p/etc" ]; }; then
    return 0
  fi
  # 3) list --installed check
  proot-distro list --installed 2>/dev/null | grep -qiE "(^|[[:space:]\*])$d([[:space:]]|$)" && return 0
  return 1
}

dx_engine_ready() {
  case "${DX_PLATFORM:-}" in
    termux)
      dx_distro_installed "$DX_DISTRO" && return 0
      return 1
      ;;
    linux|wsl)
      dx_have docker && return 0
      return 1
      ;;
    macos)
      dx_have docker && return 0
      return 1
      ;;
    *)
      return 1
      ;;
  esac
}

# =============================================================================
#  AUTO-SETUP
# =============================================================================
dx_ensure_engine() {
  if dx_engine_ready; then return 0; fi
  warn "Pehli baar setup zaroori hai — DockerX khud kar raha hai (automatic)..."
  bash "$DX_HOME/scripts/setup.sh" || die "Auto-setup fail hua."
  dx_engine_ready || die "Auto-setup ke baad bhi engine ready nahi."
}

# =============================================================================
#  TERMUX (Android) — proot-distro rootfs
# =============================================================================
dx_termux_deps() {
  step "Termux packages check (fast mode)"
  export DEBIAN_FRONTEND=noninteractive
  local missing="" p
  for p in proot-distro termux-am which; do
    dx_have "$p" || missing="$missing $p"
  done
  if [ -z "$missing" ]; then
    ok "Sab Termux packages pehle se hain — update skip (fast)."
  else
    log "Missing:$missing — install ho raha hai..."
    pkg update -y >>"$DX_LOG" 2>&1 || warn "pkg update warning (ignore)."
    for p in $missing; do
      log "install: $p"
      pkg install -y "$p" >>"$DX_LOG" 2>&1 || warn "skip: $p"
    done
  fi
  dx_have proot-distro || die "proot-distro install nahi hua."
  ok "Termux deps ready."
}

dx_termux_install() {
  step "Linux rootfs setup: $DX_DISTRO (automatic)"

  # zaroori tools (download/extract ke liye)
  pkg install -y proot-distro tar xz-utils >/dev/null 2>&1 || true

  # internet check
  if dx_have ping && ! ping -c1 -W3 8.8.8.8 >/dev/null 2>&1 && ! ping -c1 -W3 1.1.1.1 >/dev/null 2>&1; then
    warn "Internet reachable nahi lag raha — rootfs download fail hoga."
    warn "Wi-Fi/mobile data check karo, phir 'dockerx setup' chalao."
  fi

  if dx_distro_installed "$DX_DISTRO"; then
    ok "$DX_DISTRO already installed — skip."
  else
    # adhura/partial rootfs pada ho to ek baar saaf karo
    local p="$DX_TERMUX_PREFIX/var/lib/proot-distro/installed-rootfs/$DX_DISTRO"
    if [ -e "$p" ]; then
      log "Adhura rootfs saaf kar raha hoon..."
      proot-distro remove "$DX_DISTRO" >/dev/null 2>&1 || rm -rf "$p" 2>/dev/null || true
    fi

    local attempt=1 installed=1
    while [ "$attempt" -le 3 ]; do
      log "Install attempt $attempt/3: $DX_DISTRO ..."
      proot-distro install "$DX_DISTRO" 2>&1 | tee -a "$DX_LOG"
      # asli test: distro login chal raha hai? (path guess nahi)
      if dx_distro_installed "$DX_DISTRO"; then installed=0; break; fi
      warn "Attempt $attempt fail."
      # sach me install nahi hua → partial saaf karo, retry clean ho
      proot-distro remove "$DX_DISTRO" >/dev/null 2>&1 || true
      if [ "$attempt" -lt 3 ]; then log "5s baad retry..."; sleep 5; fi
      attempt=$((attempt + 1))
    done

    # fallback distro (debian — ubuntu jaisa hi apt-based)
    if [ "$installed" -ne 0 ]; then
      warn "$DX_DISTRO fail — fallback try: debian"
      proot-distro install debian 2>&1 | tee -a "$DX_LOG"
      if dx_distro_installed debian; then
        DX_DISTRO="debian"; installed=0
        [ -f "$DX_CONFIG" ] && dx_sed_i "s/^DX_DISTRO=.*/DX_DISTRO=debian/" "$DX_CONFIG" 2>/dev/null
        ok "Fallback chala: debian"
      fi
    fi

    if [ "$installed" -ne 0 ]; then
      err "Rootfs install nahi ho paya. Checklist:"
      err "  1) Internet  : ping -c2 8.8.8.8"
      err "  2) Packages  : pkg update -y && pkg install -y proot-distro"
      err "  3) Storage   : termux-setup-storage"
      err "  4) Space     : 2GB+ free"
      err "  5) Log       : $DX_LOG"
      die "Distro install fail."
    fi
  fi

  ok "Rootfs ready: $DX_DISTRO"

  step "Docker engine rootfs ke andar install ho raha hai"
  proot-distro login "$DX_DISTRO" -- /bin/bash -c '
    export DEBIAN_FRONTEND=noninteractive
    export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    apt-get update -y >/tmp/apt.log 2>&1
    apt-get install -y --no-install-recommends docker.io iptables iproute2 ca-certificates curl procps >>/tmp/apt.log 2>&1
    if [ $? -ne 0 ] && grep -qi "Could not get lock" /tmp/apt.log; then
      echo "[!] dpkg lock mila — purane apt process hata raha hoon..."
      pkill -9 apt-get 2>/dev/null; pkill -9 dpkg 2>/dev/null; pkill -9 apt 2>/dev/null; sleep 2
      rm -f /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock /var/cache/apt/archives/lock
      dpkg --configure -a >/dev/null 2>&1
      apt-get install -y --no-install-recommends docker.io iptables iproute2 ca-certificates curl procps >>/tmp/apt.log 2>&1
    fi
    apt-get clean >/dev/null 2>&1
    mkdir -p /var/lib/docker /var/run /var/log
    command -v docker  >/dev/null 2>&1 && echo "[+] docker client OK"  || echo "[!] docker client MISSING"
    command -v dockerd >/dev/null 2>&1 && echo "[+] dockerd OK"        || echo "[!] dockerd MISSING"
    echo "---- apt tail ----"; tail -4 /tmp/apt.log
  ' 2>&1 | tee -a "$DX_LOG"
  # dockerd sach me hai? (PATH + common paths)
  if proot-distro login "$DX_DISTRO" -- /bin/bash -c 'export PATH="$PATH:/usr/sbin:/sbin"; command -v dockerd >/dev/null 2>&1 || [ -x /usr/bin/dockerd ] || [ -x /usr/sbin/dockerd ] || [ -x /usr/local/bin/dockerd ]'; then
    ok "Docker (docker + dockerd) install ho gaya."
  else
    warn "dockerd install nahi hua — 'dockerx fix' chalao, ya log dekho: $DX_LOG"
  fi
}

dx_termux_start() {
  step "Docker daemon start (persistent, no root)"

  # already chal raha hai?
  if dx_daemon_running; then ok "Docker already chal raha hai."; return 0; fi

  # dockerd ka path rootfs me dhoondo
  local dpath
  dpath="$(proot-distro login "$DX_DISTRO" -- /bin/bash -c 'export PATH="$PATH:/usr/sbin:/sbin"; command -v dockerd 2>/dev/null || ls /usr/bin/dockerd /usr/sbin/dockerd /usr/local/bin/dockerd 2>/dev/null | head -1' 2>/dev/null | tail -1)"
  if [ -z "$dpath" ]; then
    warn "dockerd nahi mila — pehle chalao: dockerx fix"
    return 1
  fi
  ok "dockerd: $dpath"

  local logf="$DX_HOME/dockerd.log"
  mkdir -p "$DX_HOME" 2>/dev/null
  warn "Note: proot me networking limited hai — containers ke liye --network=none ya --network=host"

  # Mode 3 (networking off + vfs) hi aksar chalta hai; pehle wahi try karo
  local MODE3="--iptables=false --ip6tables=false --ip-forward=false --ip-masq=false --bridge=none --storage-driver=vfs"
  local MODES=(
    "$MODE3"
    "--iptables=false --ip6tables=false --ip-forward=false --ip-masq=false --bridge=none"
    "--iptables=false --ip6tables=false --ip-forward=false --ip-masq=false --bridge=none --storage-driver=vfs --userland-proxy=false"
    ""
  )
  local i=1 flags
  for flags in "${MODES[@]}"; do
    log "Mode $i: dockerd $flags"
    proot-distro login "$DX_DISTRO" -- /bin/bash -c 'pkill -x dockerd 2>/dev/null' >/dev/null 2>&1
    sleep 1
    # PERSISTENT session: nohup + background me, dockerd foreground me (session zinda rahega)
    nohup proot-distro login "$DX_DISTRO" -- /bin/bash -c "export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin; exec $dpath $flags" >"$logf" 2>&1 &
    local w=0
    while [ $w -lt 5 ]; do
      sleep 2; w=$((w + 1))
      dx_daemon_running && { ok "DOCKER RUNNING (mode $i) — persistent"; return 0; }
    done
    warn "Mode $i fail."
    i=$((i + 1))
  done

  err "DOCKER NOT RUNNING — sab modes fail. Log: $logf"
  tail -n 14 "$logf" 2>/dev/null
  return 1
}
dx_termux_stop() {
  step "Docker daemon band ho raha hai"
  proot-distro login "$DX_DISTRO" -- /bin/bash -c 'pkill -x dockerd 2>/dev/null; pkill -x containerd 2>/dev/null; echo "[*] stopped"'
}
dx_termux_status() {
  proot-distro login "$DX_DISTRO" -- /bin/bash -c '
    export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    if docker info >/dev/null 2>&1; then echo "[+] DOCKER: running"; docker version --format "  client : {{.Client.Version}}" 2>/dev/null; docker info --format "  server : {{.ServerVersion}}" 2>/dev/null; else echo "[!] DOCKER: not running"; fi
  '
}
dx_termux_shell()  { proot-distro login "$DX_DISTRO"; }
dx_termux_docker() { proot-distro login "$DX_DISTRO" -- docker "$@"; }

# =============================================================================
#  LINUX / WSL  (Ubuntu, Debian, Parrot, Kali, Mint, Pop…)
# =============================================================================
dx_linux_deps() {
  step "System packages check"
  if ! dx_is_apt; then
    warn "apt nahi mila — ye distro shayad apt-based nahi hai."
    return 0
  fi
  dx_have curl || $DX_SUDO apt-get install -y curl ca-certificates >/dev/null 2>&1 || true
  ok "Deps ok."
}

dx_linux_install() {
  step "Docker install ho raha hai (apt)"
  if dx_have docker && docker --version >/dev/null 2>&1; then
    ok "Docker already installed — skip."
    return 0
  fi
  export DEBIAN_FRONTEND=noninteractive
  $DX_SUDO apt-get update -y >>"$DX_LOG" 2>&1 || warn "apt update warning."
  # Pehle distro package try karo (Ubuntu/Debian/Parrot sab me milta hai)
  if $DX_SUDO apt-get install -y --no-install-recommends docker.io >>"$DX_LOG" 2>&1; then
    ok "docker.io install ho gaya."
  elif dx_have curl; then
    warn "docker.io se nahi hua — official script try kar raha hoon..."
    curl -fsSL https://get.docker.com -o /tmp/get-docker.sh 2>>"$DX_LOG" \
      && $DX_SUDO sh /tmp/get-docker.sh >>"$DX_LOG" 2>&1 \
      && ok "Docker official script se install ho gaya." \
      || warn "Docker install fail — manual try karo."
  else
    warn "Docker install fail."
  fi
  # user ko docker group me daalo (sudo ke bina docker chalane ke liye)
  if [ -n "$DX_SUDO" ] && dx_have usermod; then
    $DX_SUDO usermod -aG docker "$USER" >>"$DX_LOG" 2>&1 || true
  fi
  ok "Docker install step complete."
}

dx_linux_start() {
  step "Docker daemon start"
  if docker info >/dev/null 2>&1; then ok "Docker already chal raha hai."; return 0; fi
  if dx_have systemctl; then $DX_SUDO systemctl start docker 2>/dev/null || true; fi
  if ! docker info >/dev/null 2>&1 && dx_have service; then $DX_SUDO service docker start 2>/dev/null || true; fi
  if ! docker info >/dev/null 2>&1; then
    warn "service se start nahi hua — dockerd direct try..."
    $DX_SUDO nohup dockerd >/var/log/dockerd.log 2>&1 &
    sleep 3
  fi
  if docker info >/dev/null 2>&1; then ok "DOCKER RUNNING"; else
    warn "DOCKER NOT RUNNING — log dekho: /var/log/dockerd.log"
    $DX_SUDO tail -n 8 /var/log/dockerd.log 2>/dev/null || true
  fi
}
dx_linux_stop() {
  step "Docker daemon band ho raha hai"
  if dx_have systemctl; then $DX_SUDO systemctl stop docker 2>/dev/null || true; fi
  if dx_have service; then $DX_SUDO service docker stop 2>/dev/null || true; fi
  $DX_SUDO pkill -x dockerd 2>/dev/null || true
  ok "stopped."
}
dx_linux_status() {
  if docker info >/dev/null 2>&1; then
    ok "DOCKER: running"
    docker version --format "  client : {{.Client.Version}}" 2>/dev/null
    docker info --format "  server : {{.ServerVersion}}  |  containers: {{.Containers}}  |  images: {{.Images}}" 2>/dev/null
  else
    warn "DOCKER: not running"
  fi
}
dx_linux_shell()  { exec bash -i; }
dx_linux_docker() { docker "$@"; }

# =============================================================================
#  macOS
# =============================================================================
dx_macos_install() {
  step "macOS detected"
  if dx_have docker; then ok "Docker mil gaya."; return 0; fi
  if dx_have brew; then
    log "brew se Docker install (cask)..."
    brew install --cask docker >>"$DX_LOG" 2>&1 && ok "Docker Desktop install ho gaya — app kholo." || warn "brew install fail."
  else
    warn "Docker Desktop manually install karo: https://www.docker.com/products/docker-desktop/"
  fi
}
dx_macos_start()  { dx_have docker && open -a Docker 2>/dev/null; sleep 3; dx_linux_status; }
dx_macos_stop()   { osascript -e 'quit app "Docker"' 2>/dev/null || true; ok "stopped."; }
dx_macos_status() { dx_linux_status; }
dx_macos_shell()  { exec bash -i; }
dx_macos_docker() { docker "$@"; }

# =============================================================================
#  WINDOWS (native bash, Git Bash / MSYS)
# =============================================================================
dx_windows_guide() {
  step "Windows detected (native shell)"
  warn "Windows me Docker native install bash script se nahi hota."
  printf '%b\n' "  ${W}Do raste hain:${N}"
  printf '%b\n' "  ${G}1)${N} Docker Desktop install karo: https://www.docker.com/products/docker-desktop/"
  printf '%b\n' "  ${G}2)${N} Ya WSL2 kholo (Ubuntu) — uske andar ye DockerX installer chalao."
}

# =============================================================================
#  DISPATCH  (platform ke hisaab se sahi function chalao)
# =============================================================================
dx_install_all() {
  case "$DX_PLATFORM" in
    termux) dx_termux_deps; dx_termux_install ;;
    linux|wsl) dx_linux_deps; dx_linux_install ;;
    macos)  dx_macos_install ;;
    *)      dx_windows_guide ;;
  esac
}

dx_docker_start() {
  case "$DX_PLATFORM" in
    termux) dx_termux_start ;;
    linux|wsl) dx_linux_start ;;
    macos) dx_macos_start ;;
    *) dx_windows_guide ;;
  esac
}
dx_docker_stop() {
  case "$DX_PLATFORM" in
    termux) dx_termux_stop ;;
    linux|wsl) dx_linux_stop ;;
    macos) dx_macos_stop ;;
    *) dx_windows_guide ;;
  esac
}
dx_docker_status() {
  case "$DX_PLATFORM" in
    termux) dx_termux_status ;;
    linux|wsl) dx_linux_status ;;
    macos) dx_macos_status ;;
    *) dx_windows_guide ;;
  esac
}
dx_distro_shell() {
  case "$DX_PLATFORM" in
    termux) dx_termux_shell ;;
    linux|wsl) dx_linux_shell ;;
    macos) dx_macos_shell ;;
    *) dx_windows_guide ;;
  esac
}
dx_run_docker_cmd() {
  case "$DX_PLATFORM" in
    termux) dx_termux_docker "$@" ;;
    linux|wsl) dx_linux_docker "$@" ;;
    macos) dx_macos_docker "$@" ;;
    *) dx_windows_guide ;;
  esac
}

# Daemon chal raha hai ya nahi (platform-aware)
dx_daemon_running() {
  case "$DX_PLATFORM" in
    termux) proot-distro login "$DX_DISTRO" -- /bin/bash -c 'docker info >/dev/null 2>&1' ;;
    linux|wsl|macos) docker info >/dev/null 2>&1 ;;
    *) return 1 ;;
  esac
}
