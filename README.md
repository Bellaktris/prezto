Bellaktris/prezto
=================

A personal fork of [Prezto][1], the Zsh configuration framework by Sorin
Ionescu. It is the `zsh/` submodule of [Bellaktris/.files][2] and is laid out
to run from there, not from `~/.zprezto`. Upstream changes are merged in from
time to time; everything that differs from upstream is described below.

For the framework itself - how modules load, what each upstream module does -
see the [upstream README][1] and the README in each `modules/*` directory.

Installation
------------

As part of the dotfiles, which links `~/.zshenv` and does the rest:

```console
git clone --recursive https://github.com/Bellaktris/.files ~/.files
~/.files/install
```

On its own, anywhere:

```console
git clone --recursive https://github.com/Bellaktris/prezto ~/.zsh
ln -s ~/.zsh/runcoms/.zshenv ~/.zshenv
zsh -c 'source ~/.zsh/runcoms/.zlogin'
chsh -s "$(command -v zsh)"
```

Requires a recent Zsh (5.x). `cmake` and a C++ compiler are needed for the
tmux status widget; `fzf` is installed by `.zlogin` if it is missing.

Layout
------

Unlike upstream, nothing but `~/.zshenv` lives in `$HOME`. `runcoms/.zshenv`
points `ZDOTDIR` at its own directory:

```sh
export ZDOTDIR=${${(%):-%N}:A:h}
```

so Zsh reads `.zprofile`, `.zshrc` and `.zlogin` straight from `runcoms/`, and
`.zshrc` sources `runcoms/.zpreztorc` and then `init.zsh`.

| file                   | what it does                                             |
| ---------------------- | -------------------------------------------------------- |
| `runcoms/.zshenv`      | sets `ZDOTDIR`; sources `.zprofile` in non-login shells   |
| `runcoms/.zprofile`    | locale, `path`, `TMPDIR`, editor, pager, Homebrew prefix |
| `runcoms/.zpreztorc`   | which modules load, and their settings                   |
| `runcoms/.zshrc`       | loads Prezto, vi-mode tweaks, cached prompt at startup   |
| `runcoms/.zlogin`      | compiles, builds and installs - see below                |

`.zprofile` expects the Python startup file at `~/.files/python/.pythonrc`, so
outside the dotfiles that line wants adjusting.

### .zlogin

Runs once per login shell, as a disowned background job so it never delays the
prompt:

- `zrecompile`s the runcoms, `init.zsh`, every module's `init.zsh` and
  `functions/`, the completion functions, auto-fu and zsh-syntax-highlighting,
  and removes stale `*.zwc.old` files;
- builds `tmux-mem-cpu-load` into `~/.local/bin` with cmake, the first time;
- installs `fzf` through brew, apt, dnf or pacman (or a git clone) when it is
  not on `PATH`.

Re-run it by hand after editing anything under `modules/` or `runcoms/`:

```console
source ~/.files/zsh/runcoms/.zlogin
```

### Machine-local overrides

Sourced when present, and never committed:

- `runcoms/.zprofile-local` - from `.zprofile`
- `runcoms/.zshrc-local` - from `.zshrc`

What differs from upstream
--------------------------

### Modules

Loaded, in order (`runcoms/.zpreztorc`): fbterm, tmux, environment, terminal,
history, archive, git, syntax-highlighting, editor, directory, spectrum,
utility, completion, fzf, ssh, prompt. Vi key bindings, the sorin theme, and
tmux auto-started for local and remote sessions.

Added in this fork:

- **fzf** - fzf key bindings and completion, wired into the inline
  auto-completion so the two do not fight over the line.
- **fbterm** - framebuffer terminal on Linux consoles, with background images.

Changed substantially:

- **completion** - inline completion as you type, by a fork of auto-fu
  (`modules/completion/external-modules/autocompletion`, its own submodule,
  [Bellaktris/auto-fu][3]; see its readme). Also: a file list that sizes its
  name column to its content and keeps each match's quoting, a cache guard on
  `compinit`, `_opt_file_fallback` for `--opt=` specs with no action, and
  completions for `mpcc`, `vpnchain`, `claude`, `ffprobe`, `mpv`, `hg` and `rm`
  in `modules/completion/completions/`.
- **tmux** - status line widgets: `tmux-mem-cpu-load` (built by `.zlogin`) and
  battery state, plus tmux-yank.
- **editor** - backslash escapes count as part of a word; Escape in tmux copy
  mode behaves.
- **terminal** - `time-report` prints the time, CPU share and peak memory of
  any command that runs longer than 10 seconds.

Throughout, `echo` has been replaced by `printf` and a number of upstream bugs
fixed; `git log` has the details.

### Submodules

Several modules vendor their upstream projects under `external/`. Clone with
`--recursive`, or after a pull:

```console
git submodule update --init --recursive
```

Changes to auto-fu are committed in its submodule first, then the pointer is
bumped here, then in the dotfiles.

License
-------

MIT, as upstream. See the [upstream repository][1] for the original authors.

[1]: https://github.com/sorin-ionescu/prezto
[2]: https://github.com/Bellaktris/.files
[3]: https://github.com/Bellaktris/auto-fu
