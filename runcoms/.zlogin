#
# Executes commands at login post-zshrc.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

{
  zbuild() { zrecompile -p -U -z -M ${1} }

  autoload -Uz zrecompile

  local MOD_DIR="${${(%):-%N}:h:h:A}/modules/"

  # Compile .zshrc and .zprofile
  zbuild ${ZDOTDIR:-${HOME}}/.zprofile
  zbuild ${ZDOTDIR:-${HOME}}/.zshrc

  zbuild ${ZDOTDIR:-${HOME}}/../init.zsh

  setopt EXTENDED_GLOB

  # Compile the completion dump to increase startup speed.
  for file in "${ZDOTDIR:-$HOME}"/.zcomp^(*.zwc*)(.N); do zbuild "${file}"; done

  # Compile autoloaded functions
  for file in "${MOD_DIR}"/**/functions/^(*.zwc*)(.N); do zbuild "${file}"; done

  # Compile module init.zsh scripts
  for file in "${MOD_DIR}"/*/init.zsh; do zbuild "${file}"; done

  # Compile tmux-mem-cpu-usage
  if ! [[ -x ${HOME}/.local/bin/tmux-mem-cpu-load ]]
  then
    local BUILD_DIR=${TMPDIR:-/tmp}/build/tmux-mem-cpu-load

    mkdir -p ${BUILD_DIR}; cd ${BUILD_DIR}

    local CMAKE_OPTS=(
      "-GUnix Makefiles"
      "-DCMAKE_BUILD_TYPE=Release"
      "-DCMAKE_INSTALL_PREFIX=${HOME}/.local"
    )

    cmake ${CMAKE_OPTS[@]} "${MOD_DIR}/tmux/external/tmux-mem-cpu-status/" \
      && make -C "${BUILD_DIR}" && make -C "${BUILD_DIR}" install
  fi

  # Install fzf if not available
  if (( ! $+commands[fzf] )) && [[ ! -d $HOME/.fzf ]] && (( $+commands[git] )); then
    git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf \
      && $HOME/.fzf/install --64 --key-bindings --completion --no-update-rc
  fi

  # Compile auto-fu and subfiles
  { local ZSHFU_DIR="${MOD_DIR}/completion/external-modules/autocompletion/"
    for file in "${ZSHFU_DIR}"/auto-fu{,-widgets,-predicates}; do
      [[ -f "$file" ]] && zbuild "$file"
    done
  }

  for file in "${MOD_DIR}"/completion/completions/_^*.zwc*; do zbuild "${file}"; done

  # Compile syntax highlighting
  local SYNTAX_MOD="${MOD_DIR}/syntax-highlighting/external"

  zbuild "${SYNTAX_MOD}/zsh-syntax-highlighting.zsh"
  for file in "${SYNTAX_MOD}"/highlighters/**^test-data/*.zsh; do zbuild "${file}"; done

  for file in ${^fpath}/_^(*.zwc*)(.N); do zbuild "${file}"; done

  rm -f ${${ZDOTDIR:-${HOME}}:h}/**/*.zwc.old*(N) ${${ZDOTDIR:-${HOME}}:h}/**/.*.zwc.old*(N)
} &>/dev/null &!
