function manage_node_version
    if not command -q fnm
        echo "fnm is not installed. Please install it first."
        return 1
    end

    if not command -q fzf
        echo "fzf is not installed. Please install it first."
        return 1
    end

    set -l current_version (node --version 2>/dev/null; or echo none)
    set -l current_version_string "(current: $current_version)"

    set -l action (printf '%s\n' \
        "1. Use installed version" \
        "2. Set default version" \
        "3. Install new version" \
        "4. Uninstall version" | \
        fzf --height 15 \
            --cycle \
            --no-clear \
            --prompt="Select fnm action: " \
            --border-label " Manage Node.js $current_version_string")

    switch $action
        case "1. Use installed version"
            set -l node_version (fnm list | \
                fzf --height 15 \
                    --cycle \
                    --tac \
                    --prompt="Select version to use: " \
                    --border-label " Manage Node.js $current_version_string" | \
                string replace -r '^\* ' '')
            if test -n "$node_version"
                fnm use $node_version
            end

        case "2. Set default version"
            set -l node_version (fnm list | \
                fzf --height 15 \
                    --cycle \
                    --tac \
                    --prompt="Select version to set as default: " \
                    --border-label " Set Default Node.js Version $current_version_string" | \
                string replace -r '^\* ' '')
            if test -n "$node_version"
                fnm default $node_version
            end

        case "3. Install new version"
            set -l node_version (fnm list-remote | \
                fzf --height 15 \
                    --tac \
                    --prompt="Select version to install: " \
                    --border-label " Install Node.js $current_version_string")
            test -n "$node_version"; or return
            fnm install $node_version
            read -P "Do you want to set this version as default? (y/N) " answer
            if string match -qr '^[Yy]$' -- $answer
                fnm default $node_version
                fnm use $node_version
            end

        case "4. Uninstall version"
            set -l node_version (fnm list | \
                fzf --height 15 \
                    --cycle \
                    --tac \
                    --prompt="Select version to uninstall: " \
                    --border-label " Uninstall Node.js Version $current_version_string" | \
                string replace -r '^\* ' '')
            test -n "$node_version"; or return
            read -P "Are you sure you want to uninstall Node.js $node_version? (y/N) " answer
            if string match -qr '^[Yy]$' -- $answer
                fnm uninstall $node_version
            end
    end
end
