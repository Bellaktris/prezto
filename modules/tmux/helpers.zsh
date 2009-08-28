# Cache the TMUX version for speed.
tmux_version="$(tmux -V | cut -d ' ' -f 2)"
tmux_version="${tmux_version//[!0-9.]/}"

tmux_is_at_least_v() {
    [[ $tmux_version == "master" ]] \
        && return 0

    (( $tmux_version < $1 )) && return 1 || return 0
}
