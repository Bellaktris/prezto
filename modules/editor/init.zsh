#
# Sets key bindings.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Return if requirements are not found.
if [[ "$TERM" == 'dumb' ]]; then
  return 1
fi

zmodload zsh/regex
zmodload zsh/terminfo
zmodload zsh/complist

setopt SHORT_LOOPS

#
# Variables
#

# Parse key sequences fast
export KEYTIMEOUT=1

# Treat these characters as part of a word.
WORDCHARS='*?_-.[]~&;!#$%^(){}<>'

# Use human-friendly identifiers.
typeset -gA key_info
key_info=(
  'Control'         '\C-'
  'ControlLeft'     '\e[1;5D \e[5D \e\e[D \eOd'
  'ControlRight'    '\e[1;5C \e[5C \e\e[C \eOc'
  'ControlPageUp'   '\e[5;5~'
  'ControlPageDown' '\e[6;5~'
  'Escape'       '\e'
  'Tab'          '^I'
  'Enter'        '^M'
  'Meta'         '\M-'
  'Backspace'    "^?"
  'Delete'       '\e[3~'
  'Up'           '\e[A'
  'Left'         '\e[D'
  'Right'        '\e[C'
  'Down'         '\e[B'
  'F1'           "$terminfo[kf1]"
  'F2'           "$terminfo[kf2]"
  'F3'           "$terminfo[kf3]"
  'F4'           "$terminfo[kf4]"
  'F5'           "$terminfo[kf5]"
  'F6'           "$terminfo[kf6]"
  'F7'           "$terminfo[kf7]"
  'F8'           "$terminfo[kf8]"
  'F9'           "$terminfo[kf9]"
  'F10'          "$terminfo[kf10]"
  'F11'          "$terminfo[kf11]"
  'F12'          "$terminfo[kf12]"
  'Insert'       "$terminfo[kich1]"
  'Home'         "$terminfo[khome]"
  'PageUp'       "$terminfo[kpp]"
  'End'          "$terminfo[kend]"
  'PageDown'     "$terminfo[knp]"
  'BackTab'      "$terminfo[kcbt]"
)

# Set empty $key_info values to an invalid UTF-8 sequence to induce silent
# bindkey failure.
for key in "${(k)key_info[@]}"; do
  if [[ -z "$key_info[$key]" ]]; then
    key_info[$key]='�'
  fi
done

#
# External Editor
#

# Allow command line editing in an external editor.
autoload -Uz edit-command-line
zle -N edit-command-line

#
# Functions
#

# Runs bindkey but for all of the keymaps. Running it with no arguments will
# print out the mappings for all of the keymaps.
function bindkey-all {
  local keymap=''
  for keymap in $(bindkey -l); do
    [[ "$#" -eq 0 ]] && printf "#### %s\n" "${keymap}" 1>&2
    bindkey -M "${keymap}" "$@"
  done
}

# Exposes information about the Zsh Line Editor
# via the $editor_info associative array.
function editor-info {
  # Ensure that we're going to set the editor-info for prompts that
  # are prezto managed and/or compatible.
  if zstyle -t ':prezto:module:prompt' managed; then
    # Clean up previous $editor_info.
    unset editor_info
    typeset -gA editor_info

    if [[ "$KEYMAP" == *vicmd ]]; then
      zstyle -s ':prezto:module:editor:info:keymap:alternate' format 'REPLY'
      editor_info[keymap]="$REPLY"
    else
      zstyle -s ':prezto:module:editor:info:keymap:primary' format 'REPLY'
      editor_info[keymap]="$REPLY"

      if [[ "$ZLE_STATE" == *overwrite* ]]; then
        zstyle -s ':prezto:module:editor:info:keymap:primary:overwrite' format 'REPLY'
        editor_info[overwrite]="$REPLY"
      else
        zstyle -s ':prezto:module:editor:info:keymap:primary:insert' format 'REPLY'
        editor_info[overwrite]="$REPLY"
      fi
    fi

    unset REPLY
    zle zle-reset-prompt
  fi
}
zle -N editor-info

# Reset the prompt based on the current context and
# the ps-context option.
function zle-reset-prompt {
  if zstyle -t ':prezto:module:editor' ps-context; then
    # If we aren't within one of the specified contexts, then we want to reset
    # the prompt with the appropriate editor_info[keymap] if there is one.
    if [[ $CONTEXT != (select|cont) ]]; then
      zle reset-prompt
      zle -R
    fi
  else
    zle reset-prompt
    zle -R
  fi
}
zle -N zle-reset-prompt

# Updates editor information when the keymap changes.
function zle-keymap-select {
  zle editor-info
}
zle -N zle-keymap-select

# Enables terminal application mode and updates editor information.
function zle-line-init {
  # The terminal must be in application mode when ZLE is active for $terminfo
  # values to be valid.
  if (( $+terminfo[smkx] )); then
    # Enable terminal application mode.
    echoti smkx
  fi

  # Update editor information.
  zle editor-info
}
zle -N zle-line-init

# Disables terminal application mode and updates editor information.
function zle-line-finish {
  # The terminal must be in application mode when ZLE is active for $terminfo
  # values to be valid.
  if (( $+terminfo[rmkx] )); then
    # Disable terminal application mode.
    echoti rmkx
  fi

  # Update editor information.
  zle editor-info
}
zle -N zle-line-finish

# Toggles emacs overwrite mode and updates editor information.
function overwrite-mode {
  zle .overwrite-mode
  zle editor-info
}
zle -N overwrite-mode

# Enters vi insert mode and updates editor information.
function vi-insert {
  zle .vi-insert
  zle editor-info
}
zle -N vi-insert

# Fix zsh wrong behavior
function vi-cmd-mode {
    zle .vi-cmd-mode
    BUFFER="$BUFFER "
    CURSOR=$(($CURSOR + 1))
}
zle -N vi-cmd-mode

# Moves to the first non-blank character then enters vi insert mode and updates
# editor information.
function vi-insert-bol {
  zle .vi-insert-bol
  zle editor-info
}
zle -N vi-insert-bol

# Enters vi replace mode and updates editor information.
function vi-replace  {
  zle .vi-replace
  zle editor-info
}
zle -N vi-replace

# Expands .... to ../..
function expand-dot-to-parent-directory-path {
  ! [[ $LBUFFER -regex-match \
        "^(\"([^\"]*)\"|'([^']*)'|[^'\"]*)*$" ]] \
    && LBUFFER+='.' && return

  if [[ $LBUFFER -regex-match "^.*\.\.$" ]]; then
    [[ $buffer_cur != "" ]] && \
      BUFFER="$buffer_cur"

    LBUFFER+='/.'
  fi

  zle self-insert
}
zle -N expand-dot-to-parent-directory-path

# Displays an indicator when completing.
function expand-or-complete-with-indicator {
  local indicator
  zstyle -s ':prezto:module:editor:info:completing' format 'indicator'

  # This is included to work around a bug in zsh which shows up when interacting
  # with multi-line prompts.
  if [[ -z "$indicator" ]]; then
    zle expand-or-complete
    return
  fi

  print -Pn "$indicator"
  zle expand-or-complete
  zle redisplay
}
zle -N expand-or-complete-with-indicator

# Inserts 'sudo ' at the beginning of the line.
function prepend-sudo {
  if [[ "$BUFFER" != su(do|)\ * ]]; then
    BUFFER="sudo $BUFFER"
    (( CURSOR += 5 ))
  fi
}
zle -N prepend-sudo

# Expand aliases
function glob-alias {
  zle _expand_alias
  zle expand-word
  zle magic-space
}
zle -N glob-alias

# Visual mode.
source "${${(%):-%N}:h}/external/visual-mode/zsh-vimode-visual.zsh"

# Correct v in visual mode
bindkey -sM vivis 'v' "\e"

set-x-clipboard() {}

# Toggle the comment character at the start of the line. This is meant to work
# around a buggy implementation of pound-insert in zsh.
#
# This is currently only used for the emacs keys because vi-pound-insert has
# been reported to work properly.
function pound-toggle {
  if [[ "$BUFFER" = '#'* ]]; then
    # Because of an oddity in how zsh handles the cursor when the buffer size
    # changes, we need to make this check before we modify the buffer and let
    # zsh handle moving the cursor back if it's past the end of the line.
    if [[ $CURSOR != $#BUFFER ]]; then
      (( CURSOR -= 1 ))
    fi
    BUFFER="${BUFFER:1}"
  else
    BUFFER="#$BUFFER"
    (( CURSOR += 1 ))
  fi
}
zle -N pound-toggle

#
# Emacs Key Bindings
#

for key in "$key_info[Escape]"{B,b} "${(s: :)key_info[ControlLeft]}" \
  "${key_info[Escape]}${key_info[Left]}"
  bindkey -M emacs "$key" emacs-backward-word
for key in "$key_info[Escape]"{F,f} "${(s: :)key_info[ControlRight]}" \
  "${key_info[Escape]}${key_info[Right]}"
  bindkey -M emacs "$key" emacs-forward-word

# Kill to the beginning of the line.
for key in "$key_info[Escape]"{K,k}
  bindkey -M emacs "$key" backward-kill-line

# Redo.
bindkey -M emacs "$key_info[Escape]_" redo

# Search previous character.
bindkey -M emacs "$key_info[Control]X$key_info[Control]B" vi-find-prev-char

# Match bracket.
bindkey -M emacs "$key_info[Control]X$key_info[Control]]" vi-match-bracket

# Edit command in an external editor.
bindkey -M emacs "$key_info[Control]X$key_info[Control]E" edit-command-line

if (( $+widgets[history-incremental-pattern-search-backward] )); then
  bindkey -M emacs "$key_info[Control]R" \
    history-incremental-pattern-search-backward
  bindkey -M emacs "$key_info[Control]S" \
    history-incremental-pattern-search-forward
fi

# Toggle comment at the start of the line. Note that we use pound-toggle which
# is similar to pount insert, but meant to work around some issues that were
# being seen in iTerm.
bindkey -M emacs "$key_info[Escape];" pound-toggle


#
# Vi Key Bindings
#

# Edit command in an external editor.
bindkey -M vicmd "V" edit-command-line

# Undo/Redo
bindkey -M vicmd "u" undo
bindkey -M viins "$key_info[Control]_" undo
bindkey -M vicmd "$key_info[Control]R" redo

if ! (( $+widgets[history-incremental-pattern-search-backward] )) \
  || ! zstyle -t ':prezto:module:editor' pattern-search
then
  bindkey -M vicmd "?" history-incremental-search-backward
  bindkey -M vicmd "/" history-incremental-search-forward
else
  bindkey -M vicmd "?" history-incremental-pattern-search-backward
  bindkey -M vicmd "/" history-incremental-pattern-search-forward
fi

# Toggle comment at the start of the line.
bindkey -M vicmd "#" vi-pound-insert

#
# Emacs and Vi Key Bindings
#

# Unbound  keys in  vicmd and  viins mode  will cause
# really odd things  to happen such as  the casing of
# all the characters you have typed changing or other
# undefined things. In emacs  mode they just insert a
# tilde, but bind these keys  in the main keymap to a
# noop op so if there is no keybind in the users mode
# it will fall back and do nothing.

function _prezto-zle-noop {  ; }

zle -N _prezto-zle-noop

local -a unbound_keys

unbound_keys=(
  "${key_info[F1]}"
  "${key_info[F2]}"
  "${key_info[F3]}"
  "${key_info[F4]}"
  "${key_info[F5]}"
  "${key_info[F6]}"
  "${key_info[F7]}"
  "${key_info[F8]}"
  "${key_info[F9]}"
  "${key_info[F10]}"
  "${key_info[F11]}"
  "${key_info[F12]}"
  "${key_info[PageUp]}"
  "${key_info[PageDown]}"
  "${key_info[ControlPageUp]}"
  "${key_info[ControlPageDown]}"
)

for keymap in $unbound_keys; do
  bindkey -M viins "${keymap}" _prezto-zle-noop
  bindkey -M vicmd "${keymap}" _prezto-zle-noop
done

# Keybinds for all keymaps
for keymap in 'emacs' 'viins' 'vicmd'; do
  bindkey -M "$keymap" "$key_info[Home]" beginning-of-line
  bindkey -M "$keymap" "$key_info[End]" end-of-line
done

# Ctrl + Left and Ctrl + Right bindings to forward/backward word
for keymap in viins vicmd; do
  # Ctrl + Left and Ctrl + Right bindings to forward/backward word
  for key in "${(s: :)key_info[ControlLeft]}"
    bindkey -M "$keymap" "$key" vi-backward-word
  for key in "${(s: :)key_info[ControlRight]}"
    bindkey -M "$keymap" "$key" vi-forward-word
done

# Keybinds for emacs and vi insert mode
for keymap in 'emacs' 'viins'; do
  bindkey -M "$keymap" "$key_info[Insert]" overwrite-mode
  bindkey -M "$keymap" "$key_info[Delete]" delete-char
  bindkey -M "$keymap" "$key_info[Backspace]" backward-delete-char

  bindkey -M "$keymap" "$key_info[Left]" backward-char
  bindkey -M "$keymap" "$key_info[Right]" forward-char

  # [Space|Enter]+AnyModifier support
  bindkey -sM "$keymap" "\e[13;2u" "$key_info[Enter]"
  bindkey -sM "$keymap" "\e[13;5u" "$key_info[Enter]"
  bindkey -sM "$keymap" "\e[13;6u" "$key_info[Enter]"

  bindkey -sM "$keymap" "\e[32;2u" " "
  bindkey -sM "$keymap" "\e[32;5u" " "
  bindkey -sM "$keymap" "\e[32;6u" " "
  bindkey -sM "$keymap" "^@" " "

  # Expand history on space.
  bindkey -M "$keymap" ' ' magic-space

  # Clear screen.
  bindkey -M "$keymap" "$key_info[Control]L" clear-screen

  # Expand command name to full path.
  for key in "$key_info[Escape]"{E,e}
    bindkey -M "$keymap" "$key" expand-cmd-path

  # Duplicate the previous word.
  for key in "$key_info[Escape]"{M,m}
    bindkey -M "$keymap" "$key" copy-prev-shell-word

  # Use a more flexible push-line.
  for key in "$key_info[Control]Q" "$key_info[Escape]"{q,Q}
    bindkey -M "$keymap" "$key" push-line-or-edit

  # Bind Shift + Tab to go to the previous menu item.
  bindkey -M "$keymap" "$key_info[BackTab]" reverse-menu-complete

  # Complete in the middle of word.
  bindkey -M "$keymap" "$key_info[Control]I" expand-or-complete

  # Expand .... to ../..
  if zstyle -t ':prezto:module:editor' dot-expansion; then
    bindkey -M "$keymap" "." expand-dot-to-parent-directory-path
  fi

  # Make <c-z><c-z> send current job to background
  zstyle -t ':prezto:module:editor' double-ctrl-z 'yes' \
    &&  bindkey -M "$keymap" "$key_info[Control]Z" double-ctrl-z

  # Display an indicator when completing.
  bindkey -M "$keymap" "$key_info[Control]I" \
    expand-or-complete-with-indicator

  # Insert 'sudo ' at the beginning of the line.
  bindkey -M "$keymap" "$key_info[Control]X$key_info[Control]S" prepend-sudo

  # control-space expands all aliases, including global
  bindkey -M "$keymap" "$key_info[Control] " glob-alias
done

# Delete key deletes character in vimcmd cmd mode instead of weird default functionality
bindkey -M vicmd "$key_info[Delete]" delete-char


#
# Fixes
#

# Do not expand .... to ../.. during incremental search.
if zstyle -t ':prezto:module:editor' dot-expansion; then
  bindkey -M isearch . self-insert 2> /dev/null
fi

# Accept search with Enter
bindkey -M isearch "$key_info[Enter]" accept-search

# Make search more consistent with classic vim
function zle-isearch-exit() {
    [[ -n "$LASTSEARCH" ]] || return 0

    local left=$(( $CURSOR + 1))
    local right=$(( $left + $#LASTSEARCH - 1))

    [[ "$LASTSEARCH" != "$BUFFER[$left, $right]" ]] \
      && (( CURSOR -= $#LASTSEARCH )); return 0
}

zle -N zle-isearch-exit

function vi-add-next2() {
    zle vi-add-next
    [[ "$CURSOR" == "${#BUFFER}" ]] \
      && BUFFER="$BUFFER " \
      && CURSOR=$(($CURSOR + 1))
}

zle -N vi-add-next2
bindkey -M vicmd "a" vi-add-next2

# Use escape to leave menuselecting mode
change-to-vicmd() { zle -K vicmd; (( --CURSOR )) } && zle -N change-to-vicmd
bindkey -M menuselect "$key_info[Escape]" change-to-vicmd

#
# Miscelaneous
#


function double-ctrl-z ()
  { [[ $#BUFFER -ne 0 ]] && zle push-input || { bg; zle redisplay; } }

zle -N double-ctrl-z


#
# Layout
#

# Set the key layout.
zstyle -s ':prezto:module:editor' key-bindings 'key_bindings'
if [[ "$key_bindings" == emacs ]]; then
  bindkey -e
elif [[ "$key_bindings" == (vi|) ]]; then
  bindkey -v
else
  print "prezto: editor: invalid key bindings: $key_bindings" >&2
fi

unset key{,map,_bindings}
