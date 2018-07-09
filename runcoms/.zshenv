# Ensure that a non-login, non-interactive shell has a defined environment
export ZDOTDIR=${${(%):-%N}:A:h}
export skip_global_compinit=1
[[ $- == *i* ]] && echo -ne "\e[?25l"

export OUTER_TERM=$TERM
export TERM='xterm-256color'

[[ "$SHLVL" -eq 1 && ! -o LOGIN ]] && source "${ZDOTDIR}/.zprofile"
