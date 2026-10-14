#!/usr/bin/env bash
# DockerX · scripts/info.sh  —  help / about
DX_HOME="${DX_HOME:-$HOME/.dockerx}"
. "$DX_HOME/lib/common.sh"; . "$DX_HOME/lib/banner.sh"
. "$DX_HOME/lib/integrity.sh"; . "$DX_HOME/lib/platform.sh"
[ -f "$DX_CONFIG" ] && . "$DX_CONFIG"

dx_detect_platform
dx_verify_integrity

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  dx_banner_mini
  printf '%b\n' "${W}DOCKERX COMMANDS${N}"
  dx_sep
  cat <<EOF
  dockerx setup        Poora setup / reinstall
  dockerx start        Docker daemon chalu karo
  dockerx stop         Docker daemon band karo
  dockerx restart      Restart
  dockerx status       Daemon status
  dockerx shell        Shell kholo
  dockerx menu         Interactive control panel
  dockerx doctor       Health check / problem detect
  dockerx fix          Recovery — setup fail ho to sab theek karta hai
  dockerx update       Sab kuch update
  dockerx backup       Docker data ka backup
  dockerx uninstall    Hatao
  dockerx info         About
  dockerx help         Ye help

  --- Docker passthrough (koi bhi docker command) ---
  dockerx ps
  dockerx images
  dockerx run hello-world
  dockerx pull nginx
  dockerx exec -it <id> bash
  dockerx logs <id>
EOF
  echo
  exit 0
fi

dx_banner
printf '%b\n' "${W}ABOUT DOCKERX${N}"
dx_sep
cat <<EOF
  Ye ek single-command Docker tool hai — Termux / Linux / WSL / macOS sab me.
  Aapko kuch manually install nahi karna — 'dockerx setup' sab kar deta hai.

  Version    : 2.0
  Engine     : auto (platform ke hisaab se)
  Platform   : $(dx_platform_name)
  Built by   : Alexa
  Owner      : Hari Jadhav Ji
EOF
echo
dx_owner_panel
echo
