#!/usr/bin/env bash
# =============================================================================
#  DockerX  ·  scripts/fix.sh
#  Recovery — setup/dockerd fail ho to ye sab theek karta hai.
#  Rootfs ko delete NAHI karta (jab tak zaroori na ho).
# =============================================================================
DX_HOME="${DX_HOME:-$HOME/.dockerx}"
. "$DX_HOME/lib/common.sh"; . "$DX_HOME/lib/banner.sh"
. "$DX_HOME/lib/integrity.sh"; . "$DX_HOME/lib/platform.sh"; . "$DX_HOME/lib/engine.sh"
[ -f "$DX_CONFIG" ] && . "$DX_CONFIG"

dx_detect_platform
dx_set_sudo
dx_verify_integrity
dx_banner_mini
step "DockerX FIX — recovery mode ($(dx_platform_name))"

case "$DX_PLATFORM" in
  termux)
    log "1/3 Internet check..."
    if ! dx_have ping || ping -c1 -W3 8.8.8.8 >/dev/null 2>&1 || ping -c1 -W3 1.1.1.1 >/dev/null 2>&1; then
      ok "Internet OK."
    else
      warn "Internet down lag raha hai — Wi-Fi/data on karo, phir 'dockerx fix' dobara."
    fi

    log "2/3 Termux packages..."
    pkg update -y >>"$DX_LOG" 2>&1 || warn "pkg update warning."
    pkg install -y proot-distro tar xz-utils which >>"$DX_LOG" 2>&1 || warn "pkg install warning."

    log "3/4 Purane apt lock saaf kar raha hoon..."
    if dx_distro_installed "$DX_DISTRO"; then
      proot-distro login "$DX_DISTRO" -- /bin/bash -c 'pkill -9 apt-get 2>/dev/null; pkill -9 dpkg 2>/dev/null; pkill -9 apt 2>/dev/null; rm -f /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock /var/cache/apt/archives/lock /var/lib/apt/lists/lock 2>/dev/null; dpkg --configure -a >/dev/null 2>&1; echo "[+] locks cleared"' >>"$DX_LOG" 2>&1 || true
    fi

    log "4/4 Docker engine repair..."
    if dx_distro_installed "$DX_DISTRO"; then
      ok "Distro '$DX_DISTRO' theek hai — sirf Docker engine andar install/repair kar raha hoon."
      proot-distro login "$DX_DISTRO" -- /bin/bash -c '
        export DEBIAN_FRONTEND=noninteractive
        export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
        apt-get update -y 2>&1 | tail -4
        apt-get install -y --no-install-recommends docker.io iptables iproute2 ca-certificates curl procps 2>&1 | tail -15
        apt-get clean >/dev/null 2>&1
        mkdir -p /var/lib/docker /var/run /var/log
        command -v docker  >/dev/null 2>&1 && echo "[+] docker client OK"  || echo "[!] docker client MISSING"
        command -v dockerd >/dev/null 2>&1 && echo "[+] dockerd OK"        || echo "[!] dockerd MISSING"
      ' 2>&1 | tee -a "$DX_LOG"
      ok "Repair done. Ab chalao: dockerx start"
    else
      warn "Distro '$DX_DISTRO' nahi mila — pura setup kar raha hoon..."
      bash "$DX_HOME/scripts/setup.sh"
    fi
    ;;
  linux|wsl|macos)
    log "Setup/repair dobara..."
    dx_install_all
    ok "Fix complete. Ab chalao: dockerx start"
    ;;
  *)
    dx_windows_guide ;;
esac
