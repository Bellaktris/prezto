# Cache the TMUX version for speed.
tmux_version="$(tmux -V | cut -d ' ' -f 2)"

tmux_is_at_least() {
    [[ $tmux_version == "master" ]] \
        && return 0

    (( $tmux_version >= $1 )) && return 0 || return 1
}
