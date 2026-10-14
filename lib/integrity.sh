#!/usr/bin/env bash
# =============================================================================
#  DockerX  ·  lib/integrity.sh
#  Owner + Banner LOCK. Koi bhi inhe badle -> tool chalne se inkaar karta hai.
#  Built by Alexa for Hari Jadhav Ji.
# =============================================================================

# Owner ki expected identity + sha256 fingerprint (hard-coded)
DX_OWNER_EXPECTED="Hari Jadhav Ji"
DX_OWNER_HASH="5039fba060770c8fc81d2d882631834253a7efb330acddafa5c728dd4a477d0e"

# Banner me ye strings HAMESHA hone chahiye (koi badal na sake)
DX_BANNER_LOCK_1="D O C K E R X"
DX_BANNER_LOCK_2="Hari Jadhav Ji"
DX_BANNER_LOCK_3="ur_.krishn._02"
DX_BANNER_LOCK_4="nullkrishn"
DX_BANNER_LOCK_5="nullkrishn3"
DX_BANNER_LOCK_6="Alexa"

dx_owner_hash() { # $1=string -> sha256 (portable: Linux + macOS)
  if dx_have sha256sum; then
    printf '%s' "$1" | sha256sum 2>/dev/null | awk '{print $1}'
  elif dx_have shasum; then
    printf '%s' "$1" | shasum -a 256 2>/dev/null | awk '{print $1}'
  elif dx_have openssl; then
    printf '%s' "$1" | openssl dgst -sha256 2>/dev/null | awk '{print $NF}'
  else
    printf '%s' "$1" | cksum 2>/dev/null | awk '{print $1}'
  fi
}

dx_integrity_fail() {
  printf '%b\n' "${R}"
  cat <<'EOF'
   ╔════════════════════════════════════════════════════════════╗
   ║                                                            ║
   ║        ⚠   I N T E G R I T Y   F A I L U R E   ⚠           ║
   ║                                                            ║
   ║   Owner / Banner ke saath chhedkhani detect hui hai.       ║
   ║   Owner naam ya banner badla gaya hai.                     ║
   ║                                                            ║
   ║   DockerX aise tool ke saath kaam karne se inkaar karta    ║
   ║   hai.  Tool ab BAND ho raha hai.                          ║
   ║                                                            ║
   ║   Owner : Hari Jadhav Ji                                   ║
   ║   Built by : Alexa                                         ║
   ║                                                            ║
   ╚════════════════════════════════════════════════════════════╝
EOF
  printf '%b\n' "${N}"
  exit 99
}

# ---- Owner verify -----------------------------------------------------------
dx_verify_owner() {
  local name hash cfg
  name="$DX_OWNER_EXPECTED"
  if [ -f "$DX_OWNER_CONF" ]; then
    cfg="$(grep -m1 '^OWNER_NAME=' "$DX_OWNER_CONF" 2>/dev/null | cut -d= -f2-)"
    [ -n "$cfg" ] && name="$cfg"
  fi
  hash="$(dx_owner_hash "$name")"
  if [ "$name" != "$DX_OWNER_EXPECTED" ] || [ "$hash" != "$DX_OWNER_HASH" ]; then
    dx_integrity_fail
  fi
}

# ---- Banner verify ----------------------------------------------------------
dx_verify_banner() {
  local f="$DX_HOME/lib/banner.sh"
  [ -f "$f" ] || return 0
  local s
  for s in "$DX_BANNER_LOCK_1" "$DX_BANNER_LOCK_2" "$DX_BANNER_LOCK_3" \
           "$DX_BANNER_LOCK_4" "$DX_BANNER_LOCK_5" "$DX_BANNER_LOCK_6"; do
    grep -qF -- "$s" "$f" || dx_integrity_fail
  done
}

# ---- Dono check (har command ise call karta hai) ----------------------------
dx_verify_integrity() {
  dx_verify_owner
  dx_verify_banner
}

# ---- owner.conf likho -------------------------------------------------------
dx_write_owner_conf() {
  cat > "$DX_OWNER_CONF" <<EOF
# DockerX owner identity — ISE BADLNA MANA HAI.
# Badalne par tool khud ko band kar dega (integrity failure).
OWNER_NAME=$DX_OWNER_EXPECTED
OWNER_HASH=$DX_OWNER_HASH
OWNER_INSTAGRAM=ur_.krishn._02
OWNER_TELEGRAM=nullkrishn
OWNER_GITHUB=nullkrishn3
BUILT_BY=Alexa
EOF
}
