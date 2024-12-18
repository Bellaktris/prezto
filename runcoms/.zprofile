# Language
export LC_ALL='en_US.UTF-8'
export LANG="$LC_ALL"
export LANGUAGE="$LC_ALL"


# Paths


# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path

# Set the list of directories that Zsh searches for programs.
path=( $HOME/{,.local/}bin {/usr/local,/usr,}/{sbin,bin} /usr/games )

# Set the list of directories that Zsh searches for man paths.
manpath=( $HOME/.local/share/man /usr/{local,share,}/man )


# Colors
export COLORTERM=truecolor
export TERM='xterm-256color'


# Temporary Files
[[ ! -d "$TMPDIR" ]]               \
  && export TMPDIR="/tmp/zsh-$UID" \
  && mkdir "$TMPDIR" &>/dev/null   \
  && chmod 700 "$TMPDIR"

export TMPPREFIX="${TMPDIR%/}/zsh"


# Editors
export PAGER='less'

if command -v nvim &>/dev/null; then
  export EDITOR="nvim"
  export VISUAL="nvim"
fi


# Python
export PYTHONSTARTUP="$HOME/.pythonrc"
export PYTHONPATH="$HOME/.local/lib/python/"
export PYLINTHOME="$TMPDIR/pylint.d"


# Fzf
manpath=( $HOME/.fzf/man $manpath )
   path=( $HOME/.fzf/bin $path )


# Git
export GIT_CEILING_DIRECTORIES="$HOME"


# Brew
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ANALYTICS=1

if [[ "$OSTYPE" == darwin* ]]
then
  [[ -d $HOME/homebrew   ]] && path=( $HOME/homebrew/bin $path )
  path=( $(brew --prefix coreutils)/libexec/gnubin $path ) 2>/dev/null

  export BREW_PREFIX="$(brew --prefix)"
else
  export BREW_PREFIX="$HOME/.linuxbrew"
  [[ -d $HOME/.linuxbrew ]] && path=( $HOME/.linuxbrew/bin $path )
fi  # [[ "$OSTYPE" == darwin* ]]


# Less
# Set the default Less options.
export LESS='-g -i -M -R -S -w -z-4'

# Set the Less input preprocessor.
# Try both `lesspipe` and `lesspipe.sh` as either might exist on a system.
if (( $#commands[(i)lesspipe(|.sh)] )); then
  export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
fi


# Source machine local environment
source "${${(%):-%N}:h}"/.zprofile-local 2>/dev/null
# vim: filetype=zsh: foldmarker={{{,}}}: foldenable
