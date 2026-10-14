#!/usr/bin/env bash
# =============================================================================
#  DockerX  ·  install.sh   (ONE-COMMAND UNIVERSAL INSTALLER)
# -----------------------------------------------------------------------------
#  Platforms:  Termux/Android · Linux (Ubuntu, Debian, Parrot, Kali, Mint…)
#              Windows (WSL) · macOS
#  Chalao:  bash install.sh
#  Built by Alexa for Hari Jadhav Ji.
# =============================================================================

set -o pipefail
DX_HOME="${DX_HOME:-$HOME/.dockerx}"
SRC="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"

# ---- Colors -----------------------------------------------------------------
R=$'\033[1;31m'; G=$'\033[1;32m'; Y=$'\033[1;33m'
C=$'\033[1;36m'; W=$'\033[1;37m'; M=$'\033[1;35m'; N=$'\033[0m'

# ---- Platform detect --------------------------------------------------------
if [ -d "/data/data/com.termux/files/usr" ]; then PLAT="termux"
elif grep -qiE "microsoft|wsl" /proc/version 2>/dev/null; then PLAT="wsl"
elif [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then PLAT="macos"
elif [ "$(uname -s 2>/dev/null)" = "Linux" ]; then PLAT="linux"
else PLAT="other"; fi

printf '%b\n' "${C}"
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
printf '%b\n' "${N}"
printf '%b\n' "  ${W}DOCKERX INSTALLER${N}  ${M}·${N} ${Y}Hari Jadhav Ji${N} ${M}·${N} ${C}by Alexa${N}"
printf '%b\n' "  ${W}Platform:${N} $PLAT"
echo

# ---- Windows native guide ---------------------------------------------------
if [ "$PLAT" = "other" ]; then
  printf '%b\n' "${Y}[!]${N} Windows native shell detect hua."
  printf '%b\n' "  ${W}Do raste hain:${N}"
  printf '%b\n' "  ${G}1)${N} Docker Desktop install karo: https://www.docker.com/products/docker-desktop/"
  printf '%b\n' "  ${G}2)${N} WSL2 kholo (Ubuntu) — uske andar ye installer chalao."
  exit 0
fi

# ---- Sanity: source files ---------------------------------------------------
for d in lib bin scripts config; do
  if [ ! -d "$SRC/$d" ]; then
    printf '%b\n' "${R}[x]${N} '$d' folder nahi mila. Poora DockerX folder extract karo, phir chalao."
    exit 1
  fi
done

# ---- Copy into DX_HOME ------------------------------------------------------
printf '%b\n' "${C}[*]${N} Files install ho rahi hain: $DX_HOME"
mkdir -p "$DX_HOME"
for d in lib bin scripts config; do
  rm -rf "$DX_HOME/$d"
  cp -r "$SRC/$d" "$DX_HOME/$d" 2>/dev/null || { printf '%b\n' "${R}[x]${N} Copy fail: $d"; exit 1; }
done

[ -f "$DX_HOME/config/settings.conf" ] && cp "$DX_HOME/config/settings.conf" "$DX_HOME/settings.conf"
[ -f "$DX_HOME/config/owner.conf" ]    && cp "$DX_HOME/config/owner.conf"    "$DX_HOME/owner.conf"

chmod +x "$DX_HOME/bin/dockerx" "$DX_HOME"/scripts/*.sh "$DX_HOME"/lib/*.sh 2>/dev/null
printf '%b\n' "${G}[+]${N} Files ready."

# ---- Run setup --------------------------------------------------------------
printf '%b\n' "${C}[*]${N} Setup shuru ho raha hai...\n"
bash "$DX_HOME/scripts/setup.sh"

echo
printf '%b\n' "${G}[+]${N} Install complete — sab kuch apne aap set ho gaya."
printf '%b\n' "${W}Ab bas ye chalao:${N} ${G}dockerx start${N}"
echo

# ---- Prompt turant apply: interactive shell auto-refresh --------------------
if [ -t 0 ] && [ -t 1 ]; then
  printf '%b\n' "${C}[*]${N} Prompt apply ho raha hai... (shell refresh)"
  exec bash -i
fi
