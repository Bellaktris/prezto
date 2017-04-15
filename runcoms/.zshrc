[[ "${ZDOTDIR}"/.prompt_shot -nt "${ZDOTDIR}"/.zpreztorc ]] \
  && cat "${ZDOTDIR}"/.prompt_shot

source "${ZDOTDIR}/.zpreztorc"; source "${ZDOTDIR}/../init.zsh"

if zstyle -t ':prezto:module:prompt' theme 'sorin' \
  && [[ ! "${ZDOTDIR}"/.prompt_shot -nt "${ZDOTDIR}"/.zpreztorc ]]
then
  local prompt_name="$(prompt -c | tail -n1 | awk '{print $1;}')"
  local prompt_preview=$(eval "prompt_${prompt_name}_preview")

  prompt_preview=$(echo -ne $prompt_preview | tail -n1 | sed "s/command.*//")
  echo -ne "$prompt_preview\e[47m \e[0m\b" >! ${ZDOTDIR}/.prompt_shot
fi  # [[ ! "${ZDOTDIR}"/.prompt_shot -nt "${ZDOTDIR}"/.zpreztorc ]]

# Editor
bindkey -M 'vivis' '\-' vi-visual-first-non-blank &>/dev/null
bindkey -M 'vivis' '0' vi-visual-eol &>/dev/null

for keymap in 'vicmd' 'afu-vicmd'; do
  bindkey -M ${keymap} '\-' vi-beginning-of-line &>/dev/null
  bindkey -M ${keymap} '0' vi-end-of-line &>/dev/null; done;

# Source machine local options
source "${ZDOTDIR}"/.zshrc-local 2>/dev/null; echo -ne "\r\e[?25h"
