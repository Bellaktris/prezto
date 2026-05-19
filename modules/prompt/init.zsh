#
# Loads prompt themes.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Load and execute the prompt theming system.
autoload -Uz promptinit && promptinit

# Load the prompt theme.
zstyle -a ':prezto:module:prompt' theme 'prompt_argv'
if [[ "$TERM" == (dumb|linux|*bsd*) ]] || (( $#prompt_argv < 1 )); then
  prompt 'off'
else
  prompt "$prompt_argv[@]"
fi
unset prompt_argv

# Generate early-display snapshot if enabled
if zstyle -t ':prezto:module:prompt' early-display \
  && [[ ! "${ZDOTDIR}"/.prompt_shot -nt "${ZDOTDIR}"/.zpreztorc ]]
then
  local prompt_name="$(prompt -c | tail -n1 | awk '{print $1;}')"
  if (( $+functions[prompt_${prompt_name}_preview] )); then
    local prompt_preview=$(eval "prompt_${prompt_name}_preview")
    prompt_preview=$(echo -ne "$prompt_preview" | tail -n1 | sed "s/command.*//")
    echo -ne "$prompt_preview\e[47m \e[0m\b" >! ${ZDOTDIR}/.prompt_shot
  fi
fi
