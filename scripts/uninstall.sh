#!/usr/bin/env bash
# DockerX · scripts/uninstall.sh  (cross-platform)
DX_HOME="${DX_HOME:-$HOME/.dockerx}"
. "$DX_HOME/lib/common.sh"; . "$DX_HOME/lib/banner.sh"
. "$DX_HOME/lib/integrity.sh"; . "$DX_HOME/lib/platform.sh"; . "$DX_HOME/lib/engine.sh"
[ -f "$DX_CONFIG" ] && . "$DX_CONFIG"

dx_detect_platform
dx_set_sudo
dx_verify_integrity
dx_banner_mini
warn "Ye DockerX ko hata dega ($(dx_platform_name)). Aapka docker data safe rahega."
dx_confirm "Pakka uninstall karna hai?" || { ok "Cancel kiya."; exit 0; }

dx_docker_stop 2>/dev/null || true

case "$DX_PLATFORM" in
  termux)
    if dx_have proot-distro; then
      proot-distro remove "$DX_DISTRO" >>"$DX_LOG" 2>&1 && ok "Rootfs hataya: $DX_DISTRO" || warn "Rootfs remove fail."
    fi ;;
  linux|wsl)
    warn "Docker engine system me install hai — DockerX sirf apna tool hata raha hai."
    warn "Docker hatana ho to:  sudo apt-get remove docker.io" ;;
  macos)
    warn "Docker Desktop ko manually Applications se hatao." ;;
esac

LADIR="$(dx_launcher_dir)"
rm -f "$LADIR/${DX_LAUNCHER:-dockerx}" 2>/dev/null && ok "Launcher hataya ($LADIR)."

dx_sed_i '/# >>> dockerx prompt >>>/,/# <<< dockerx prompt <<</d' "$HOME/.bashrc" 2>/dev/null

dx_confirm "DockerX config (~/.dockerx) bhi delete karu?" && rm -rf "$DX_HOME" && ok "Config hataya."
ok "Uninstall complete. Phir se install: bash install.sh"
