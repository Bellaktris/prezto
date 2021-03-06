#
# Provides Git aliases and functions.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Return if requirements are not found.
if (( ! $+commands[git] )); then
  return 1
fi

# Load dependencies.
pmodload 'helper'

# Source module files.
alias git='noglob git'
alias hg='noglob hg'

hg-diff () {
  hg diff --color=always --git $@ | diff-so-fancy | less -FR
}

source "${${(%):-%N}:h}/alias.zsh"
