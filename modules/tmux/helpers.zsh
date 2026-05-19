# Cache the TMUX version for speed.
tmux_version="$(tmux -V | cut -d ' ' -f 2)"
tmux_version="${tmux_version//[!0-9.]/}"

tmux_is_at_least_v() {
    [[ $tmux_version == "master" ]] && return 0
    autoload -Uz is-at-least
    is-at-least "$1" "$tmux_version"
}
