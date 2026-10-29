# Delete (one or multiple) selected application(s)
# mnemonic [B]rew [C]lean [P]ackage (e.g. uninstall)
function bcp
    set -l uninst (brew leaves | \
        fzf -m \
            --height 15 \
            --cycle \
            --prompt="Select packages to remove: " \
            --border-label=" Brew Uninstall ")

    for prog in $uninst
        brew uninstall $prog
    end
end
