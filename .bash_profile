for DOTFILE in ~/.dotfiles/.{path,aliases,functions}; do
    [ -f "$DOTFILE" ] && . "$DOTFILE"
done
