#!/usr/bin/env zsh
#
# The right-hand twin of tmux-glow.zsh, on its own clock: every 30 seconds,
# the first 13 seconds in (the labels' sweep runs every 20), a bright band
# sweeps right to left across the cyan readings tmux-status.sh prints. The
# readings are taken once per sweep and only the clock is redrawn as it goes.
# While a sweep runs status-right shows @glow_status; in between it is unset
# and the live #(tmux-status.sh) is back. One instance per server, its pid
# kept in @glow_status_pid.

zmodload zsh/zselect zsh/mathfunc zsh/datetime

local pid=$(tmux show -gv @glow_status_pid 2>/dev/null)
[[ -n $pid ]] && kill -0 $pid 2>/dev/null && exit 0
tmux set -g @glow_status_pid $$

# From the readings' colour at rest - bold cyan, which iTerm draws as its
# bright cyan (ANSI 14) - to a pale gold at the band's peak.
local -a base=(85 255 255) peak=(255 230 160)
local -F width=4           # half-width of the band, in characters
local tick=5               # hundredths of a second per frame
local -F period=30 delay=13   # seconds

local status_sh="${${(%):-%N}:h}/tmux-status.sh"
local value='#[fg=cyan,bright]' sep='#[fg=black] · '

# glow-frame <text> <band position> <text's column>
function glow-frame {
  local text=$1 out= c
  local -F pos=$2 d w
  local -i i=$3 r g b
  for c in ${(s::)text}; do
    d=$(( abs(i - pos) / width )); w=$(( d < 1 ? (cos(d * 3.14159) + 1) / 2 : 0 ))
    r=$(( base[1] + (peak[1] - base[1]) * w ))
    g=$(( base[2] + (peak[2] - base[2]) * w ))
    b=$(( base[3] + (peak[3] - base[3]) * w ))
    [[ $c == '#' ]] && c='##'
    out+="#[bold,fg=$(printf '#%02x%02x%02x' $r $g $b)]$c"
    (( i++ ))
  done
  print -rn -- $out
}

function glow-refresh {
  local client
  for client in ${(f)"$(tmux list-clients -F '#{client_name}')"}; do
    tmux refresh-client -S -t $client 2>/dev/null
  done
}

# Sweeps start on a fixed schedule, however long each one takes.
local -F next=$(( EPOCHREALTIME + delay ))
while tmux has-session 2>/dev/null; do
  (( next > EPOCHREALTIME )) && zselect -t $(( int((next - EPOCHREALTIME) * 100) ))
  (( next += period ))
  if [[ $(tmux show -gv status) != off ]] && tmux list-clients -F x 2>/dev/null | grep -q x; then
    # The readings between their separators; the last is the clock.
    local raw="$(zsh $status_sh)"
    local split=$sep$value
    local -a parts=("${(@ps:$split:)${raw#$value}}")
    local -a cols=() ; local -i col=0 total step k
    for k in {1..$#parts}; do cols+=$col; (( col += ${(m)#parts[k]} + 3 )); done
    (( total = col - 3 ))

    for (( step = total + width + 1; step >= -width - 1; step-- )); do
      parts[-1]=$(strftime '%a %H:%M:%S' $EPOCHSECONDS)
      local frame=
      for k in {1..$#parts}; do
        (( k > 1 )) && frame+=$sep
        frame+=$(glow-frame $parts[k] $step $cols[k])
      done
      tmux set -g @glow_status "$frame" 2>/dev/null
      glow-refresh
      zselect -t $tick
    done
    tmux set -gu @glow_status 2>/dev/null
    glow-refresh
  fi
done
