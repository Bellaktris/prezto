#!/usr/bin/env zsh

local sep="#[fg=black] · #[fg=cyan,bright]"
typeset -a tmuxstatus
local plugins="${${(%):-%N}:h}/external"

{ local cmd=$HOME/.local/bin/tmux-mem-cpu-load
  local memcpu="$($cmd | cut -f 1 -d %)"

  # macOS fills RAM on purpose (file cache, compressor), so used/total sits
  # near total. Count the share the kernel calls under pressure instead
  # (100 minus memorystatus_level, the free share), yellow/red at the
  # warn/critical levels.
  if [[ $OSTYPE == darwin* ]]; then
    local -a vm=( $(sysctl -n hw.memsize kern.memorystatus_level \
      kern.memorystatus_vm_pressure_level 2>/dev/null) )
    local total=$(( vm[1] / 2**30 )) color mem
    case $vm[3] in
      2) color='#[fg=yellow,bright]' ;;
      4) color='#[fg=red,bright]' ;;
    esac
    mem="${color}$(printf %.0f $(( total * (100 - vm[2]) / 100. )))/${total}GB"
    [[ -n $color ]] && mem+='#[fg=cyan,bright]'
    memcpu="$mem$sep${${memcpu#* }##[[:space:]]#}"
  fi

  memcpu="${${memcpu//|/▪}/\//∕}"
  tmuxstatus+=("${memcpu//MB / MB$sep}" ) }

{ local dir="${${(%):-%N}:h}/external/tmux-battery-status/scripts"
  local percentage="$(sh -c ${dir}/battery_percentage.sh 2>/dev/null)"
  local state="$(bash -c "source ${dir}/helpers.sh && battery_status" 2>/dev/null)"

  # Nerd Font batteries (Material Design, merged into Monaco-UTF8): one per
  # ten percent, alert below ten; charging, and a plug when on power and not
  # charging. Other terminals lack the glyphs and get plain arrows. Jobs see
  # TERM_PROGRAM=tmux, so ask tmux which terminal the clients are.
  local -a level=( $'\U000F0083' $'\U000F007A' $'\U000F007B' $'\U000F007C'
    $'\U000F007D' $'\U000F007E' $'\U000F007F' $'\U000F0080' $'\U000F0081'
    $'\U000F0082' $'\U000F0079' )
  local icon
  if [[ $(tmux list-clients -F '#{client_termtype}' 2>/dev/null) == *iTerm2* ]]; then
    case $state in
      discharging*) icon="${level[${percentage%\%} / 10 + 1]} " ;;
      charging*)    icon=$'\U000F0084 ' ;;
      *)            icon=$'\U000F06A5 ' ;;
    esac
  else
    [[ $state == discharging* ]] && icon='⇓' || icon='⚡'
  fi

  [[ -n $percentage ]] && tmuxstatus+=( "${icon}${percentage}" ) }

tmuxstatus+=( "$(date '+%a %H:%M:%S')" )

eval "echo -n \"#[fg=cyan,bright]\${(pj:$sep:)tmuxstatus}\""
