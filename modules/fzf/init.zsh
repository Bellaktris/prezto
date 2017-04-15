#
# Configure fzf options
#
# Authors:
#   Yury Gitman <me.gitman@gmail.com>
#


(( $+commands[ag] )) &&\
  export FZF_DEFAULT_COMMAND="ag --files --hidden --no-messages "

(( $+commands[rg] )) &&\
  export FZF_DEFAULT_COMMAND="rg --files --hidden --no-messages "

export FZF_DEFAULT_OPTS="-i -m -1 --ansi --algo=v1 --cycle --color=bg+:-1\
  --inline-info --tiebreak=begin,length,index --bind=tab:toggle-up,btab:toggle-down"

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND ./"

export FZF_CTRL_T_OPTS='--preview-window=up'


# Fzf
source $HOME/.fzf/shell/completion.zsh   $>/dev/null
source $HOME/.fzf/shell/key-bindings.zsh $>/dev/null

afu-fzf-history-widget() {
  afu_in_p=0; BUFFER="${buffer_cur}"; fzf-history-widget }

zle -N afu-fzf-history-widget

for keymap in 'emacs' 'viins' 'vicmd' 'afu-vicmd'
do
  bindkey -M ${keymap} "$key_info[Control]R" fzf-history-widget &>/dev/null
  bindkey -M ${keymap} "$key_info[Control]T"    fzf-file-widget &>/dev/null
done

bindkey -M afu "$key_info[Control]R" afu-fzf-history-widget &>/dev/null
bindkey -M afu "$key_info[Control]T"        fzf-file-widget &>/dev/null
