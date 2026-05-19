#
# Configure fzf options
#
# Authors:
#   Yury Gitman <me.gitman@gmail.com>
#


(( $+commands[ag] )) &&\
  export FZF_DEFAULT_COMMAND="ag --files --hidden --no-messages "

(( $+commands[rg] )) &&\
  export FZF_DEFAULT_COMMAND="rg -L --files --hidden --no-messages "

export FZF_DEFAULT_OPTS="-i -m -1 --ansi --algo=v1 --bind change:top --cycle --color=bg+:-1\
  --inline-info --tiebreak=begin,length,index --bind=tab:toggle-up,btab:toggle-down,esc:cancel"

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND ./"

export FZF_CTRL_T_OPTS='--preview-window=up'


# Fzf shell integration (completion + key-bindings)
local _fzf_dir
if (( $+commands[fzf] )); then
  local _fzf_base="${commands[fzf]:A:h:h}"
  for _fzf_dir in \
    $_fzf_base/shell \
    $_fzf_base/opt/fzf/shell \
    $_fzf_base/share/fzf \
    $_fzf_base/share/doc/fzf/examples
  do
    [[ -f $_fzf_dir/completion.zsh ]] && break
    _fzf_dir=
  done
elif [[ -d $HOME/.fzf/shell ]]; then
  _fzf_dir=$HOME/.fzf/shell
fi

if [[ -n "$_fzf_dir" ]]; then
  source $_fzf_dir/completion.zsh   2>/dev/null
  source $_fzf_dir/key-bindings.zsh 2>/dev/null
fi
unset _fzf_dir _fzf_base

if (( $+commands[fzf] )) || [[ -d $HOME/.fzf ]]; then
  for keymap in 'emacs' 'viins' 'vicmd' 'afu-vicmd'
  do
    bindkey -M ${keymap} "$key_info[Control]R" fzf-history-widget &>/dev/null
    bindkey -M ${keymap} "$key_info[Control]T"    fzf-file-widget &>/dev/null
  done

  afu-fzf-file-widget() {
    afu_in_p=0; BUFFER="${buffer_cur}"; fzf-file-widget }

  afu-fzf-history-widget() {
    afu_in_p=0; BUFFER="${buffer_cur}"; fzf-history-widget }

  zle -N afu-fzf-history-widget
  zle -N afu-fzf-file-widget

  bindkey -M afu "$key_info[Control]R" afu-fzf-history-widget &>/dev/null
  bindkey -M afu "$key_info[Control]T"    afu-fzf-file-widget &>/dev/null
fi
