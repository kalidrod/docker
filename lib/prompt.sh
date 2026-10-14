#!/usr/bin/env bash
# =============================================================================
#  DockerX  ·  lib/prompt.sh
#  Custom prompt — default style: @docker~#  (e.g. Hari@docker:~#)
#  Built by Alexa for Hari Jadhav Ji.
# =============================================================================

# style: docker | alexa | minimal | power | plain
dx_apply_prompt() {
  local style="${1:-${DX_PROMPT_STYLE:-docker}}"
  local rc="$HOME/.bashrc"
  touch "$rc" 2>/dev/null

  # purana block hata do
  dx_sed_i '/# >>> dockerx prompt >>>/,/# <<< dockerx prompt <<</d' "$rc" 2>/dev/null

  local ps
  case "$style" in
    docker)
      # @docker~#  ->  \u@docker:\w#  (home par '~' dikhta hai)
      ps="PS1='\[\e[1;31m\]\u\[\e[0m\]@\[\e[1;34m\]docker\[\e[0m\]:\[\e[1;32m\]\w\[\e[0m\]# '"
      ;;
    alexa)
      ps="PS1='\[\e[1;31m\]\u\[\e[0m\]@\[\e[1;34m\]docker\[\e[0m\] \[\e[1;32m\]\w\[\e[0m\]\n\[\e[1;36m\]» \[\e[0m\]'"
      ;;
    minimal)
      ps="PS1='\[\e[1;32m\]\w\[\e[0m\] \$ '"
      ;;
    power)
      ps="PS1='\[\e[1;35m\]┌─[\[\e[1;37m\]\u\[\e[1;35m\]]─[\[\e[1;33m\]\w\[\e[1;35m\]]\n└─\[\e[1;36m\]❯ \[\e[0m\]'"
      ;;
    plain|*)
      ps="PS1='\u@\h:\w\$ '"
      ;;
  esac

  {
    echo "# >>> dockerx prompt >>>"
    echo "$ps"
    echo "# <<< dockerx prompt <<<"
  } >>"$rc"

  # Current shell me turant apply (agar script sourced ho)
  if [ -n "${BASH_VERSION:-}" ]; then
    eval "$ps" 2>/dev/null || true
  fi

  ok "Prompt set (style: $style) — apne aap apply ho gaya."
}
