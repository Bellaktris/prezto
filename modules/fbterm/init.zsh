#
# Set up frame buffer support in linux ttys
#
# Authors:
#   Yury Gitman <me.gitman@gmail.com>
#

[[ "$TTY" != /dev/tty* ]]  && return 1
! [[ -c /dev/fb0 ]]        && return 1
[[ $TERM != 'linux' ]]     && return 1
(( ! $+commands[fbterm] )) && return 1

local shell=$(ls -l /proc/$$/exe)
shell=( ${(s: -> :)shell} ); shell=$shell[-1]

local cmd="$TMPDIR/fbterm-zsh.sh"
echo -e "#!/bin/sh\nTERM=fbterm $shell" >! $cmd && chmod +x $cmd

zstyle -a ':prezto:module:fbterm' backgrounds '_backgrounds'

! (( $+commands[fbi] )) && { fbterm -- $cmd && exit 0 }
! [[ -n "$_backgrounds" ]] && { fbterm -- $cmd && exit 0 }

export FBTERM_BACKGROUND_IMAGE=1
local _background="$backgrounds"

[[ -d "$_backgrounds" ]] && { files=( ~/.fbterm/*.(png|jpg) );
   _background="$(python -c "import random; A=['${(j:', ':)files}']; print(random.choice(A))")" }

unset _backgrounds; echo -ne "\e[?25l";

( sleep 0.2; cat /dev/fb0 > $TMPDIR/screen.fbimg ) \
   & fbi -t 2 -1 --noverbose -a "$_background"

cat $TMPDIR/screen.fbimg >/dev/fb0 && { fbterm -- $cmd && exit 0 }
