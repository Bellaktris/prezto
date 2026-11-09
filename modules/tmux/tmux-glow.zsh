#!/usr/bin/env zsh
#
# Every 20 seconds sweeps a bright band right to left across the [session]
# label on the left of the status line, like Claude Code's shimmer over
# "Thinking...".
# status-left shows @glow while it is set; between sweeps it is unset and the
# plain label is back. One instance per server, its pid kept in @glow_pid.

zmodload zsh/zselect zsh/mathfunc

local pid=$(tmux show -gv @glow_pid 2>/dev/null)
[[ -n $pid ]] && kill -0 $pid 2>/dev/null && exit 0
tmux set -g @glow_pid $$

# status-style's colour136 at rest, rising to a pale gold at the band's peak.
local -a base=(175 135 0) peak=(255 240 190)
local -F width=2.5    # half-width of the band, in characters
local tick=7          # hundredths of a second per frame

function glow-frame {
  local label=$1 out= c
  local -F pos=$2 d w
  local -i i=0 r g b
  for c in ${(s::)label}; do
    d=$(( abs(i - pos) / width )); w=$(( d < 1 ? (cos(d * 3.14159) + 1) / 2 : 0 ))
    r=$(( base[1] + (peak[1] - base[1]) * w ))
    g=$(( base[2] + (peak[2] - base[2]) * w ))
    b=$(( base[3] + (peak[3] - base[3]) * w ))
    [[ $c == '#' ]] && c='##'
    out+="#[fg=$(printf '#%02x%02x%02x' $r $g $b)]$c"
    (( i++ ))
  done
  print -rn -- "$out#[default] "
}

function glow-refresh {
  local client
  for client in ${(f)"$(tmux list-clients -F '#{client_name}')"}; do
    tmux refresh-client -S -t $client 2>/dev/null
  done
}

while tmux has-session 2>/dev/null; do
  zselect -t 2000  # 20 seconds

  [[ $(tmux show -gv status) == on ]] || continue
  local -a sessions=(${(f)"$(tmux list-sessions -F '#{session_attached} #{session_name}' \
    | sed -n 's/^[1-9][0-9]* //p')"})
  (( $#sessions )) || continue

  local -i longest=0 step
  local s
  for s in $sessions; do (( $#s + 2 > longest )) && longest=$(( $#s + 2 )); done
  for (( step = longest + 3; step >= -3; step-- )); do
    for s in $sessions; do
      tmux set -t "=$s:" @glow "$(glow-frame "[$s]" $step)" 2>/dev/null
    done
    glow-refresh
    zselect -t $tick
  done
  for s in $sessions; do tmux set -u -t "=$s:" @glow 2>/dev/null; done
  glow-refresh
done
