[alias]
    # most of these are coming from brauliobo
    root = rev-parse --show-toplevel
    co = checkout
    amend = commit --amend

    undo = reset HEAD^1
    unstage = reset HEAD

    tags = tag -l

    st = status

    ap = add -p
    br = branch

    pr = prune
