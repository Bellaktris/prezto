#!/usr/bin/env zsh

local sep="#[fg=black] · #[fg=cyan,bright]"
typeset -a tmuxstatus
local plugins="${${(%):-%N}:h}/external"

{ local cmd=$HOME/.local/bin/tmux-mem-cpu-load
  local memcpu="$($cmd | cut -f 1 -d %)"
  memcpu="${${memcpu//|/▪}/\//∕}"
  tmuxstatus+=("${memcpu//MB / MB$sep}" ) }

{ local dir="${${(%):-%N}:h}/external/tmux-battery-status/scripts"
  local icon="$(sh -c ${dir}/battery_icon.sh)";

  icon=${${icon//🌖 /⇓}//🌗 /⇓}
  icon=${${icon//🌒 /⇓}//🌕 /⇓}

  # if [[ $TERM_PROGRAM != iTerm.app ]]
  #   then
      icon=${${icon[1]//❇/⚡}//🔋/}
  # fi

  local percentage="$(sh -c ${dir}/battery_percentage.sh 2>/dev/null)"
  [[ -n $percentage ]] && tmuxstatus+=( "${icon}${percentage}" ) }

tmuxstatus+=( "$(date '+%a %H:%M:%S')" )

eval "echo -n \"#[fg=cyan,bright]\${(pj:$sep:)tmuxstatus}\""
