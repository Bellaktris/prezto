#!/bin/sh
# The copy-mode key in a pane running Claude Code's fullscreen renderer. The
# first press opens Claude's transcript view (ctrl+o); pressed again while the
# transcript is showing, it enters tmux copy mode on top of it, to select and
# yank its visible text with the usual copy-mode keys. Scrolled up in the
# normal view (the mouse wheel scrolls it), copy mode starts right there too -
# ctrl+o would leave that spot for a transcript opened at the bottom.
#
# Claude's state is read off the screen: the transcript view always ends in
# this footer, and a scrolled normal view shows a "Jump to bottom" pill above
# the prompt ("N new messages" once output arrives below), followed by how to
# get back - "(click) ↓", ": fn+↓ to scroll" or a key in brackets. Only the
# bottom lines are looked at, since the conversation above can quote the same
# words. Should a later version reword them, the press falls back to toggling
# the transcript, which is harmless.
pane=$1
bottom=$(tmux capture-pane -p -t "$pane" | grep -v '^[[:space:]]*$' | tail -n 8)
if printf '%s\n' "$bottom" | tail -n 2 |
        grep -q '^[[:space:]]*Showing detailed transcript ·' ||
   printf '%s\n' "$bottom" |
        grep -Eq '(Jump to bottom|[0-9]+ new messages?)( \(|: )'; then
    tmux copy-mode -e -t "$pane"
else
    tmux send-keys -t "$pane" C-o
fi
