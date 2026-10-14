#!/usr/bin/env bash
# DockerX · scripts/update.sh  (cross-platform)
DX_HOME="${DX_HOME:-$HOME/.dockerx}"
. "$DX_HOME/lib/common.sh"; . "$DX_HOME/lib/banner.sh"
. "$DX_HOME/lib/integrity.sh"; . "$DX_HOME/lib/platform.sh"; . "$DX_HOME/lib/engine.sh"
[ -f "$DX_CONFIG" ] && . "$DX_CONFIG"

dx_detect_platform
dx_set_sudo
dx_verify_integrity
dx_banner_mini
step "DockerX update  ($(dx_platform_name))"

case "$DX_PLATFORM" in
  termux)
    log "Termux packages update..."
    pkg update -y >>"$DX_LOG" 2>&1 || warn "pkg update warning."
    if dx_engine_ready; then
      log "Rootfs ke andar docker update..."
      proot-distro login "$DX_DISTRO" -- /bin/bash -c '
        export DEBIAN_FRONTEND=noninteractive
        apt-get update -y && apt-get install -y --only-upgrade docker.io
      ' >>"$DX_LOG" 2>&1 && ok "Docker updated." || warn "Docker update me dikkat."
    fi
    ;;
  linux|wsl)
    log "System + docker update (apt)..."
    $DX_SUDO apt-get update -y >>"$DX_LOG" 2>&1 || warn "apt update warning."
    $DX_SUDO apt-get install -y --only-upgrade docker.io >>"$DX_LOG" 2>&1 && ok "Docker updated." || warn "Docker update me dikkat."
    ;;
  macos)
    if dx_have brew; then
      log "Docker Desktop update (brew)..."
      brew upgrade --cask docker >>"$DX_LOG" 2>&1 && ok "Docker updated." || warn "Update fail."
    else
      warn "brew nahi mila — Docker Desktop manually update karo."
    fi
    ;;
  *) dx_windows_guide ;;
esac
ok "Update complete."
