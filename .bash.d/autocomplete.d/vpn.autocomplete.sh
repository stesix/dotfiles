# VPN Autocomplete

function __vpn_entries {
    local cur prev opts base
    COMPREPLY=()

    cur="${COMP_WORDS[COMP_CWORD]}"

    COMPREPLY=( \
        $( compgen -W \
            "$( ls /etc/openvpn | grep '\.conf$' | cut -d'.' -f1 )" \
            $cur \
        ) \
    )

}

complete -F __vpn_entries vpn
complete -F __vpn_entries vpnup
complete -F __vpn_entries vpndown
