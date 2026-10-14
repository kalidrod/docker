#!/usr/bin/env bash
# =============================================================================
#  DockerX  ·  lib/platform.sh
#  Platform detect: termux (Android) | linux | wsl (Windows) | macos | unknown
#  Built by Alexa for Hari Jadhav Ji.
# =============================================================================

DX_PLATFORM=""
DX_SUDO=""

dx_detect_platform() {
  if [ -d "/data/data/com.termux/files/usr" ]; then
    DX_PLATFORM="termux"
  elif grep -qiE "microsoft|wsl" /proc/version 2>/dev/null; then
    DX_PLATFORM="wsl"
  elif [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
    DX_PLATFORM="macos"
  elif [ "$(uname -s 2>/dev/null)" = "Linux" ]; then
    DX_PLATFORM="linux"
  elif [ -n "${WINDIR:-}" ] || uname -s 2>/dev/null | grep -qiE "mingw|msys|cygwin"; then
    DX_PLATFORM="windows"
  else
    DX_PLATFORM="unknown"
  fi
}

dx_set_sudo() {
  if [ "$(id -u 2>/dev/null)" = "0" ]; then
    DX_SUDO=""
  elif dx_have sudo; then
    DX_SUDO="sudo"
  else
    DX_SUDO=""
  fi
}

dx_platform_name() {
  case "${DX_PLATFORM:-}" in
    termux)  printf 'Termux / Android' ;;
    linux)   printf 'Linux' ;;
    wsl)     printf 'Windows (WSL)' ;;
    macos)   printf 'macOS' ;;
    windows) printf 'Windows' ;;
    *)       printf 'Unknown' ;;
  esac
}

# Launcher install dir per platform
dx_launcher_dir() {
  case "${DX_PLATFORM:-}" in
    termux) printf '/data/data/com.termux/files/usr/bin' ;;
    macos)  printf '/usr/local/bin' ;;
    *)
      if [ -w /usr/local/bin ] 2>/dev/null; then
        printf '/usr/local/bin'
      else
        printf '%s/.local/bin' "$HOME"
      fi
      ;;
  esac
}

# Is apt available? (Ubuntu / Debian / Parrot / Kali / Mint / WSL)
dx_is_apt() { dx_have apt-get; }
