# TOTP Autocomplete

function __totp_entries {
    local cur prev opts base
    COMPREPLY=()

    cur="${COMP_WORDS[COMP_CWORD]}"
    if [ ! -f ~/.secrets/totp ] ; then
        return
    fi

    COMPREPLY=( \
        $( compgen -W \
            "$( awk -F= '{ print $1 }' ~/.secrets/totp )" \
            $cur \
        ) \
    )
}

complete -F __totp_entries totp
