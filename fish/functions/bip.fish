# Install (one or multiple) selected application(s)
# using "brew search" as source input
# mnemonic [B]rew [I]nstall [P]ackage
function bip
    set -l inst (brew search $argv | \
        fzf -m \
            --height 15 \
            --cycle \
            --prompt="Select packages to install: " \
            --border-label=" Brew Install ")

    for prog in $inst
        brew install $prog
    end
end
