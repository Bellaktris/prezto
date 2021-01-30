#
# Defines general aliases and functions.
#
# Authors:
#   Robby Russell <robby@planetargon.com>
#   Suraj N. Kurapati <sunaku@gmail.com>
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Load dependencies.
pmodload 'helper' 'spectrum'

# Correct commands.
setopt CORRECT

#
# Source control helpers
#

is_git_repo() {
  local root="$(pwd -P)"

  while [[ $root && ! -d $root/.git ]]
  do; root="${root%/*}"; done

  [[ $root ]] && return 0 || return 1
}

is_hg_repo() {
  local root="$(pwd -P)"

  while [[ $root && ! -d $root/.hg ]]
  do; root="${root%/*}"; done

  [[ $root ]] && return 0 || return 1
}


#
# Aliases
#

function rm cp mv () {
    if is_git_repo; then
        git $0 "$@" &>/dev/null || command $0 "$@"
    else
      if is_hg_repo; then
        hg $0 "$@" &>/dev/null || command $0 "$@"
      else
        if zstyle -T ':prezto:module:utility' safe-ops; then
          command $0 -i "$@"
        else
          command $0 "$@"
        fi
      fi
    fi
}

# Disable correction.
alias ack='nocorrect ack'
alias cd='nocorrect cd'
alias cp='nocorrect cp'
alias ebuild='nocorrect ebuild'
alias gcc='nocorrect gcc'
alias gist='nocorrect gist'
alias grep='nocorrect grep'
alias heroku='nocorrect heroku'
alias ln='nocorrect ln'
alias man='nocorrect man'
alias mkdir='nocorrect mkdir'
alias mv='nocorrect mv'
alias mysql='nocorrect mysql'
alias rm='nocorrect rm'

(( $+commands[rg] )) \
  && alias rg='nocorrect rg --smart-case'

(( $+commands[ag] )) \
  && alias rg='nocorrect ag --smart-case'

# Disable globbing.
alias wget='noglob wget'
alias curl='noglob curl'
alias nmap='noglob nmap'

alias bower='noglob bower'
alias fc='noglob fc'
alias find='noglob find'
alias ftp='noglob ftp'
alias history='noglob history'
alias locate='noglob locate'
alias rake='noglob rake'
alias rsync='noglob noremoteglob rsync'
alias scp='noglob noremoteglob scp'
alias sftp='noglob sftp'

# Define general aliases.
alias _='sudo'
alias b='${(z)BROWSER}'

alias diffu="diff --unified"
alias e='${(z)VISUAL:-${(z)EDITOR}}'
alias mkdir="${aliases[mkdir]:-mkdir} -p"
alias p='${(z)PAGER}'
alias po='popd'
alias pu='pushd'
alias sa='alias | grep -i'
alias type='type -a'

# Safe ops. Ask the user before doing anything destructive.
alias rmi="nocorrect command rm -i"
alias mvi="nocorrect command mv -i"
alias cpi="nocorrect command cp -i"
alias lni="${aliases[ln]:-ln} -i"

if zstyle -T ':prezto:module:utility' safe-ops; then
  alias ln='lni'
fi

# ls
if is-callable 'dircolors'; then
  # GNU Core Utilities
  alias ls='ls --group-directories-first'

  if zstyle -t ':prezto:module:utility:ls' color; then
    if [[ -s "$HOME/.dir_colors" ]]; then
      eval "$(dircolors --sh "$HOME/.dir_colors")"
    else
      eval "$(dircolors --sh)"
    fi

    alias ls="${aliases[ls]:-ls} --color=auto"
  else
    alias ls="${aliases[ls]:-ls} -F"
  fi
else
  # BSD Core Utilities
  if zstyle -t ':prezto:module:utility:ls' color; then
    # Define colors for BSD ls.
    export LSCOLORS='exfxcxdxbxGxDxabagacad'

    # Define colors for the completion system.
    export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=36;01:cd=33;01:su=31;40;07:sg=36;40;07:tw=32;40;07:ow=33;40;07:'

    alias ls="${aliases[ls]:-ls} -G"
  else
    alias ls="${aliases[ls]:-ls} -F"
  fi
fi

alias l='ls -1A'         # Lists in one column, hidden files.
alias ll='ls -lh'        # Lists human readable sizes.
alias lr='ll -R'         # Lists human readable sizes, recursively.
alias la='ll -A'         # Lists human readable sizes, hidden files.
alias lm='la | "$PAGER"' # Lists human readable sizes, hidden files through pager.
alias lx='ll -XB'        # Lists sorted by extension (GNU only).
alias lk='ll -Sr'        # Lists sorted by size, largest last.
alias lt='ll -tr'        # Lists sorted by date, most recent last.
alias lc='lt -c'         # Lists sorted by date, most recent last, shows change time.
alias lu='lt -u'         # Lists sorted by date, most recent last, shows access time.
alias sl='ls'            # I often screw this up.

# This is how I use ls usually
alias ls='ls -a -h'

# Grep
if zstyle -t ':prezto:module:utility:grep' color; then
  export GREP_COLOR='37;45'           # BSD.
  export GREP_COLORS="mt=$GREP_COLOR" # GNU.

  alias grep="${aliases[grep]:-grep} --color=auto"
fi

# C++
alias gdb='gdb -quiet'

local CXX_OPTIONS='-std=c++1z -I/usr/include/eigen3'
CXX_OPTIONS="$CXX_OPTIONS -march=native -mfpmath=sse -Wall"

alias g++="g++ $CXX_OPTIONS"
alias clang++="clang++ $CXX_OPTIONS"

# Make
alias make="make -j10"

# (( $+commands[cmake] )) && \
#   cmake() {
#     local cmake_args="-DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=ON"
#
#     if [[ -f $(pwd)/CMakeCache.txt ]]; then
#       command cmake ${(s: :)cmake_args} $*
#     else
#       if [[ "$@" -regex-match " -G " ]] \
#         || ! (( $+commands[ninja] ))
#       then
#         command cmake ${(s: :)cmake_args} $*
#       else
#         command cmake ${(s: :)cmake_args} -G Ninja $*
#       fi
#     fi
#   }

# Editor
alias :wq='exit'
alias :q='exit'

command -v nvim &>/dev/null && {
  alias vim='nvim -p'
  alias  vi='nvim -p'
}

nvim () {
  # if [[ -S /tmp/nvimsocket ]] && (( $+commands[nvr] ));
  # then
  #   NVIM_LISTEN_ADDRESS=/tmp/nvimsocket nvr --remote-tab ${@}
  # else
    NVIM_LISTEN_ADDRESS=/tmp/nvimsocket command $EDITOR ${@}
  # fi  # [[ -S /tmp/nvimsocket ]] && (( $+commands[nvr] ))
}

# Video playing
(( $+commands[mpv] )) && \
  mpv() {
    if [[ "$(uname -s)" != "Linux" ]]
    then
      local mpv_opts=""
    else
      local mpv_opts="--x11-bypass-compositor=never"
    fi  # [[ "$(uname -s)" == "Linux" ]]

    if (( $+commands[xset] )); then
      xset q &>/dev/null \
        || local mpv_opts="--vo=drm $mpv_opts"
    fi  # (( $+commands[xset] ))

    if ! [[ ${@: -1} =~ ^(.*\\.vpy|.*\\.py)$ ]]; then
      command mpv ${mpv_opts} ${@}
    else
      # IFS="= "; set -- ${=@}
      zparseopts -a vs_args -D - \
        o: a: -arg+: -start: -end:

      vspipe "${vs_args[@]#=}" "${@: -1}" --y4m - \
        | command mpv "${mpv_opts[@]}" "${@:1:-1}" -
    fi
  }

hstack-mpv () {
  command mpv --lavfi-complex="[vid1][vid2]hstack=inputs=2[vo]" $1 --external-files="$2" --mute
}

# Grc
if zstyle -t ':prezto:module:utility:grc' color \
  && (( $+commands[grc] ))
then
  cmds=( cc cvs df diff dig gcc gmake ifconfig \
         last ldap make mount mtr netstat ping \
         ping6 ps traceroute traceroute6 wdiff );

  for cmd in $cmds; do
    (( $+commands[$cmd] )) && \
      alias $cmd="command grc --colour=auto $cmd"
  done

  unset cmd{s,}

  alias make="command grc --colour=auto make -j10"
  alias configure='command grc --colour=auto ./configure'
fi


# Mac OS X Everywhere
if [[ "$OSTYPE" == darwin* ]]; then
  alias o='open'
elif [[ "$OSTYPE" == cygwin* ]]; then
  alias o='cygstart'
  alias pbcopy='tee > /dev/clipboard'
  alias pbpaste='cat /dev/clipboard'
else
  alias o='xdg-open'

  if (( $+commands[xclip] )); then
    alias pbcopy='xclip -selection clipboard -in'
    alias pbpaste='xclip -selection clipboard -out'
  elif (( $+commands[xsel] )); then
    alias pbcopy='xsel --clipboard --input'
    alias pbpaste='xsel --clipboard --output'
  fi
fi

alias pbc='pbcopy'
alias pbp='pbpaste'

# File Download
if (( $+commands[curl] )); then
  alias get='curl --continue-at - --location --progress-bar --remote-name --remote-time'
elif (( $+commands[wget] )); then
  alias get='wget --continue --progress=bar --timestamping'
fi

# Resource Usage
if (( $+commands[pydf] )); then
  alias df=pydf
else
  alias df='df -kh'
fi

alias du='du -kh'

if [[ "$OSTYPE" == (darwin*|*bsd*) ]]; then
  alias topc='top -o cpu'
  alias topm='top -o vsize'
else
  alias topc='top -o %CPU'
  alias topm='top -o %MEM'
fi

# Miscellaneous

# Serves a directory via HTTP.
if (( $+commands[python3] )); then
  alias http-serve='python3 -m http.server'
else
  alias http-serve='python -m SimpleHTTPServer'
fi

# Use fzf-tmux when tmux is on
[[ -z $TMUX ]] && alias fzf='fzf-tmux'

# Use apt instead of apt-get
(( $+commands[apt] )) && alias apt-get='apt'

#
# Functions
#

# Enables globbing selectively on path arguments.
# Globbing is enabled on local paths (starting in '/' and './') and
# disabled on remote paths (containing  ':' but not starting in '/'
# and  './'). This  is  useful  for programs  that  have their  own
# globbing for remote paths. Currently, this is used by default for
# 'rsync' and 'scp'.
#
# Example:
#   - Local: '*.txt', './foo:2017*.txt', '/var/*:log.txt'
#   - Remote: user@localhost:foo/

function noremoteglob {
  local -a argo
  local cmd="$1"
  for arg in ${argv:2}; do case $arg in
    ( ./* ) argo+=( ${~arg} ) ;; # local relative, glob
    (  /* ) argo+=( ${~arg} ) ;; # local absolute, glob
    ( *:* ) argo+=( ${arg}  ) ;; # remote, noglob
    (  *  ) argo+=( ${~arg} ) ;; # default, glob
  esac; done

  command $cmd "${(@)argo}"
}

# Makes a directory and changes to it.
function mkdcd {
  [[ -n "$1" ]] && mkdir -p "$1" && builtin cd "$1"
}

# Changes to a directory and lists its contents.
function cdls {
  builtin cd "$argv[-1]" && ls "${(@)argv[1,-2]}"
}

# Pushes an entry onto the directory stack and lists its contents.
function pushdls {
  builtin pushd "$argv[-1]" && ls "${(@)argv[1,-2]}"
}

# Pops an entry off the directory stack and lists its contents.
function popdls {
  builtin popd "$argv[-1]" && ls "${(@)argv[1,-2]}"
}

# Prints columns 1 2 3 ... n.
function slit {
  awk "{ print ${(j:,:):-\$${^@}} }"
}

# Finds files and executes a command on them.
function find-exec {
  find . -type f -iname "*${1:-}*" -exec "${2:-file}" '{}' \;
}

# Displays user owned processes status.
function psu {
  ps -U "${1:-$LOGNAME}" -o 'pid,%cpu,%mem,command' "${(@)argv[2,-1]}"
}
