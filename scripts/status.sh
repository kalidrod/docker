#!/usr/bin/env bash
# DockerX · scripts/status.sh
DX_HOME="${DX_HOME:-$HOME/.dockerx}"
. "$DX_HOME/lib/common.sh"; . "$DX_HOME/lib/banner.sh"
. "$DX_HOME/lib/integrity.sh"; . "$DX_HOME/lib/platform.sh"; . "$DX_HOME/lib/engine.sh"
[ -f "$DX_CONFIG" ] && . "$DX_CONFIG"

dx_detect_platform
dx_set_sudo
dx_verify_integrity
dx_banner_mini
dx_ensure_engine
dx_docker_status
