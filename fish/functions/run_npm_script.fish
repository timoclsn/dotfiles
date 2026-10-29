# Run npm script, requires jq fzf and nr
function run_npm_script
    set -l missing_deps
    for dep in jq fzf nr
        command -q $dep; or set -a missing_deps $dep
    end

    if test (count $missing_deps) -ne 0
        echo "Error: Missing required dependencies: $missing_deps"
        echo "Please install them before running this script."
        return 1
    end

    if not test -f package.json
        echo "Error: package.json not found in current directory"
        return 1
    end

    if test (jq -r '.scripts | length' package.json) -eq 0
        echo "Error: No scripts found in package.json"
        return 1
    end

    set -l script (jq -r '.scripts | keys[]' package.json | sort | \
        fzf --height 15 \
            --cycle \
            --prompt="Select script to run: " \
            --border-label=" Run npm script ")
    test -n "$script"; or return

    history append -- "nr $script"
    nr $script
end
