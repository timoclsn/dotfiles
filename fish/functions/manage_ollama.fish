function manage_ollama
    if not command -q ollama
        echo "ollama is not installed. Please install it first."
        return 1
    end

    if not command -q fzf
        echo "fzf is not installed. Please install it first."
        return 1
    end

    if not pgrep -f "ollama serve" >/dev/null
        echo "Ollama service is not running. Starting it now..."
        ollama serve >/dev/null 2>&1 &
        # Wait a moment for the service to start
        sleep 2
    end

    set -l action (printf '%s\n' \
        "1. Run installed model" \
        "2. Remove model" \
        "3. Stop Ollama service" | \
        fzf --height 15 \
            --cycle \
            --no-clear \
            --prompt="Select ollama action: " \
            --border-label " Manage Ollama ")

    switch $action
        case "1. Run installed model"
            set -l model (ollama list | \
                fzf --height 15 \
                    --cycle \
                    --tac \
                    --prompt="Select model to run: " \
                    --border-label " Run Ollama Model " | \
                awk '{print $1}')
            if test -n "$model"
                ollama run $model
            end

        case "2. Remove model"
            set -l model (ollama list | \
                fzf --height 15 \
                    --cycle \
                    --tac \
                    --prompt="Select model to remove: " \
                    --border-label " Remove Ollama Model " | \
                awk '{print $1}')
            test -n "$model"; or return
            read -P "Are you sure you want to remove $model? (y/N) " answer
            if string match -qr '^[Yy]$' -- $answer
                ollama rm $model
            end

        case "3. Stop Ollama service"
            read -P "Are you sure you want to stop the Ollama service? (y/N) " answer
            if string match -qr '^[Yy]$' -- $answer
                pkill -f "ollama serve"
                echo "Ollama service stopped."
            end
    end
end
