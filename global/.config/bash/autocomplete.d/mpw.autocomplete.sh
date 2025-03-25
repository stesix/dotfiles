# MPW Autocomplete

export MPW_ENTRIES_PATH

if which mpw &>/dev/null ; then
    MPW_ENTRIES_PATH="$HOME/.mpw.d/$MPW_FULLNAME"
elif which spectre &>/dev/null ; then
    MPW_ENTRIES_PATH="$HOME/.spectre.d/$MPW_FULLNAME"
fi

function __mpw_entries {
    local cur prev opts base
    COMPREPLY=()

    cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=( \
        $( compgen -W \
            "$( jq '.sites | to_entries | .[] .key' "$MPW_ENTRIES_PATH"*.*json | sort -u | sed 's/"//g' )" \
            $cur \
        ) \
    )
}

complete -F __mpw_entries mpw spectre
