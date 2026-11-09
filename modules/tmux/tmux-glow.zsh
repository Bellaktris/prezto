#!/usr/bin/env zsh
#
# Every 20 seconds sweeps a bright band right to left across the current
# window's [n name] label and on through the [session] label, like Claude
# Code's shimmer over "Thinking...". While a sweep runs, status-left shows the
# session's @glow and the current window's label its @glow_label (a name of
# its own, else status-left would find the window's first); in between both
# are unset and the plain labels are back. One instance per server, its pid
# kept in @glow_pid.

zmodload zsh/zselect zsh/mathfunc

local pid=$(tmux show -gv @glow_pid 2>/dev/null)
[[ -n $pid ]] && kill -0 $pid 2>/dev/null && exit 0
tmux set -g @glow_pid $$

# Each label rises from its own colour at rest - status-style's colour136,
# window-status-current-style's colour166 - to a pale gold at the band's peak.
local -a session_rgb=(175 135 0) window_rgb=(215 95 0) peak=(255 240 190)
local -F width=2.5    # half-width of the band, in characters
local tick=5          # hundredths of a second per frame

# glow-frame <label> <band position> <label's column> <r> <g> <b>
function glow-frame {
  local label=$1 out= c
  local -F pos=$2 d w
  local -i i=$3 r g b
  local -a base=($4 $5 $6)
  for c in ${(s::)label}; do
    d=$(( abs(i - pos) / width )); w=$(( d < 1 ? (cos(d * 3.14159) + 1) / 2 : 0 ))
    r=$(( base[1] + (peak[1] - base[1]) * w ))
    g=$(( base[2] + (peak[2] - base[2]) * w ))
    b=$(( base[3] + (peak[3] - base[3]) * w ))
    [[ $c == '#' ]] && c='##'
    out+="#[fg=$(printf '#%02x%02x%02x' $r $g $b)]$c"
    (( i++ ))
  done
  print -rn -- "$out#[default]"
}

function glow-refresh {
  local client
  for client in ${(f)"$(tmux list-clients -F '#{client_name}')"}; do
    tmux refresh-client -S -t $client 2>/dev/null
  done
}

while tmux has-session 2>/dev/null; do
  zselect -t 2000  # 20 seconds

  [[ $(tmux show -gv status) == off ]] && continue
  local -a sessions=(${(f)"$(tmux list-sessions -F '#{session_attached} #{session_name}' \
    | sed -n 's/^[1-9][0-9]* //p')"})
  (( $#sessions )) || continue

  # Where each session's current window label sits: past the session label
  # and, for each window before it, its label - the bracketed form, less the
  # brackets the other windows do not have - and the one-space separator
  # (window-status-format in tmux-options.zsh).
  local marks='#{?window_zoomed_flag, ⤢,}#{?window_bell_flag, !,}'
  local -A window_id window_label window_col
  local -i last=0 col step max_left=$(tmux show -gv status-left-length)
  local s line
  for s in $sessions; do
    (( col = ${(m)#${:-[$s] }} ))
    (( col > max_left )) && col=max_left
    for line in ${(f)"$(tmux list-windows -t "=$s:" \
        -F "#{window_active}#{window_id} [#W#{E:@window_number}$marks]")"}; do
      if [[ $line == 1* ]]; then
        window_id[$s]=${${line#1}%% *} window_label[$s]=${line#* }
        break
      fi
      (( col += ${(m)#${line#* }} - 2 + 1 ))
    done
    window_col[$s]=$col
    (( col + ${(m)#window_label[$s]} > last )) && last=$(( col + ${(m)#window_label[$s]} ))
  done

  for (( step = last + 3; step >= -3; step-- )); do
    for s in $sessions; do
      tmux set -t "=$s:" @glow \
        "$(glow-frame "[$s]" $step 0 $session_rgb) " 2>/dev/null
      tmux set -w -t $window_id[$s] @glow_label \
        "$(glow-frame $window_label[$s] $step $window_col[$s] $window_rgb)" 2>/dev/null
    done
    glow-refresh
    zselect -t $tick
  done
  for s in $sessions; do
    tmux set -u -t "=$s:" @glow 2>/dev/null
    tmux set -u -w -t $window_id[$s] @glow_label 2>/dev/null
  done
  glow-refresh
done
