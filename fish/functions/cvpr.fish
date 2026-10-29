function cvpr
    set -l base (git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)
    or set base origin/(git config --get init.defaultBranch 2>/dev/null; or echo main)
    git diff (git merge-base HEAD $base)...HEAD | comview
end
