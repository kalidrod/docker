#!/usr/bin/env bash
# DockerX · scripts/backup.sh  (cross-platform)
DX_HOME="${DX_HOME:-$HOME/.dockerx}"
. "$DX_HOME/lib/common.sh"; . "$DX_HOME/lib/banner.sh"
. "$DX_HOME/lib/integrity.sh"; . "$DX_HOME/lib/platform.sh"; . "$DX_HOME/lib/engine.sh"
[ -f "$DX_CONFIG" ] && . "$DX_CONFIG"

dx_detect_platform
dx_set_sudo
dx_verify_integrity
dx_banner_mini
step "Backup"

OUT="$HOME/dockerx-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
dx_docker_stop 2>/dev/null || true

case "$DX_PLATFORM" in
  termux)
    ROOTFS="$DX_TERMUX_PREFIX/var/lib/proot-distro/installed-rootfs/$DX_DISTRO"
    if [ -d "$ROOTFS/var/lib/docker" ]; then
      log "Docker data backup: $OUT"
      tar -czf "$OUT" -C "$ROOTFS" var/lib/docker 2>>"$DX_LOG" \
        && ok "Backup ready: $OUT" || err "Backup fail."
    else
      warn "Docker data nahi mila ($ROOTFS/var/lib/docker)."
    fi
    ;;
  linux|wsl)
    if [ -d /var/lib/docker ]; then
      log "Docker data backup: $OUT (sudo)"
      $DX_SUDO tar -czf "$OUT" -C / var/lib/docker 2>>"$DX_LOG" \
        && ok "Backup ready: $OUT" || err "Backup fail."
    else
      warn "/var/lib/docker nahi mila."
    fi
    ;;
  *)
    warn "Is platform par automatic backup support nahi." ;;
esac
