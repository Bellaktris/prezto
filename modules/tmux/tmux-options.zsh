# General options
tmux set -ga terminal-features ',xterm-256color:RGB'
tmux set -ga terminal-features ',xterm:RGB'
tmux set -g default-terminal "tmux-256color"

tmux set destroy-unattached off

tmux set -g history-limit 50000

tmux set default-shell $SHELL

tmux setw monitor-activity off
tmux set visual-activity off

tmux set -g escape-time 0
tmux set mouse on

tmux set bell-action none
tmux set focus-events on

tmux set default-command $SHELL

source "${${(%):-%N}:h}"/helpers.zsh

# Vi-mode
local is_ssh_like=( 'tmux show -v "@is_ssh_like_#{pane_id}"' 'grep .')

local is_vim=( 'echo "#{pane_current_command}"' \
  'grep -iqE "(^|\/)g?(view|n?vim?x?|ssh|mosh-client|dev)(diff)?$"' )

local is_ssh=( 'echo "#{pane_current_command}"' \
  'grep -iqE "(^|\/)g?(ssh|mosh-client|dev)$"' )

zstyle -s ':prezto:module:editor' key-bindings 'mode'

if [[ "$mode" == (vi|) ]]; then
  tmux set-window-option -g mode-keys vi

  tmux bind-key , new-window

  tmux unbind-key -T copy-mode-vi v

  tmux bind-key -T copy-mode-vi 'v' \
    send-keys -X begin-selection

  # rectangle-toggle on its own does not start a selection.
  tmux bind-key -T copy-mode-vi 'C-v' \
    'send-keys -X begin-selection; send-keys -X rectangle-on'

  # Escape drops the selection if there is one, and otherwise leaves copy
  # mode, the way vim returns to normal mode and then does nothing.
  # rectangle-off is needed because clear-selection keeps the block flag,
  # which would make the next v rectangular. selection_active rather than
  # selection_present: the latter only becomes true once the cursor has moved
  # away from the anchor.
  tmux bind-key -T copy-mode-vi 'Escape' if-shell -F '#{selection_active}' \
    'send-keys -X clear-selection; send-keys -X rectangle-off' \
    'send-keys -X cancel'

  # extended-keys always makes the terminal report ctrl-[ as a CSI u sequence,
  # which tmux decodes to a C-[ key that is distinct from Escape rather than
  # to the bare 0x1b the two would otherwise share. Without its own binding it
  # is simply dropped, so re-dispatch it through the Escape binding above.
  tmux bind-key -T copy-mode-vi 'C-[' send-keys Escape

  tmux bind -n C-h if-shell "${(j: | :)is_vim} || ${(j: | :)is_ssh_like}" \
    "send-keys C-h" "select-pane -L"

  tmux bind -n C-j if-shell "${(j: | :)is_vim} || ${(j: | :)is_ssh_like}" \
    "send-keys C-j" "select-pane -D"

  tmux bind -n C-k if-shell "${(j: | :)is_vim} || ${(j: | :)is_ssh_like}" \
    "send-keys C-k" "select-pane -U"

  tmux bind -n C-l if-shell "${(j: | :)is_vim} || ${(j: | :)is_ssh_like}" \
    "send-keys C-l" "select-pane -R"

  tmux bind -  if-shell "${(j: | :)is_ssh} || ${(j: | :)is_ssh_like}" \
    "send-prefix; send-keys -" "split-window"

  tmux bind 0  if-shell "${(j: | :)is_ssh} || ${(j: | :)is_ssh_like}" \
    "send-prefix; send-keys 0" "split-window -h"

  tmux bind o  if-shell "${(j: | :)is_ssh} || ${(j: | :)is_ssh_like}" \
    "send-prefix; send-keys o" "resize-pane -Z"

  # Claude Code in its fullscreen renderer draws on the alternate screen, so
  # copy mode would only see the current screen; its own transcript view
  # (ctrl+o) scrolls the whole conversation with vi keys, and 'v' there opens
  # it in the editor. Pressed again over the transcript, copy mode after all -
  # see claude-scroll.sh.
  local claude_scroll="${${(%):-%N}:h}/claude-scroll.sh"
  tmux bind \[ if-shell "${(j: | :)is_ssh} || ${(j: | :)is_ssh_like}" \
    "send-prefix; send-keys [" \
    "if-shell -F '#{&&:#{==:#{pane_current_command},claude},#{alternate_on}}' 'run-shell \"$claude_scroll #{pane_id}\"' 'copy-mode -e'"

  tmux bind \] if-shell "${(j: | :)is_ssh} || ${(j: | :)is_ssh_like}" \
    "send-prefix; send-keys ]" "paste-buffer -p"

  unset is_{ssh,ssh_like,vim} claude_scroll
fi

#Yank
tmux set -g @yank_action 'copy-pipe-and-cancel'

# Separators
tmux set pane-border-style fg=colour240
tmux set pane-active-border-style fg=colour240

# Tmux status line
tmux set renumber-windows on
tmux set-window-option -g automatic-rename

tmux set status-right-length 140
{ tmux set base-index 1; tmux movew; }

# Two blank columns after it, as Claude Code leaves at the end of its own
# status line. A glow sweeps the readings every 30 seconds, on its own clock
# - see tmux-glow-status.zsh.
tmux set status-right "#{?@glow_status,#{@glow_status},#(${${(%):-%N}:h}/tmux-status.sh)}  "
tmux run-shell -b "${${(%):-%N}:h}/tmux-glow-status.zsh"

tmux set-option -g status-style bg=default,fg=colour136

# A second status row above the usual one, holding only a thin rule near the
# bottom of its cells (⎽, horizontal scan line 9), in the pane borders'
# colour. ─ sits mid-cell and ▁ is thick. Monaco-UTF8 in fonts/ is patched
# so the scan lines span the whole cell; with other fonts ⎽ may show gaps.
# Left alone where init.zsh turned the status line off.
# status-format is reset first so that sourcing this again does not copy the
# rule into the second row.
if [[ $(tmux show -v status) != off ]]; then
  tmux set -gu status-format
  tmux set -g 'status-format[1]' "$(tmux show -gv 'status-format[0]')"
  tmux set -g 'status-format[0]' '#[fg=colour240]#{R:⎽,#{client_width}}'
  tmux set status 2
fi

# Every 20 seconds a glow sweeps across the current window and session labels
# - see tmux-glow.zsh.
tmux set status-left '#{?@glow,#{@glow},[#{session_name}] }'
tmux run-shell -b "${${(%):-%N}:h}/tmux-glow.zsh"

tmux set-window-option -g window-status-style fg=colour244,bg=default
tmux set-window-option -g window-status-current-style fg=colour166,bg=default

# Brackets around the current window instead of the * and - flags, and one
# space between labels; the list shifts by the brackets' width as you switch,
# which padding the others would avoid at the cost of uneven gaps. The number
# follows the name as a subscript (zsh₂), digit by digit, in @window_number so
# that tmux-glow.zsh builds the same label. Zoom and bell get their own marks;
# the previous window is dimmed.
tmux set -g @window_number \
  '#{s/0/₀/;s/1/₁/;s/2/₂/;s/3/₃/;s/4/₄/;s/5/₅/;s/6/₆/;s/7/₇/;s/8/₈/;s/9/₉/:window_index}'
local window_label='#W#{E:@window_number}#{?window_zoomed_flag, ⤢,}#{?window_bell_flag, !,}'
tmux set-window-option -g window-status-format \
  "#{?window_last_flag,#[dim],}$window_label"
tmux set-window-option -g window-status-current-format \
  "#{?@glow_label,#{@glow_label},[$window_label]}"
unset window_label
