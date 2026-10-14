#!/usr/bin/env bash
# =============================================================================
#  DockerX · cross-platform  ·  lib/banner.sh
#  Docker ka apna whale banner + owner panel (banner ke niche).
#  Owner naam ko koi badal na sake — isliye ye hard-coded + verified hai.
# =============================================================================

dx_banner() {
  printf '%b' "$C"
  cat <<'EOF'
                    ##         .
              ## ## ##        ==
           ## ## ## ## ##    ===
       /""""""""""""""""___/ ===
  ~~~ {~~ ~~~~ ~~~ ~~~~ ~~ ~ /  ===- ~~~
       \______ o          __/
        \    \        __/
          \____\______/
EOF
  printf '%b\n' "$N"
  printf '%b\n' "  ${W}D O C K E R X${N}   ${M}·${N} ${C}cross-platform${N}   ${M}·${N} ${Y}by Alexa${N}"
  echo
  dx_owner_panel
}

dx_owner_panel() {
  printf '%b\n' "${R}  ╔══════════════════════════════════════════════════════════╗${N}"
  printf '%b\n' "${R}  ║${N}  ${W}OWNER      ${N}: ${G}Hari Jadhav Ji${N}"
  printf '%b\n' "${R}  ║${N}  ${W}INSTAGRAM  ${N}: ${C}ur_.krishn._02${N}"
  printf '%b\n' "${R}  ║${N}  ${W}TELEGRAM   ${N}: ${C}nullkrishn${N}"
  printf '%b\n' "${R}  ║${N}  ${W}GITHUB     ${N}: ${C}nullkrishn3${N}"
  printf '%b\n' "${R}  ║${N}  ${W}BUILT BY   ${N}: ${M}Alexa${N}"
  printf '%b\n' "${R}  ╚══════════════════════════════════════════════════════════╝${N}"
}

# Chhota banner (menu / commands ke liye)
dx_banner_mini() {
  printf '%b\n' "${C}  ▄▄  DockerX${N} ${D}·${N} ${Y}Hari Jadhav Ji${N} ${D}·${N} ${M}by Alexa${N}"
}
