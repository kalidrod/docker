#!/usr/bin/env bash
# =============================================================================
#  DockerX  ·  scripts/setup.sh   (cross-platform)
#  Poora setup — ek hi baar. Termux / Linux / WSL / macOS sab me chalta hai.
# =============================================================================
DX_HOME="${DX_HOME:-$HOME/.dockerx}"
. "$DX_HOME/lib/common.sh"
. "$DX_HOME/lib/banner.sh"
. "$DX_HOME/lib/integrity.sh"
. "$DX_HOME/lib/platform.sh"
. "$DX_HOME/lib/engine.sh"
. "$DX_HOME/lib/prompt.sh"

dx_detect_platform
dx_set_sudo
dx_banner
printf '%b\n' "  ${D}Platform: $(dx_platform_name)${N}"
echo

# settings load
[ -f "$DX_CONFIG" ] && . "$DX_CONFIG"

# owner + banner integrity (tamper par refuse)
dx_write_owner_conf
dx_verify_integrity

# ---- Engine install (platform ke hisaab se) ---------------------------------
dx_install_all

# ---- Launcher install -------------------------------------------------------
LADIR="$(dx_launcher_dir)"
LAUNCH="${DX_LAUNCHER:-dockerx}"
mkdir -p "$LADIR" 2>/dev/null
if [ -f "$DX_HOME/bin/dockerx" ]; then
  if cp "$DX_HOME/bin/dockerx" "$LADIR/$LAUNCH" 2>/dev/null; then
    case "$DX_PLATFORM" in
      termux) dx_sed_i "1s|.*|#!/data/data/com.termux/files/usr/bin/bash|" "$LADIR/$LAUNCH" ;;
      *)      dx_sed_i "1s|.*|#!/usr/bin/env bash|" "$LADIR/$LAUNCH" ;;
    esac
    chmod +x "$LADIR/$LAUNCH" 2>/dev/null
    ok "Launcher ready: $LAUNCH  ($LADIR)"
  else
    warn "Launcher copy fail — manually chalao: bash $DX_HOME/bin/dockerx"
  fi
fi

# ---- docker wrapper: Termux me 'docker ...' bhi kaam kare -------------------
if [ -f "$LADIR/docker" ] && ! grep -q "DockerX: docker wrapper" "$LADIR/docker" 2>/dev/null; then
  warn "'docker' pehle se maujood hai — wrapper skip kiya (conflict avoid)."
else
  cat > "$LADIR/docker" <<'WRAP'
#!/usr/bin/env bash
# DockerX: docker wrapper — Termux me docker command ko rootfs me forward karta hai
DX_HOME="${DX_HOME:-$HOME/.dockerx}"
exec bash "$DX_HOME/scripts/docker-passthrough.sh" "$@"
WRAP
  case "$DX_PLATFORM" in
    termux) dx_sed_i "1s|.*|#!/data/data/com.termux/files/usr/bin/bash|" "$LADIR/docker" ;;
  esac
  chmod +x "$LADIR/docker" 2>/dev/null
  ok "docker wrapper ready — ab Termux me 'docker ps' bhi chalega"
fi

# ---- Prompt ----------------------------------------------------------------
dx_apply_prompt "${DX_PROMPT_STYLE:-docker}"

echo
ok "════════════════════════════════════════════════"
ok "  SETUP COMPLETE  ·  DockerX ready hai bhai"
ok "════════════════════════════════════════════════"
echo
printf '%b\n' "${W}Platform:${N} $(dx_platform_name)"
printf '%b\n' "${W}Ab ye commands use karo:${N}"
printf '%b\n' "  ${G}dockerx start${N}                     Docker daemon start"
printf '%b\n' "  ${G}dockerx run hello-world${N}           test"
printf '%b\n' "  ${G}dockerx ps${N}                        containers dekho"
printf '%b\n' "  ${G}dockerx shell${N}                     shell"
printf '%b\n' "  ${G}dockerx menu${N}                      full menu"
printf '%b\n' "  ${G}dockerx doctor${N}                    problem check"
printf '%b\n' "  ${G}dockerx stop${N}                      daemon band"
echo
case "$DX_PLATFORM" in
  termux)
    warn "Agar 'dockerx start' par dockerd fail ho, to aapke phone kernel me"
    warn "cgroup support nahi hai — ye device limit hai. 'dockerx doctor' chalao." ;;
  linux|wsl)
    warn "Agar 'dockerx start' par daemon na chale, to sudo zaroori ho sakta hai."
    warn "'dockerx doctor' chalao." ;;
  macos)
    warn "macOS par Docker Desktop app chalu honi chahiye." ;;
  *)
    warn "Windows par Docker Desktop ya WSL2 use karo." ;;
esac
echo
