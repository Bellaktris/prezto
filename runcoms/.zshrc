echo -ne "\e[?25l"
TRAPEXIT() { echo -ne "\e[?25h" }

local _pcached=0
if [[ $TERM_PROGRAM != "iTerm.app" ]] && \
   [[ "${ZDOTDIR}"/.prompt_shot -nt "${ZDOTDIR}"/.zpreztorc ]]; then
  echo -ne "\e7"
  cat "${ZDOTDIR}"/.prompt_shot
  _pcached=1
fi

source "${ZDOTDIR}/.zpreztorc"; source "${ZDOTDIR}/../init.zsh"

if zstyle -t ':prezto:module:prompt' theme 'sorin' \
  && [[ ! "${ZDOTDIR}"/.prompt_shot -nt "${ZDOTDIR}"/.zpreztorc ]]
then
  local prompt_name="$(prompt -c | tail -n1 | awk '{print $1;}')"
  local prompt_preview=$(eval "prompt_${prompt_name}_preview")

  prompt_preview=$(echo -ne "$prompt_preview" | tail -n1 | sed "s/command.*//")
  echo -ne "$prompt_preview\e[47m \e[0m\b" >! ${ZDOTDIR}/.prompt_shot
fi  # [[ ! "${ZDOTDIR}"/.prompt_shot -nt "${ZDOTDIR}"/.zpreztorc ]]

# Editor
bindkey -M 'vivis' '\-' vi-visual-first-non-blank &>/dev/null
bindkey -M 'vivis' '0' vi-visual-eol &>/dev/null

for keymap in 'vicmd' 'afu-vicmd'; do
  bindkey -M ${keymap} '\-' vi-beginning-of-line &>/dev/null
  bindkey -M ${keymap} '0' vi-end-of-line &>/dev/null; done;

# Source machine local options
source "${ZDOTDIR}"/.zshrc-local 2>/dev/null

# Begin synchronized output so the terminal buffers the clear + prompt
# draw as a single atomic frame (no visible blank gap).
# Restore cursor, clear the cached prompt, and defer cursor-show to
# precmd so it appears together with the real prompt.
if (( _pcached )); then
  echo -ne "\e[?2026h\e8\e[J"
fi

function _deferred_cursor_show {
  echo -ne "\e[?25h\e[?2026l"
  add-zsh-hook -d precmd _deferred_cursor_show
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _deferred_cursor_show
