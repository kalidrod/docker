#!/usr/bin/env bash
# DockerX · scripts/shell.sh  —  Linux rootfs ka shell kholo
DX_HOME="${DX_HOME:-$HOME/.dockerx}"
. "$DX_HOME/lib/common.sh"; . "$DX_HOME/lib/banner.sh"
. "$DX_HOME/lib/integrity.sh"; . "$DX_HOME/lib/platform.sh"; . "$DX_HOME/lib/engine.sh"
[ -f "$DX_CONFIG" ] && . "$DX_CONFIG"

dx_detect_platform
dx_set_sudo
dx_verify_integrity
dx_ensure_engine
log "Rootfs shell khul raha hai ($DX_DISTRO)."
warn "Yaad rakho: 'dockerx' sirf Termux me chalta hai, rootfs ke andar nahi."
warn "Bahar aane ke liye: exit   |   Phir docker chalane ke liye: dockerx start"
dx_distro_shell
