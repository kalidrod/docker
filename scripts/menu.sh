#!/usr/bin/env bash
# =============================================================================
#  DockerX  ·  scripts/menu.sh  —  interactive control panel
# =============================================================================
DX_HOME="${DX_HOME:-$HOME/.dockerx}"
. "$DX_HOME/lib/common.sh"; . "$DX_HOME/lib/banner.sh"
. "$DX_HOME/lib/integrity.sh"; . "$DX_HOME/lib/platform.sh"; . "$DX_HOME/lib/engine.sh"
[ -f "$DX_CONFIG" ] && . "$DX_CONFIG"

dx_detect_platform
dx_set_sudo
dx_verify_integrity

while true; do
  clear 2>/dev/null
  dx_banner
  printf '%b\n' "${W}  CONTROL PANEL${N}"
  dx_sep
  printf '%b\n' "  ${G}1${N})  Setup / Reinstall       ${D}(dockerx setup)${N}"
  printf '%b\n' "  ${G}2${N})  Start Docker daemon     ${D}(dockerx start)${N}"
  printf '%b\n' "  ${G}3${N})  Stop Docker daemon      ${D}(dockerx stop)${N}"
  printf '%b\n' "  ${G}4${N})  Status                  ${D}(dockerx status)${N}"
  printf '%b\n' "  ${G}5${N})  Linux shell             ${D}(dockerx shell)${N}"
  printf '%b\n' "  ${G}6${N})  Run hello-world test    ${D}(dockerx run hello-world)${N}"
  printf '%b\n' "  ${G}7${N})  Running containers      ${D}(dockerx ps)${N}"
  printf '%b\n' "  ${G}8${N})  Images list             ${D}(dockerx images)${N}"
  printf '%b\n' "  ${G}9${N})  Doctor (health check)   ${D}(dockerx doctor)${N}"
  printf '%b\n' "  ${M}10${N}) Update DockerX          ${D}(dockerx update)${N}"
  printf '%b\n' "  ${M}11${N}) Backup docker data      ${D}(dockerx backup)${N}"
  printf '%b\n' "  ${Y}13${N}) Fix / Recovery          ${D}(dockerx fix)${N}"
  printf '%b\n' "  ${R}12${N}) Uninstall               ${D}(dockerx uninstall)${N}"
  printf '%b\n' "  ${C}0${N})  Exit"
  dx_sep
  choice="$(dx_ask 'Choice:')"
  case "$choice" in
    1) bash "$DX_HOME/scripts/setup.sh"; dx_pause ;;
    2) bash "$DX_HOME/scripts/start.sh"; dx_pause ;;
    3) bash "$DX_HOME/scripts/stop.sh"; dx_pause ;;
    4) bash "$DX_HOME/scripts/status.sh"; dx_pause ;;
    5) bash "$DX_HOME/scripts/shell.sh" ;;
    6) bash "$DX_HOME/scripts/docker-passthrough.sh" run hello-world; dx_pause ;;
    7) bash "$DX_HOME/scripts/docker-passthrough.sh" ps; dx_pause ;;
    8) bash "$DX_HOME/scripts/docker-passthrough.sh" images; dx_pause ;;
    9) bash "$DX_HOME/scripts/doctor.sh"; dx_pause ;;
    10) bash "$DX_HOME/scripts/update.sh"; dx_pause ;;
    11) bash "$DX_HOME/scripts/backup.sh"; dx_pause ;;
    13) bash "$DX_HOME/scripts/fix.sh"; dx_pause ;;
    12) bash "$DX_HOME/scripts/uninstall.sh" ;;
    0|q|exit) ok "Bye! — Hari Jadhav Ji, phir milenge."; exit 0 ;;
    *) warn "Galat choice."; sleep 1 ;;
  esac
done
