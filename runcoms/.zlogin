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
  for file in "${ZDOTDIR:-$HOME}"/.zcomp^(*.zwc)(.N); do zbuild "${file}"; done

  # Compile autoloaded functions
  for file in "${MOD_DIR}"/**/functions/^(*.zwc)(.N); do zbuild "${file}"; done

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

  # Load fzf if not available
  (( ! $+commands[fzf] )) && \
    { git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
      sh -c ~/.fzf/install --64 --no-update-rc }

  # Compile completion functions
  ! [[ -f "${MOD_DIR}/completion/external/autocompletion/auto-fu" ]] && \
      { local ZSHFU_DIR="${MOD_DIR}/completion/external/autocompletion/"
        local ZSHFU="${ZSHFU_DIR}/auto-fu.zsh"

        # source ${ZSHFU}; auto-fu-zcompile $ZSHFU $ZSHFU_DIR
        zbuild "${ZSHFU_DIR}/auto-fu" }

  for file in "${MOD_DIR}"/completion/completions/_^*.zwc; do zbuild "${file}"; done

  # Compile syntax highlighting
  local SYNTAX_MOD="${MOD_DIR}/syntax-highlighting/external"

  zbuild "${SYNTAX_MOD}/zsh-syntax-highlighting.zsh"
  for file in "${SYNTAX_MOD}"/highlighters/**^test-data/*.zsh; do zbuild "${file}"; done

  for file in ${^fpath}/_^(*.zwc)(.N); do zbuild "${file}"; done

  rm -f ${${ZDOTDIR:-${HOME}}:h}/**/*.zwc.old && rm -f ${${ZDOTDIR:-${HOME}}:h}/**/.*.zwc.old
} &>/dev/null &!
