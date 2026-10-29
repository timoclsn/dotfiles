function run_nx_target
    set -l missing_deps
    for dep in jq fzf
        command -q $dep; or set -a missing_deps $dep
    end

    if test (count $missing_deps) -ne 0
        echo "Error: Missing required dependencies: $missing_deps"
        echo "Please install them before running this script."
        return 1
    end

    if not test -f nx.json
        echo "Error: nx.json not found in current directory"
        return 1
    end

    set -l project (npx nx show projects --json 2>/dev/null | jq -r '.[]' | sort | \
        fzf --height 15 \
            --cycle \
            --prompt="Select project: " \
            --border-label=" Select Nx project ")
    test -n "$project"; or return 0

    set -l target (npx nx show project $project --json 2>/dev/null | \
        jq -r '.targets | keys[]' | sort | \
        fzf --height 15 \
            --cycle \
            --prompt="Select target to run: " \
            --border-label=" Run target for $project ")
    test -n "$target"; or return 0

    history append -- "npx nx run $project:$target"
    npx nx run $project:$target
end
