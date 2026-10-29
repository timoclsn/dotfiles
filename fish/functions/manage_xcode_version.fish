function manage_xcode_version
    if not command -q fzf
        echo "fzf is not installed. Please install it first."
        return 1
    end

    set -l current_xcode (xcode-select -p 2>/dev/null | string replace /Contents/Developer '')
    set -l current_xcode_name (basename "$current_xcode" 2>/dev/null; or echo none)
    set -l current_xcode_string "(current: $current_xcode_name)"

    set -l xcode_apps /Applications/Xcode*.app

    if test (count $xcode_apps) -eq 0
        echo "No Xcode applications found in /Applications"
        return 1
    end

    set -l selected_xcode (path basename $xcode_apps | \
        fzf --height 15 \
            --cycle \
            --prompt="Select Xcode version: " \
            --border-label " Manage Xcode $current_xcode_string")
    test -n "$selected_xcode"; or return 0

    if not sudo xcode-select -s /Applications/$selected_xcode
        echo "Failed to switch Xcode version"
        return 1
    end
    echo "Successfully switched to:"
    xcodebuild -version
end
