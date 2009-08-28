# Ensure that a non-login, non-interactive shell has a defined environment
export ZDOTDIR=${${(%):-%N}:A:h}
export skip_global_compinit=1

[[ ! -o LOGIN ]] && source "${ZDOTDIR}/.zprofile"
