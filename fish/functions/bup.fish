# Update (one or multiple) selected application(s)
# mnemonic [B]rew [U]pdate [P]ackage
function bup
    set -l upd (brew leaves | \
        fzf -m \
            --height 15 \
            --cycle \
            --prompt="Select packages to update: " \
            --border-label=" Brew Update ")

    for prog in $upd
        brew upgrade $prog
    end
end
