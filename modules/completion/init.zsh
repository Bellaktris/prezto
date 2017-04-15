#
# Sets completion options.
#
# Authors:
#   Robby Russell <robby@planetargon.com>
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Return if requirements are not found.
if [[ "$TERM" == 'dumb' ]]; then
  return 1
fi

# Add zsh-completions to $fpath.
fpath=("${${(%):-%N}:h}/external/zsh-completions/src" $fpath)

# Add additional completions
fpath=("${${(%):-%N}:h}/completions" $fpath)

# Add brew completions to $fpath.
fpath+=( "${BREW_PREFIX}"/completions/zsh ) 2>/dev/null

#
# Options
#

setopt COMPLETE_IN_WORD    # Complete from both ends of a word.
setopt ALWAYS_TO_END       # Move cursor to the end of a completed word.
setopt PATH_DIRS           # Perform path search even on command names with slashes.
setopt AUTO_MENU           # Show completion menu on a successive tab press.
setopt AUTO_LIST           # Automatically list choices on ambiguous completion.
setopt AUTO_PARAM_SLASH    # If completed parameter is a directory, add a trailing slash.
setopt AUTO_REMOVE_SLASH   # Remove slash if followed with delimiter.
setopt NUMERIC_GLOB_SORT   # Sort globbing results numericaly
setopt COMPLETE_ALIASES    # Transfer completion from commands to its alises
setopt GLOB_COMPLETE       # Complete glob instead of expanding
setopt MAGIC_EQUAL_SUBST   # File completion after equal signs
setopt EXTENDED_GLOB       # Needed for file modification glob modifiers with compinit
unsetopt MENU_COMPLETE     # Do not autoselect the first completion entry.
unsetopt FLOW_CONTROL      # Disable start/stop characters in shell editor.

# Load and initialize the completion system ignoring insecure directories with a
# cache time of 20 hours, so it should almost always regenerate the first time a
# shell is opened each day.
autoload -Uz compinit

[[ -n "${ZDOTDIR:-$HOME}"/.zcompdump(Nm-20) ]] \
  && compinit -i -C || compinit -i

# autoload -U bashcompinit && bashcompinit

#
# Styles
#

# Use caching to make completion for commands such as dpkg and apt usable.
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "${TMPDIR:-$HOME}/.zcompcache"

# Case-sensitive/case-insensitive
if zstyle -t ':prezto:module:completion:*' case-sensitive; then
  zstyle ':completion:*' matcher-list ''
  setopt CASE_GLOB
else
  zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
  unsetopt CASE_GLOB
fi

# Group matches and describe.
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format " %F{green}── %d (errors: %e) ──%f"
zstyle ':completion:*:descriptions' format ' %F{yellow}── %d ──%f'
zstyle ':completion:*:messages' format ' %F{purple} ── %d ──%f'
zstyle ':completion:*:warnings' format ' %F{red}── no matches found ──%f'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' format ' %F{yellow}── %d ──%f'
zstyle ':completion:*' list-separator '│'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes

# Set up completers order
zstyle ':completion:*' completer \
  _oldlist _complete _gnu_arg_complete _list _approximate

zstyle -e ':completion:*' completer \
 'reply=(_oldlist _complete _gnu_arg_complete _list _approximate);
  (( $CURRENT <= 1 )) && reply=();
  (( $CURRENT <= 2 )) && [[ "${(j: :)words[1, $CURRENT]}" =~ "^(sudo |)[A-Za-z0-9_~./\+\-]+$" ]] \
    && reply=(_oldlist _command_complete _complete _list _approximate);'

zstyle ':completion:*:-command-:*' tag-order   \
  "suffix-aliases aliases" "functions:-non-ignored" \
  "builtins commands" reserved-words parameters _files

# Increase the number of errors based on the length of the typed word. But make
# sure to cap (at 3) the max-errors to avoid hanging.
zstyle ':completion:*:approximate:*' max-errors 1 numeric
zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3>3?3:($#PREFIX+$#SUFFIX)/3))numeric)'

# Ignore cache-files and executables
local invisible_files=( '*~' '*.swp' '__pycache__' '*.pyg'
        '*.pyc' '.DS_Store' '.DS_Store?' '.DS_Store'
        '*._' '.Trashes' 'Icon?' 'ehthumbs.db' 'Thumbs.db'
        '*.sqlite' '*.com' '*.class' '*.dll' '*.exe'
        '*.bak' '*.aux' '*.glo' '*.idx' '*.o' '*.so'
        '*.toc' '*.ist' '*.acn' '*.acr' '*.alg' '*.bbl'
        '*.blg' '*.glg' '*.gls' '*.ilg' '*.ind' '*.lof'
        '*.lot' '*.maf' '*.mtc' '*.mtc1' '*.out'
        '*.fdb_latex.mk' '*.fls'  '*.brf' '*.synctex.gz' )

for cmd in vi vim nvim emacs xemacs mpv; do
  zstyle ":completion:*:*:$cmd:*:*files" \
    ignored-patterns "(${(j:|:)invisible_files})"
done

zstyle ':completion:*:*:cd:*:*files' ignored-patterns "__pycache__"

# Array completion element sorting.
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# Directories
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories
# zstyle ':completion:*:*:cd:*:directory-stack' menu yes
zstyle ':completion:*:-tilde-:*' group-order 'named-directories' 'path-directories' 'expand'
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' squeeze-slashes true


# Files
zstyle ':completion:*' file-sort access
zstyle ':completion:*' file-list list=20 insert=10
zstyle ':completion:*:paths' accept-exact '*(N)'


# History
zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' list false
zstyle ':completion:*:history-words' menu yes

# Environmental Variables
zstyle ':completion::*:(-command-|export):*' fake-parameters ${${${_comps[(I)-value-*]#*,}%%,*}:#-*-}

# Populate hostname completion. But allow ignoring custom entries from static
# */etc/hosts* which might be uninteresting.
zstyle -a ':prezto:module:completion:*:hosts' etc-host-ignores '_etc_host_ignores'

_get_hosts='
  ${=${=${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) 2> /dev/null)"}%%[#| ]*}//\]:[0-9]*/ }//,/ }//\[/ }
  ${=${(f)"$(cat /etc/hosts(|)(N) <<(ypcat hosts 2> /dev/null))"}%%(\#${_etc_host_ignores:+|${(j:|:)~_etc_host_ignores}})*}
  ${=${${${${(@M)${(f)"$(cat ~/.ssh/config 2> /dev/null)"}:#Host *}#Host }:#*\**}:#*\?*}}
'
zstyle -e ':completion:*:hosts' hosts "reply=($_get_hosts)"
zstyle -e ':completion:*:*:ping:*:hosts'  hosts "reply=($_get_hosts ya.ru google.com 8.8.8.8 8.8.4.4)"
zstyle -e ':completion:*:*:ping6:*:hosts' hosts "reply=($_get_hosts ya.ru google.com 8.8.8.8 8.8.4.4)"

unset _get_hosts

# Don't complete uninteresting users...
# zstyle ':completion:*:*:*:users' ignored-patterns \
#   adm amanda apache avahi beaglidx bin cacti canna clamav daemon \
#   dbus distcache dovecot fax ftp games gdm gkrellmd gopher \
#   hacluster haldaemon halt hsqldb ident junkbust ldap lp mail \
#   mailman mailnull mldonkey mysql nagios \
#   named netdump news nfsnobody nobody nscd ntp nut nx openvpn \
#   operator pcap postfix postgres privoxy pulse pvm quagga radvd \
#   rpc rpcuser rpm shutdown squid sshd sync uucp vcsa xfs '_*'

zstyle ':completion:*' users

# ... unless we really want to.
zstyle '*' single-ignored show

# Ignore completion functions for commands you don't have:
zstyle ':completion::(^approximate*):*:functions' \
  ignored-patterns '*?.(zwc)' '(_|afu|zle|precmd|preexec)?*'

# Ignore multiple entries.
zstyle ':completion:*:(rm|kill|diff):*' ignore-line other
zstyle ':completion:*:rm:*' file-patterns '*:all-files'

# Kill
zstyle ':completion:*:*:*:*:processes' command 'ps -u $LOGNAME -o pid,user,command -w'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;36=0=01'
zstyle ':completion:*:*:kill:*' force-list always
zstyle ':completion:*:*:kill:*' insert-ids single

# Aptitude
zstyle ':completion:*:complete:-command-::commands' ignored-patterns '(aptitude-*|*\~)'

# Man
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true

# Media Players
zstyle ':completion:*:*:mpg123:*' file-patterns '*.(mp3|MP3):mp3\ files *(-/):directories'
zstyle ':completion:*:*:mpg321:*' file-patterns '*.(mp3|MP3):mp3\ files *(-/):directories'
zstyle ':completion:*:*:ogg123:*' file-patterns '*.(ogg|OGG|flac):ogg\ files *(-/):directories'
zstyle ':completion:*:*:mocp:*' file-patterns '*.(wav|WAV|mp3|MP3|ogg|OGG|flac):ogg\ files *(-/):directories'

# Mutt
if [[ -s "$HOME/.mutt/aliases" ]]; then
  # zstyle ':completion:*:*:mutt:*' menu yes
  zstyle ':completion:*:mutt:*' users ${${${(f)"$(<"$HOME/.mutt/aliases")"}#alias[[:space:]]}%%[[:space:]]*}
fi

# SSH/SCP/RSYNC
zstyle ':completion:*:(ssh|scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(scp|rsync):*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*' group-order users hosts-domain hosts-host users hosts-ipaddr
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'


#
# Autocompletion
#

if zstyle -t ':prezto:module:completion' autocompletion 'yes'
then
  zstyle ':auto-fu:highlight' input bold
  zstyle ':auto-fu:var' postdisplay $'\n'

  zstyle ':auto-fu:highlight' completion fg=black,bold
  zstyle ':auto-fu:highlight' completion/one fg=black,bold

  zstyle ':auto-fu:var' enable all
  zstyle ':auto-fu:var' disable magic-space

  zstyle ':auto-fu:var' autoable-function/skiplines \
    '([[:print:]]##[[:space:]]##|(#s)[[:space:]]#)(blaze|blaze64|buck|g4d|g4) ?*' \
    '([[:print:]]##[[:space:]]##|(#s)[[:space:]]#)(aptitude|apt|apt-get|yum|hg|brew|pip|pip3) [[:print:]]# ?*' \
    '([[:print:]]##[[:space:]]##|(#s)[[:space:]]#)(touch|mkdir|npm|scp|make|yarn) ?*'

  zstyle ':auto-fu:var' autoable-function/skipwords \
    '/bns/*' '/cns/*' '/cfs/*' '/bigtable/*' '/bigfile/*' '/namespace/*' '/placer/*' '/home/' '/mnt/vol/*'

  # it a hack, of course...
  source "${${(%):-%N}:h}/external/autocompletion/auto-fu" && auto-fu-install

  bindkey -M afu "$key_info[Right]" afu-cursor-right
  bindkey -M afu  "$key_info[Left]" afu-cursor-left

  # bindkey -M afu   "$key_info[Up]" afu-history-up
  # bindkey -M afu "$key_info[Down]" afu-history-down

  afu-cursor-left()  { (( CURSOR -= 1 )) } && zle -N afu-cursor-left
  afu-cursor-right() { (( CURSOR += 1 )) } && zle -N afu-cursor-right

  zle-line-init() { afu_in_p=0; auto-fu-init; } && zle -N zle-line-init
fi  # zstyle -t ':prezto:module:completion' autocompletion 'yes'


#
# Frequent commands completion
#

function _accept-line-and-hook() {
  zle accept-line && local return_code="$?"

  [[ $return_code == 0 ]] || return $return_code

  local line=$(echo ${BUFFER} | sed -e "s/^ *//"                     \
    -e "s/^\([a-zA-Z0-9_]\+=\('[^']*'\|\"[^\"]*\"\|[^ '\"]*\) *\)//" \
    -e "s/^sudo  *//")

  local tokens=(${(z)line})

  [[ ${tokens[1]} =~ "/|\"|=" ]] && return $return_code
  (( ${#tokens[1]} <= 1 )) && return $return_code

  # TODO(yury): This is only needed because return_code is not working
  whence ${tokens[1]} &>/dev/null || return $return_code

  local data=$(echo "${tokens[1]}" | sort -u -m "${HISTFILE}-commands" -)
  echo -n "$data" >! "${HISTFILE}-commands"; return $return_code
}

zle -N accept-line-and-hook _accept-line-and-hook

for keymap in 'vicmd' 'viins' 'emacs' 'afu-vicmd' 'afu'; do
  bindkey -M ${keymap} "$key_info[Enter]" accept-line-and-hook &>/dev/null; done
