echo -ne "\e[?25l"
TRAPEXIT() { echo -ne "\e[?25h" }

# Early prompt: show cached prompt snapshot during shell init.
# Enable with: zstyle ':prezto:module:prompt' early-display 'yes'
# The snapshot is auto-generated from the active prompt theme.
local _pcached=0
if [[ $TERM_PROGRAM != "iTerm.app" ]] \
  && [[ -f "${ZDOTDIR}"/.prompt_shot ]] \
  && [[ "${ZDOTDIR}"/.prompt_shot -nt "${ZDOTDIR}"/.zpreztorc ]]; then
  echo -ne "\e7"
  cat "${ZDOTDIR}"/.prompt_shot
  _pcached=1
fi

source "${ZDOTDIR}/.zpreztorc"; source "${ZDOTDIR}/../init.zsh"

# Editor
bindkey -M 'vivis' '\-' vi-visual-first-non-blank &>/dev/null
bindkey -M 'vivis' '0' vi-visual-eol &>/dev/null

for keymap in 'vicmd' 'afu-vicmd'; do
  bindkey -M ${keymap} '\-' vi-beginning-of-line &>/dev/null
  bindkey -M ${keymap} '0' vi-end-of-line &>/dev/null; done;

# Source machine local options
source "${ZDOTDIR}"/.zshrc-local 2>/dev/null

# Transition from cached prompt to real prompt
if (( _pcached )); then
  echo -ne "\e[?2026h\e8\e[J"
fi

function _deferred_cursor_show {
  echo -ne "\e[?25h\e[?2026l"
  unfunction TRAPEXIT 2>/dev/null
  add-zsh-hook -d precmd _deferred_cursor_show
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _deferred_cursor_show
