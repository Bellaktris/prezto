#
# Defines tmux aliases and provides for auto launching it at start-up.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#   Colin Hebert <hebert.colin@gmail.com>
#   Georges Discry <georges@discry.be>
#   Xavier Cambar <xcambar@gmail.com>
#

# Return if requirements are not found.
(( ! $+commands[tmux] )) && return 1

#
# Auto Start
#

export TMUX_TMPDIR="/tmp"

if ([[ "$TERM_PROGRAM" = 'iTerm.app' ]] && \
  zstyle -t ':prezto:module:tmux:iterm' integrate \
); then
  _tmux_iterm_integration='-CC'
fi

if [[ -z "$TMUX" && -z "$INSIDE_EMACS" && -z "$VIM" \
   && -z "$EMACS" && ! $TERM =~ screen\\* ]] && ( \
  ( [[ -n "$SSH_TTY" ]] && zstyle -t ':prezto:module:tmux:auto-start' remote ) ||
  ( [[ -z "$SSH_TTY" ]] && zstyle -t ':prezto:module:tmux:auto-start' local ) \
); then
  local xterm="$TERM"

  tmux start-server

  if [[ -n "$SSH_TTY" ]]
  then
       tmux new-session -d -s "nicky" &>/dev/null
  else
       tmux new-session -d -s "nicky" &>/dev/null \
    || tmux new-session -d -s "lina"  &>/dev/null \
    || tmux new-session -d -s "julie" &>/dev/null \
    || tmux new-session -d -s "barsa" &>/dev/null \
    || tmux new-session -d -s # numbered no-name sessions
  fi  # [[ -n "$SSH_TTY" ]]

  tmux setenv ENABLE_FORTUNE 'yes'

  if ! [[ "$xterm" =~ ^(dumb|linux|\\*bsd\\*|eterm\\*)$ ]]
  then
    if [[ -z "$SSH_TTY" ]]
    then
      tmux set status on
    else
      tmux set status off
    fi  # [[ -z "$SSH_TTY" ]]
  else
    tmux set status off
  fi  # ! [[ "$TERM" =~ ^(dumb|linux|\\*bsd\\*|eterm\\*)$ ]]

  source "${${(%):-%N}:h}/tmux-options.zsh" 2>/dev/null
  # Load plugins
  local plug_dir="${${(%):-%N}:h}/external"
  /usr/bin/env sh -c "${plug_dir}/tmux-yank/yank.tmux" &>/dev/null

  # Attach to the starting session or to the last session used.
  exec tmux $_tmux_iterm_integration attach-session && exit 0;
fi

#
# Aliases
#

alias tmuxl='tmux list-sessions'
alias tmuxa="tmux $_tmux_iterm_integration new-session -A"

function tmuxt() {
  local query=(); [[ $# > 0 ]] && query=(-q $1)
  tmux switch-client -t $(tmux list-sessions | cut -f 1 -d ":" \
    | fzf-tmux -d 20% -- -e -i -1 \
    --bind=tab:toggle-up,btab:toggle-down $query[@]) 2>/dev/null
}

[[ -n "$TMUX" ]] && export TERM="screen-256color"

# Print welcome quote
if [[ -n "$TMUX" ]] && (( $+commands[fortune] )) && [[ -t 0 || -t 1 ]] \
  && [[ -n "$(tmux show-environment | grep ENABLE_FORTUNE)" ]]
then
  zstyle -t ':prezto:module:tmux' fortune-message 'always' \
    && { clear; fortune -as && print }

  zstyle -t ':prezto:module:tmux' fortune-message 'first-time' \
    && { tmux setenv -u ENABLE_FORTUNE; clear; fortune -as && print }
fi

# SSH/TMUX integration (a bit hacky...)
if [[ -n "$TMUX" && -n "$SSH_TTY" ]];
then
  function _tmux-preexec-hook {
    export $(tmux show-environment | grep        "^DISPLAY") &>/dev/null
    export $(tmux show-environment | grep  "^SSH_AUTH_SOCK") &>/dev/null
    export $(tmux show-environment | grep    "^SSH_ASKPASS") &>/dev/null
    export $(tmux show-environment | grep  "^SSH_AGENT_PID") &>/dev/null
    export $(tmux show-environment | grep "^SSH_CONNECTION") &>/dev/null
    export $(tmux show-environment | grep       "^WINDOWID") &>/dev/null
    export $(tmux show-environment | grep     "^XAUTHORITY") &>/dev/null
  }

  autoload -Uz add-zsh-hook
  add-zsh-hook preexec _tmux-preexec-hook
fi  #  [[ -n "$TMUX" ]]
