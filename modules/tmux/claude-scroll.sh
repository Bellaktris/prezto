#!/bin/sh
# The copy-mode key in a pane running Claude Code's fullscreen renderer. The
# first press opens Claude's transcript view (ctrl+o); pressed again while the
# transcript is showing, it enters tmux copy mode on top of it, to select and
# yank its visible text with the usual copy-mode keys.
#
# Claude's state is read off the screen: the transcript view always ends in
# this footer. Only the bottom lines are looked at, since the conversation
# above can quote the same words, while the normal view always ends in the
# prompt. Should a later version reword it, the second press falls back to
# toggling the transcript, which is harmless.
pane=$1
if tmux capture-pane -p -t "$pane" | grep -v '^[[:space:]]*$' | tail -n 2 |
        grep -q '^[[:space:]]*Showing detailed transcript ·'; then
    tmux copy-mode -e -t "$pane"
else
    tmux send-keys -t "$pane" C-o
fi
