# Hard clear: visible screen + scrollback (and tmux history if in tmux)
function c
    printf "\033c"
    if set -q TMUX
        command tmux clear-history
    end
end
