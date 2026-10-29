# Personal projects use the personal Claude login, everything else the work one.
# Pass --work or --personal (also through the cc* aliases) to pick the login
# regardless of the project.
function claude
    set -l account_flag
    set -l args
    for arg in $argv
        switch $arg
            case --work --personal
                set account_flag $arg
            case '*'
                set -a args $arg
        end
    end

    set -l config_dir
    if test -n "$account_flag"
        set config_dir (claude-config-dir $account_flag)
    else if test -n "$CLAUDE_CONFIG_DIR"
        set config_dir $CLAUDE_CONFIG_DIR
    else
        set config_dir (claude-config-dir $PWD)
    end

    # The work login is the default one, which needs CLAUDE_CONFIG_DIR unset
    if test -n "$config_dir"
        CLAUDE_CONFIG_DIR=$config_dir command claude $args
    else
        env -u CLAUDE_CONFIG_DIR claude $args
    end
end
