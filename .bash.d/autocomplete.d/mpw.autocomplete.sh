# MPW Autocomplete

function __mpw_entries {
    local cur prev opts base
    COMPREPLY=()

    cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=( \
        $( compgen -W \
            "$( jq '.sites | to_entries | .[] .key' $HOME/.mpw.d/"$MPW_FULLNAME"*.*json | sort -u | sed 's/"//g' )" \
            $cur \
        ) \
    )
}

complete -F __mpw_entries mpw
