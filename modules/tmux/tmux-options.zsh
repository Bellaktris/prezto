# General options
tmux set -ga terminal-features ',xterm-256color:RGB'
tmux set -ga terminal-features ',xterm:RGB'
tmux set -g default-terminal "tmux-256color"

tmux set destroy-unattached off

tmux set -g history-limit 5000

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

  tmux bind \[ if-shell "${(j: | :)is_ssh} || ${(j: | :)is_ssh_like}" \
    "send-prefix; send-keys [" "copy-mode -e"

  tmux bind \] if-shell "${(j: | :)is_ssh} || ${(j: | :)is_ssh_like}" \
    "send-prefix; send-keys ]" "paste-buffer -p"

  unset is_{ssh,ssh_like,vim}
fi

#Yank
tmux set -g @yank_action 'copy-pipe'

# Separators
tmux set pane-border-style fg=colour240
tmux set pane-active-border-style fg=colour240

# Tmux status line
tmux set renumber-windows on
tmux set-window-option -g automatic-rename

tmux set status-right-length 140
{ tmux set base-index 1; tmux movew; }

tmux set status-right "#(${${(%):-%N}:h}/tmux-status.sh)"

tmux set-option -g status-style bg=default,fg=colour136

tmux set-window-option -g window-status-style fg=colour244,bg=default
tmux set-window-option -g window-status-current-style fg=colour166,bg=default
