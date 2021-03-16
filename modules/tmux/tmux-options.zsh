# General options
tmux set visual-activity off
tmux setw monitor-activity off

tmux set mouse on
tmux set -g escape-time 0

tmux set focus-events on
tmux set bell-action none

tmux set -a terminal-overrides ',xterm-256color:RGB'
tmux set -a terminal-overrides ',xterm:RGB'
tmux set default-terminal "screen-256color"

tmux set destroy-unattached off

tmux set -g history-limit 5000

tmux set default-shell $SHELL

! (( $+commands[reattach-to-user-namespace] )) \
  && tmux set default-command $SHELL \
  || "reattach-to-user-namespace -l $SHELL"

source "${${(%):-%N}:h}"/helpers.zsh

# Vi-mode
local is_ssh_like=( 'tmux show -v "@is_ssh_like_#{pane_id}"' 'grep .')

local is_vim=( 'echo "#{pane_current_command}"' \
  'grep -iqE "(^|\/)g?(view|n?vim?x?|ssh|mosh-client)(diff)?$"' )

local is_ssh=( 'echo "#{pane_current_command}"' \
  'grep -iqE "(^|\/)g?(ssh|mosh-client)$"' )

zstyle -s ':prezto:module:editor' key-bindings 'mode'

if [[ "$mode" == (vi|) ]]; then
  tmux set-window-option -g mode-keys vi

  tmux bind-key , new-window

  local table_opt='-t' vi_copy='vi-copy' \
    send_keys='' send_keys_opt=''

  tmux_is_at_least_v 2.4 && table_opt="-T"
  tmux_is_at_least_v 2.4 && vi_copy="copy-mode-vi"

  tmux_is_at_least_v 2.4 && send_keys_opt="-X"
  tmux_is_at_least_v 2.4 && send_keys="send-keys"

  tmux unbind-key ${table_opt} ${vi_copy} v

  tmux bind-key ${table_opt} ${vi_copy}  'v' \
    ${send_keys} ${send_keys_opt} begin-selection

  # tmux bind-key ${table_opt} ${vi_copy} 'C-q' \
  #   ${send_keys} ${send_keys_opt} rectangle-toggle \\\; \
  #   ${send_keys} ${send_keys_opt} begin-selection

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

  unset {table,send_keys}_opt vi_copy \
    send_keys is_{ssh,ssh_like,vim}
fi

# Separators
tmux set pane-border-fg colour240
tmux set pane-active-border-fg colour240

# Tmux status line
tmux set renumber-windows on
tmux set-window-option -g automatic-rename

tmux set status-right-length 140
{ tmux set base-index 1; tmux movew; }

tmux set status-right "#(${${(%):-%N}:h}/tmux-status.sh)"

tmux set status-bg default
tmux set status-fg colour136

tmux set-window-option -g window-status-fg colour244
tmux set-window-option -g window-status-bg default
tmux set-window-option -g window-status-current-fg colour166
tmux set-window-option -g window-status-current-bg default
