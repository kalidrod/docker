#!/usr/bin/env bash
# DockerX · scripts/docker-passthrough.sh
# Koi bhi docker command yahan se guzarta hai:  dockerx ps / dockerx run hello-world
DX_HOME="${DX_HOME:-$HOME/.dockerx}"
. "$DX_HOME/lib/common.sh"; . "$DX_HOME/lib/integrity.sh"; . "$DX_HOME/lib/platform.sh"; . "$DX_HOME/lib/engine.sh"
[ -f "$DX_CONFIG" ] && . "$DX_CONFIG"

dx_detect_platform
dx_set_sudo
dx_verify_integrity
dx_ensure_engine

# daemon band hai to chupchaap chalu kar do
if ! dx_daemon_running; then
  warn "Daemon band tha — chalu kar raha hoon..."
  dx_docker_start >/dev/null 2>&1
fi

dx_run_docker_cmd "$@"
