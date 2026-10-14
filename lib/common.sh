#!/usr/bin/env bash
# =============================================================================
#  DockerX for Termux  ·  lib/common.sh
#  Common colors, logging aur helper functions.
#  Built by Alexa for Hari Jadhav Ji.
# =============================================================================

# ---- Paths ------------------------------------------------------------------
DX_HOME="${DX_HOME:-$HOME/.dockerx}"
DX_LOG="${DX_LOG:-$DX_HOME/dockerx.log}"
DX_CONFIG="$DX_HOME/settings.conf"
DX_OWNER_CONF="$DX_HOME/owner.conf"
mkdir -p "$DX_HOME" 2>/dev/null

# ---- Colors (auto-off when not a terminal) ----------------------------------
if [ -t 1 ]; then
  R=$'\033[1;31m'; G=$'\033[1;32m'; Y=$'\033[1;33m'
  B=$'\033[1;34m'; M=$'\033[1;35m'; C=$'\033[1;36m'
  W=$'\033[1;37m'; N=$'\033[0m'; D=$'\033[2m'
else
  R=""; G=""; Y=""; B=""; M=""; C=""; W=""; N=""; D=""
fi

# ---- Logging ----------------------------------------------------------------
dx_raw() { printf '%s\n' "$*" >>"$DX_LOG" 2>/dev/null; }
log()  { printf '%b\n' "${B}[*]${N} $*"; dx_raw "[*] $*"; }
ok()   { printf '%b\n' "${G}[+]${N} $*"; dx_raw "[+] $*"; }
warn() { printf '%b\n' "${Y}[!]${N} $*"; dx_raw "[!] $*"; }
err()  { printf '%b\n' "${R}[x]${N} $*"; dx_raw "[x] $*"; }
die()  { err "$*"; printf '%b\n' "${R}Tool ruk gaya.${N}"; exit 1; }
step() { printf '\n%b\n' "${W}▶ $*${N}"; }

# ---- Small helpers ----------------------------------------------------------
dx_have()  { command -v "$1" >/dev/null 2>&1; }

# Portable in-place sed (GNU + BSD/macOS dono)
dx_sed_i() {
  if sed --version >/dev/null 2>&1; then
    sed -i "$@"
  else
    sed -i '' "$@"
  fi
}
dx_ask()   { # $1=prompt  -> echoes answer
  local ans
  printf '%b' "${C}? ${N}$1 " >&2
  read -r ans
  printf '%s' "$ans"
}
dx_confirm() { # $1=prompt -> 0 yes / 1 no
  local a
  a="$(dx_ask "$1 [y/N]")"
  case "$a" in y|Y|yes|YES) return 0 ;; *) return 1 ;; esac
}
dx_sep() { printf '%b\n' "${D}────────────────────────────────────────────────────────${N}"; }
dx_pause(){ printf '%b' "${D}Enter dabao continue...${N}"; read -r _ ; }

# ---- Platform helpers -------------------------------------------------------
dx_is_termux() { [ -d "/data/data/com.termux/files/usr" ]; }

# Har platform support hai — kuch block nahi karte.
dx_require_supported() {
  : # cross-platform; platform.sh detect karta hai
}
