#
# Defines Docker aliases.
#
# Author:
#   François Vantomme <akarzim@gmail.com>
#

# Return if requirements are not found.
if (( ! $+commands[docker] )); then
  return 1
fi

#
# Functions
#

# Set Docker Machine environment
function dkme {
  if (( ! $+commands[docker-machine] )); then
    return 1
  fi

  eval $(docker-machine env $1)
}

# Set Docker Machine default machine
function dkmd {
  if (( ! $+commands[docker-machine] )); then
    return 1
  fi

  pushd ~/.docker/machine/machines

  if [[ ! -d $1 ]]; then
    printf "Docker machine '%s' does not exist. Abort.\n" "$1"
    popd
    return 1
  fi

  if [[ -L default ]]; then
    eval $(rm -f default)
  elif [[ -d default ]]; then
    printf 'A default machine already exists. Abort.\n'
    popd
    return 1
  elif [[ -e default ]]; then
    printf "A file named 'default' already exists. Abort.\n"
    popd
    return 1
  fi

  eval $(ln -s $1 default)
  popd
}

# Source module files.
source "${${(%):-%N}:h}/alias.zsh"
