#!/usr/bin/env bash
# =============================================================================
#  DockerX  ·  scripts/doctor.sh   (cross-platform health-check)
# =============================================================================
DX_HOME="${DX_HOME:-$HOME/.dockerx}"
. "$DX_HOME/lib/common.sh"; . "$DX_HOME/lib/banner.sh"
. "$DX_HOME/lib/integrity.sh"; . "$DX_HOME/lib/platform.sh"; . "$DX_HOME/lib/engine.sh"
[ -f "$DX_CONFIG" ] && . "$DX_CONFIG"

dx_detect_platform
dx_set_sudo
dx_verify_integrity
dx_banner
step "DOCTOR — health check"
printf '%b\n' "  ${D}·${N} platform : $(dx_platform_name)"
printf '%b\n' "  ${D}·${N} arch     : $(uname -m)"

chk() { if [ "$2" = "0" ]; then printf '%b\n' "  ${G}✓${N} $1"; else printf '%b\n' "  ${R}✗${N} $1"; fi; }

case "$DX_PLATFORM" in
  termux)
    dx_have proot-distro; chk "proot-distro installed" $?
    dx_distro_installed "$DX_DISTRO"; chk "distro '$DX_DISTRO' installed+usable" $?
    printf '%b\n' "  ${D}·${N} proot-distro installed list:"
    proot-distro list --installed 2>/dev/null | sed 's/^/      /' | head -20
    if dx_distro_installed "$DX_DISTRO"; then
      proot-distro login "$DX_DISTRO" -- /bin/bash -c 'command -v docker >/dev/null 2>&1'
      chk "docker client (rootfs)" $?
      proot-distro login "$DX_DISTRO" -- /bin/bash -c 'docker info >/dev/null 2>&1'
      chk "dockerd running" $?
    fi
    ;;
  linux|wsl)
    dx_have docker; chk "docker installed" $?
    if dx_have docker; then docker info >/dev/null 2>&1; chk "dockerd running" $?; fi
    if dx_have systemctl; then systemctl is-active docker >/dev/null 2>&1; chk "docker service active" $?; fi
    ;;
  macos)
    dx_have docker; chk "docker installed" $?
    if dx_have docker; then docker info >/dev/null 2>&1; chk "dockerd running" $?; fi
    ;;
esac

FREE_KB="$(df -k "$HOME" 2>/dev/null | awk 'NR==2{print $4}')"
[ -n "$FREE_KB" ] && printf '%b\n' "  ${D}·${N} free     : $((FREE_KB/1024)) MB"

echo
step "Agar ✗ mile to"
case "$DX_PLATFORM" in
  termux)
    printf '%b\n' "  ${Y}•${N} Phone kernel me cgroup/namespace support na ho to dockerd nahi chalega."
    printf '%b\n' "  ${Y}•${N} Log:  dockerx shell  →  cat /var/log/dockerd.log" ;;
  linux|wsl)
    printf '%b\n' "  ${Y}•${N} Daemon ke liye sudo zaroori ho sakta hai:  sudo systemctl start docker"
    printf '%b\n' "  ${Y}•${N} Log:  /var/log/dockerd.log" ;;
  macos)
    printf '%b\n' "  ${Y}•${N} Docker Desktop app chalu karo." ;;
esac
echo
printf '%b\n' "  ${C}Log file:${N} $DX_LOG"
echo
