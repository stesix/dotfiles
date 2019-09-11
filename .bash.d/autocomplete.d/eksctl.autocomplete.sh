# bash completion for eksctl                               -*- shell-script -*-

__eksctl_debug()
{
    if [[ -n ${BASH_COMP_DEBUG_FILE} ]]; then
        echo "$*" >> "${BASH_COMP_DEBUG_FILE}"
    fi
}

# Homebrew on Macs have version 1.3 of bash-completion which doesn't include
# _init_completion. This is a very minimal version of that function.
__eksctl_init_completion()
{
    COMPREPLY=()
    _get_comp_words_by_ref "$@" cur prev words cword
}

__eksctl_index_of_word()
{
    local w word=$1
    shift
    index=0
    for w in "$@"; do
        [[ $w = "$word" ]] && return
        index=$((index+1))
    done
    index=-1
}

__eksctl_contains_word()
{
    local w word=$1; shift
    for w in "$@"; do
        [[ $w = "$word" ]] && return
    done
    return 1
}

__eksctl_handle_reply()
{
    __eksctl_debug "${FUNCNAME[0]}"
    case $cur in
        -*)
            if [[ $(type -t compopt) = "builtin" ]]; then
                compopt -o nospace
            fi
            local allflags
            if [ ${#must_have_one_flag[@]} -ne 0 ]; then
                allflags=("${must_have_one_flag[@]}")
            else
                allflags=("${flags[*]} ${two_word_flags[*]}")
            fi
            COMPREPLY=( $(compgen -W "${allflags[*]}" -- "$cur") )
            if [[ $(type -t compopt) = "builtin" ]]; then
                [[ "${COMPREPLY[0]}" == *= ]] || compopt +o nospace
            fi

            # complete after --flag=abc
            if [[ $cur == *=* ]]; then
                if [[ $(type -t compopt) = "builtin" ]]; then
                    compopt +o nospace
                fi

                local index flag
                flag="${cur%=*}"
                __eksctl_index_of_word "${flag}" "${flags_with_completion[@]}"
                COMPREPLY=()
                if [[ ${index} -ge 0 ]]; then
                    PREFIX=""
                    cur="${cur#*=}"
                    ${flags_completion[${index}]}
                    if [ -n "${ZSH_VERSION}" ]; then
                        # zsh completion needs --flag= prefix
                        eval "COMPREPLY=( \"\${COMPREPLY[@]/#/${flag}=}\" )"
                    fi
                fi
            fi
            return 0;
            ;;
    esac

    # check if we are handling a flag with special work handling
    local index
    __eksctl_index_of_word "${prev}" "${flags_with_completion[@]}"
    if [[ ${index} -ge 0 ]]; then
        ${flags_completion[${index}]}
        return
    fi

    # we are parsing a flag and don't have a special handler, no completion
    if [[ ${cur} != "${words[cword]}" ]]; then
        return
    fi

    local completions
    completions=("${commands[@]}")
    if [[ ${#must_have_one_noun[@]} -ne 0 ]]; then
        completions=("${must_have_one_noun[@]}")
    fi
    if [[ ${#must_have_one_flag[@]} -ne 0 ]]; then
        completions+=("${must_have_one_flag[@]}")
    fi
    COMPREPLY=( $(compgen -W "${completions[*]}" -- "$cur") )

    if [[ ${#COMPREPLY[@]} -eq 0 && ${#noun_aliases[@]} -gt 0 && ${#must_have_one_noun[@]} -ne 0 ]]; then
        COMPREPLY=( $(compgen -W "${noun_aliases[*]}" -- "$cur") )
    fi

    if [[ ${#COMPREPLY[@]} -eq 0 ]]; then
		if declare -F __eksctl_custom_func >/dev/null; then
			# try command name qualified custom func
			__eksctl_custom_func
		else
			# otherwise fall back to unqualified for compatibility
			declare -F __custom_func >/dev/null && __custom_func
		fi
    fi

    # available in bash-completion >= 2, not always present on macOS
    if declare -F __ltrim_colon_completions >/dev/null; then
        __ltrim_colon_completions "$cur"
    fi

    # If there is only 1 completion and it is a flag with an = it will be completed
    # but we don't want a space after the =
    if [[ "${#COMPREPLY[@]}" -eq "1" ]] && [[ $(type -t compopt) = "builtin" ]] && [[ "${COMPREPLY[0]}" == --*= ]]; then
       compopt -o nospace
    fi
}

# The arguments should be in the form "ext1|ext2|extn"
__eksctl_handle_filename_extension_flag()
{
    local ext="$1"
    _filedir "@(${ext})"
}

__eksctl_handle_subdirs_in_dir_flag()
{
    local dir="$1"
    pushd "${dir}" >/dev/null 2>&1 && _filedir -d && popd >/dev/null 2>&1
}

__eksctl_handle_flag()
{
    __eksctl_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    # if a command required a flag, and we found it, unset must_have_one_flag()
    local flagname=${words[c]}
    local flagvalue
    # if the word contained an =
    if [[ ${words[c]} == *"="* ]]; then
        flagvalue=${flagname#*=} # take in as flagvalue after the =
        flagname=${flagname%=*} # strip everything after the =
        flagname="${flagname}=" # but put the = back
    fi
    __eksctl_debug "${FUNCNAME[0]}: looking for ${flagname}"
    if __eksctl_contains_word "${flagname}" "${must_have_one_flag[@]}"; then
        must_have_one_flag=()
    fi

    # if you set a flag which only applies to this command, don't show subcommands
    if __eksctl_contains_word "${flagname}" "${local_nonpersistent_flags[@]}"; then
      commands=()
    fi

    # keep flag value with flagname as flaghash
    # flaghash variable is an associative array which is only supported in bash > 3.
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        if [ -n "${flagvalue}" ] ; then
            flaghash[${flagname}]=${flagvalue}
        elif [ -n "${words[ $((c+1)) ]}" ] ; then
            flaghash[${flagname}]=${words[ $((c+1)) ]}
        else
            flaghash[${flagname}]="true" # pad "true" for bool flag
        fi
    fi

    # skip the argument to a two word flag
    if [[ ${words[c]} != *"="* ]] && __eksctl_contains_word "${words[c]}" "${two_word_flags[@]}"; then
			  __eksctl_debug "${FUNCNAME[0]}: found a flag ${words[c]}, skip the next argument"
        c=$((c+1))
        # if we are looking for a flags value, don't show commands
        if [[ $c -eq $cword ]]; then
            commands=()
        fi
    fi

    c=$((c+1))

}

__eksctl_handle_noun()
{
    __eksctl_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    if __eksctl_contains_word "${words[c]}" "${must_have_one_noun[@]}"; then
        must_have_one_noun=()
    elif __eksctl_contains_word "${words[c]}" "${noun_aliases[@]}"; then
        must_have_one_noun=()
    fi

    nouns+=("${words[c]}")
    c=$((c+1))
}

__eksctl_handle_command()
{
    __eksctl_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    local next_command
    if [[ -n ${last_command} ]]; then
        next_command="_${last_command}_${words[c]//:/__}"
    else
        if [[ $c -eq 0 ]]; then
            next_command="_eksctl_root_command"
        else
            next_command="_${words[c]//:/__}"
        fi
    fi
    c=$((c+1))
    __eksctl_debug "${FUNCNAME[0]}: looking for ${next_command}"
    declare -F "$next_command" >/dev/null && $next_command
}

__eksctl_handle_word()
{
    if [[ $c -ge $cword ]]; then
        __eksctl_handle_reply
        return
    fi
    __eksctl_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"
    if [[ "${words[c]}" == -* ]]; then
        __eksctl_handle_flag
    elif __eksctl_contains_word "${words[c]}" "${commands[@]}"; then
        __eksctl_handle_command
    elif [[ $c -eq 0 ]]; then
        __eksctl_handle_command
    elif __eksctl_contains_word "${words[c]}" "${command_aliases[@]}"; then
        # aliashash variable is an associative array which is only supported in bash > 3.
        if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
            words[c]=${aliashash[${words[c]}]}
            __eksctl_handle_command
        else
            __eksctl_handle_noun
        fi
    else
        __eksctl_handle_noun
    fi
    __eksctl_handle_word
}

_eksctl_create_cluster()
{
    last_command="eksctl_create_cluster"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--alb-ingress-access")
    local_nonpersistent_flags+=("--alb-ingress-access")
    flags+=("--appmesh-access")
    local_nonpersistent_flags+=("--appmesh-access")
    flags+=("--asg-access")
    local_nonpersistent_flags+=("--asg-access")
    flags+=("--authenticator-role-arn=")
    two_word_flags+=("--authenticator-role-arn")
    local_nonpersistent_flags+=("--authenticator-role-arn=")
    flags+=("--auto-kubeconfig")
    local_nonpersistent_flags+=("--auto-kubeconfig")
    flags+=("--cfn-role-arn=")
    two_word_flags+=("--cfn-role-arn")
    local_nonpersistent_flags+=("--cfn-role-arn=")
    flags+=("--config-file=")
    two_word_flags+=("--config-file")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--config-file=")
    flags+=("--external-dns-access")
    local_nonpersistent_flags+=("--external-dns-access")
    flags+=("--full-ecr-access")
    local_nonpersistent_flags+=("--full-ecr-access")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--max-pods-per-node=")
    two_word_flags+=("--max-pods-per-node")
    local_nonpersistent_flags+=("--max-pods-per-node=")
    flags+=("--name=")
    two_word_flags+=("--name")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--name=")
    flags+=("--node-ami=")
    two_word_flags+=("--node-ami")
    local_nonpersistent_flags+=("--node-ami=")
    flags+=("--node-ami-family=")
    two_word_flags+=("--node-ami-family")
    local_nonpersistent_flags+=("--node-ami-family=")
    flags+=("--node-labels=")
    two_word_flags+=("--node-labels")
    local_nonpersistent_flags+=("--node-labels=")
    flags+=("--node-private-networking")
    flags+=("-P")
    local_nonpersistent_flags+=("--node-private-networking")
    flags+=("--node-security-groups=")
    two_word_flags+=("--node-security-groups")
    local_nonpersistent_flags+=("--node-security-groups=")
    flags+=("--node-type=")
    two_word_flags+=("--node-type")
    two_word_flags+=("-t")
    local_nonpersistent_flags+=("--node-type=")
    flags+=("--node-volume-size=")
    two_word_flags+=("--node-volume-size")
    local_nonpersistent_flags+=("--node-volume-size=")
    flags+=("--node-volume-type=")
    two_word_flags+=("--node-volume-type")
    local_nonpersistent_flags+=("--node-volume-type=")
    flags+=("--node-zones=")
    two_word_flags+=("--node-zones")
    local_nonpersistent_flags+=("--node-zones=")
    flags+=("--nodegroup-name=")
    two_word_flags+=("--nodegroup-name")
    local_nonpersistent_flags+=("--nodegroup-name=")
    flags+=("--nodes=")
    two_word_flags+=("--nodes")
    two_word_flags+=("-N")
    local_nonpersistent_flags+=("--nodes=")
    flags+=("--nodes-max=")
    two_word_flags+=("--nodes-max")
    two_word_flags+=("-M")
    local_nonpersistent_flags+=("--nodes-max=")
    flags+=("--nodes-min=")
    two_word_flags+=("--nodes-min")
    two_word_flags+=("-m")
    local_nonpersistent_flags+=("--nodes-min=")
    flags+=("--profile=")
    two_word_flags+=("--profile")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--profile=")
    flags+=("--region=")
    two_word_flags+=("--region")
    two_word_flags+=("-r")
    local_nonpersistent_flags+=("--region=")
    flags+=("--set-kubeconfig-context")
    local_nonpersistent_flags+=("--set-kubeconfig-context")
    flags+=("--ssh-access")
    local_nonpersistent_flags+=("--ssh-access")
    flags+=("--ssh-public-key=")
    two_word_flags+=("--ssh-public-key")
    local_nonpersistent_flags+=("--ssh-public-key=")
    flags+=("--tags=")
    two_word_flags+=("--tags")
    local_nonpersistent_flags+=("--tags=")
    flags+=("--timeout=")
    two_word_flags+=("--timeout")
    local_nonpersistent_flags+=("--timeout=")
    flags+=("--version=")
    two_word_flags+=("--version")
    local_nonpersistent_flags+=("--version=")
    flags+=("--vpc-cidr=")
    two_word_flags+=("--vpc-cidr")
    local_nonpersistent_flags+=("--vpc-cidr=")
    flags+=("--vpc-from-kops-cluster=")
    two_word_flags+=("--vpc-from-kops-cluster")
    local_nonpersistent_flags+=("--vpc-from-kops-cluster=")
    flags+=("--vpc-nat-mode=")
    two_word_flags+=("--vpc-nat-mode")
    local_nonpersistent_flags+=("--vpc-nat-mode=")
    flags+=("--vpc-private-subnets=")
    two_word_flags+=("--vpc-private-subnets")
    local_nonpersistent_flags+=("--vpc-private-subnets=")
    flags+=("--vpc-public-subnets=")
    two_word_flags+=("--vpc-public-subnets")
    local_nonpersistent_flags+=("--vpc-public-subnets=")
    flags+=("--without-nodegroup")
    local_nonpersistent_flags+=("--without-nodegroup")
    flags+=("--write-kubeconfig")
    local_nonpersistent_flags+=("--write-kubeconfig")
    flags+=("--zones=")
    two_word_flags+=("--zones")
    local_nonpersistent_flags+=("--zones=")
    flags+=("--color=")
    two_word_flags+=("--color")
    two_word_flags+=("-C")
    flags+=("--help")
    flags+=("-h")
    flags+=("--verbose=")
    two_word_flags+=("--verbose")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_eksctl_create_nodegroup()
{
    last_command="eksctl_create_nodegroup"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--alb-ingress-access")
    local_nonpersistent_flags+=("--alb-ingress-access")
    flags+=("--appmesh-access")
    local_nonpersistent_flags+=("--appmesh-access")
    flags+=("--asg-access")
    local_nonpersistent_flags+=("--asg-access")
    flags+=("--cfn-role-arn=")
    two_word_flags+=("--cfn-role-arn")
    local_nonpersistent_flags+=("--cfn-role-arn=")
    flags+=("--cluster=")
    two_word_flags+=("--cluster")
    local_nonpersistent_flags+=("--cluster=")
    flags+=("--config-file=")
    two_word_flags+=("--config-file")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--config-file=")
    flags+=("--exclude=")
    two_word_flags+=("--exclude")
    local_nonpersistent_flags+=("--exclude=")
    flags+=("--external-dns-access")
    local_nonpersistent_flags+=("--external-dns-access")
    flags+=("--full-ecr-access")
    local_nonpersistent_flags+=("--full-ecr-access")
    flags+=("--include=")
    two_word_flags+=("--include")
    local_nonpersistent_flags+=("--include=")
    flags+=("--max-pods-per-node=")
    two_word_flags+=("--max-pods-per-node")
    local_nonpersistent_flags+=("--max-pods-per-node=")
    flags+=("--name=")
    two_word_flags+=("--name")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--name=")
    flags+=("--node-ami=")
    two_word_flags+=("--node-ami")
    local_nonpersistent_flags+=("--node-ami=")
    flags+=("--node-ami-family=")
    two_word_flags+=("--node-ami-family")
    local_nonpersistent_flags+=("--node-ami-family=")
    flags+=("--node-labels=")
    two_word_flags+=("--node-labels")
    local_nonpersistent_flags+=("--node-labels=")
    flags+=("--node-private-networking")
    flags+=("-P")
    local_nonpersistent_flags+=("--node-private-networking")
    flags+=("--node-security-groups=")
    two_word_flags+=("--node-security-groups")
    local_nonpersistent_flags+=("--node-security-groups=")
    flags+=("--node-type=")
    two_word_flags+=("--node-type")
    two_word_flags+=("-t")
    local_nonpersistent_flags+=("--node-type=")
    flags+=("--node-volume-size=")
    two_word_flags+=("--node-volume-size")
    local_nonpersistent_flags+=("--node-volume-size=")
    flags+=("--node-volume-type=")
    two_word_flags+=("--node-volume-type")
    local_nonpersistent_flags+=("--node-volume-type=")
    flags+=("--node-zones=")
    two_word_flags+=("--node-zones")
    local_nonpersistent_flags+=("--node-zones=")
    flags+=("--nodes=")
    two_word_flags+=("--nodes")
    two_word_flags+=("-N")
    local_nonpersistent_flags+=("--nodes=")
    flags+=("--nodes-max=")
    two_word_flags+=("--nodes-max")
    two_word_flags+=("-M")
    local_nonpersistent_flags+=("--nodes-max=")
    flags+=("--nodes-min=")
    two_word_flags+=("--nodes-min")
    two_word_flags+=("-m")
    local_nonpersistent_flags+=("--nodes-min=")
    flags+=("--profile=")
    two_word_flags+=("--profile")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--profile=")
    flags+=("--region=")
    two_word_flags+=("--region")
    two_word_flags+=("-r")
    local_nonpersistent_flags+=("--region=")
    flags+=("--ssh-access")
    local_nonpersistent_flags+=("--ssh-access")
    flags+=("--ssh-public-key=")
    two_word_flags+=("--ssh-public-key")
    local_nonpersistent_flags+=("--ssh-public-key=")
    flags+=("--timeout=")
    two_word_flags+=("--timeout")
    local_nonpersistent_flags+=("--timeout=")
    flags+=("--update-auth-configmap")
    local_nonpersistent_flags+=("--update-auth-configmap")
    flags+=("--version=")
    two_word_flags+=("--version")
    local_nonpersistent_flags+=("--version=")
    flags+=("--color=")
    two_word_flags+=("--color")
    two_word_flags+=("-C")
    flags+=("--help")
    flags+=("-h")
    flags+=("--verbose=")
    two_word_flags+=("--verbose")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_eksctl_create_iamidentitymapping()
{
    last_command="eksctl_create_iamidentitymapping"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config-file=")
    two_word_flags+=("--config-file")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--config-file=")
    flags+=("--group=")
    two_word_flags+=("--group")
    local_nonpersistent_flags+=("--group=")
    flags+=("--name=")
    two_word_flags+=("--name")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--name=")
    flags+=("--profile=")
    two_word_flags+=("--profile")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--profile=")
    flags+=("--region=")
    two_word_flags+=("--region")
    two_word_flags+=("-r")
    local_nonpersistent_flags+=("--region=")
    flags+=("--role=")
    two_word_flags+=("--role")
    local_nonpersistent_flags+=("--role=")
    flags+=("--timeout=")
    two_word_flags+=("--timeout")
    local_nonpersistent_flags+=("--timeout=")
    flags+=("--username=")
    two_word_flags+=("--username")
    local_nonpersistent_flags+=("--username=")
    flags+=("--color=")
    two_word_flags+=("--color")
    two_word_flags+=("-C")
    flags+=("--help")
    flags+=("-h")
    flags+=("--verbose=")
    two_word_flags+=("--verbose")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_eksctl_create()
{
    last_command="eksctl_create"

    command_aliases=()

    commands=()
    commands+=("cluster")
    commands+=("nodegroup")
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        command_aliases+=("ng")
        aliashash["ng"]="nodegroup"
    fi
    commands+=("iamidentitymapping")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--color=")
    two_word_flags+=("--color")
    two_word_flags+=("-C")
    flags+=("--help")
    flags+=("-h")
    flags+=("--verbose=")
    two_word_flags+=("--verbose")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_eksctl_get_cluster()
{
    last_command="eksctl_get_cluster"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all-regions")
    flags+=("-A")
    local_nonpersistent_flags+=("--all-regions")
    flags+=("--chunk-size=")
    two_word_flags+=("--chunk-size")
    local_nonpersistent_flags+=("--chunk-size=")
    flags+=("--name=")
    two_word_flags+=("--name")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--name=")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    local_nonpersistent_flags+=("--output=")
    flags+=("--profile=")
    two_word_flags+=("--profile")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--profile=")
    flags+=("--region=")
    two_word_flags+=("--region")
    two_word_flags+=("-r")
    local_nonpersistent_flags+=("--region=")
    flags+=("--timeout=")
    two_word_flags+=("--timeout")
    local_nonpersistent_flags+=("--timeout=")
    flags+=("--color=")
    two_word_flags+=("--color")
    two_word_flags+=("-C")
    flags+=("--help")
    flags+=("-h")
    flags+=("--verbose=")
    two_word_flags+=("--verbose")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_eksctl_get_nodegroup()
{
    last_command="eksctl_get_nodegroup"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--chunk-size=")
    two_word_flags+=("--chunk-size")
    local_nonpersistent_flags+=("--chunk-size=")
    flags+=("--cluster=")
    two_word_flags+=("--cluster")
    local_nonpersistent_flags+=("--cluster=")
    flags+=("--name=")
    two_word_flags+=("--name")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--name=")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    local_nonpersistent_flags+=("--output=")
    flags+=("--profile=")
    two_word_flags+=("--profile")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--profile=")
    flags+=("--region=")
    two_word_flags+=("--region")
    two_word_flags+=("-r")
    local_nonpersistent_flags+=("--region=")
    flags+=("--timeout=")
    two_word_flags+=("--timeout")
    local_nonpersistent_flags+=("--timeout=")
    flags+=("--color=")
    two_word_flags+=("--color")
    two_word_flags+=("-C")
    flags+=("--help")
    flags+=("-h")
    flags+=("--verbose=")
    two_word_flags+=("--verbose")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_eksctl_get_iamidentitymapping()
{
    last_command="eksctl_get_iamidentitymapping"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--chunk-size=")
    two_word_flags+=("--chunk-size")
    local_nonpersistent_flags+=("--chunk-size=")
    flags+=("--config-file=")
    two_word_flags+=("--config-file")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--config-file=")
    flags+=("--name=")
    two_word_flags+=("--name")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--name=")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    local_nonpersistent_flags+=("--output=")
    flags+=("--profile=")
    two_word_flags+=("--profile")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--profile=")
    flags+=("--region=")
    two_word_flags+=("--region")
    two_word_flags+=("-r")
    local_nonpersistent_flags+=("--region=")
    flags+=("--role=")
    two_word_flags+=("--role")
    local_nonpersistent_flags+=("--role=")
    flags+=("--timeout=")
    two_word_flags+=("--timeout")
    local_nonpersistent_flags+=("--timeout=")
    flags+=("--color=")
    two_word_flags+=("--color")
    two_word_flags+=("-C")
    flags+=("--help")
    flags+=("-h")
    flags+=("--verbose=")
    two_word_flags+=("--verbose")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_eksctl_get()
{
    last_command="eksctl_get"

    command_aliases=()

    commands=()
    commands+=("cluster")
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        command_aliases+=("clusters")
        aliashash["clusters"]="cluster"
    fi
    commands+=("nodegroup")
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        command_aliases+=("ng")
        aliashash["ng"]="nodegroup"
        command_aliases+=("nodegroups")
        aliashash["nodegroups"]="nodegroup"
    fi
    commands+=("iamidentitymapping")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--color=")
    two_word_flags+=("--color")
    two_word_flags+=("-C")
    flags+=("--help")
    flags+=("-h")
    flags+=("--verbose=")
    two_word_flags+=("--verbose")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_eksctl_update_cluster()
{
    last_command="eksctl_update_cluster"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--approve")
    local_nonpersistent_flags+=("--approve")
    flags+=("--config-file=")
    two_word_flags+=("--config-file")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--config-file=")
    flags+=("--name=")
    two_word_flags+=("--name")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--name=")
    flags+=("--profile=")
    two_word_flags+=("--profile")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--profile=")
    flags+=("--region=")
    two_word_flags+=("--region")
    two_word_flags+=("-r")
    local_nonpersistent_flags+=("--region=")
    flags+=("--timeout=")
    two_word_flags+=("--timeout")
    local_nonpersistent_flags+=("--timeout=")
    flags+=("--wait")
    flags+=("-w")
    local_nonpersistent_flags+=("--wait")
    flags+=("--color=")
    two_word_flags+=("--color")
    two_word_flags+=("-C")
    flags+=("--help")
    flags+=("-h")
    flags+=("--verbose=")
    two_word_flags+=("--verbose")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_eksctl_update()
{
    last_command="eksctl_update"

    command_aliases=()

    commands=()
    commands+=("cluster")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--color=")
    two_word_flags+=("--color")
    two_word_flags+=("-C")
    flags+=("--help")
    flags+=("-h")
    flags+=("--verbose=")
    two_word_flags+=("--verbose")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_eksctl_delete_cluster()
{
    last_command="eksctl_delete_cluster"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cfn-role-arn=")
    two_word_flags+=("--cfn-role-arn")
    local_nonpersistent_flags+=("--cfn-role-arn=")
    flags+=("--config-file=")
    two_word_flags+=("--config-file")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--config-file=")
    flags+=("--name=")
    two_word_flags+=("--name")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--name=")
    flags+=("--profile=")
    two_word_flags+=("--profile")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--profile=")
    flags+=("--region=")
    two_word_flags+=("--region")
    two_word_flags+=("-r")
    local_nonpersistent_flags+=("--region=")
    flags+=("--timeout=")
    two_word_flags+=("--timeout")
    local_nonpersistent_flags+=("--timeout=")
    flags+=("--wait")
    flags+=("-w")
    local_nonpersistent_flags+=("--wait")
    flags+=("--color=")
    two_word_flags+=("--color")
    two_word_flags+=("-C")
    flags+=("--help")
    flags+=("-h")
    flags+=("--verbose=")
    two_word_flags+=("--verbose")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_eksctl_delete_nodegroup()
{
    last_command="eksctl_delete_nodegroup"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--approve")
    local_nonpersistent_flags+=("--approve")
    flags+=("--cfn-role-arn=")
    two_word_flags+=("--cfn-role-arn")
    local_nonpersistent_flags+=("--cfn-role-arn=")
    flags+=("--cluster=")
    two_word_flags+=("--cluster")
    local_nonpersistent_flags+=("--cluster=")
    flags+=("--config-file=")
    two_word_flags+=("--config-file")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--config-file=")
    flags+=("--drain")
    local_nonpersistent_flags+=("--drain")
    flags+=("--exclude=")
    two_word_flags+=("--exclude")
    local_nonpersistent_flags+=("--exclude=")
    flags+=("--include=")
    two_word_flags+=("--include")
    local_nonpersistent_flags+=("--include=")
    flags+=("--name=")
    two_word_flags+=("--name")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--name=")
    flags+=("--only-missing")
    local_nonpersistent_flags+=("--only-missing")
    flags+=("--profile=")
    two_word_flags+=("--profile")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--profile=")
    flags+=("--region=")
    two_word_flags+=("--region")
    two_word_flags+=("-r")
    local_nonpersistent_flags+=("--region=")
    flags+=("--timeout=")
    two_word_flags+=("--timeout")
    local_nonpersistent_flags+=("--timeout=")
    flags+=("--update-auth-configmap")
    local_nonpersistent_flags+=("--update-auth-configmap")
    flags+=("--wait")
    flags+=("-w")
    local_nonpersistent_flags+=("--wait")
    flags+=("--color=")
    two_word_flags+=("--color")
    two_word_flags+=("-C")
    flags+=("--help")
    flags+=("-h")
    flags+=("--verbose=")
    two_word_flags+=("--verbose")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_eksctl_delete_iamidentitymapping()
{
    last_command="eksctl_delete_iamidentitymapping"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all")
    local_nonpersistent_flags+=("--all")
    flags+=("--config-file=")
    two_word_flags+=("--config-file")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--config-file=")
    flags+=("--name=")
    two_word_flags+=("--name")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--name=")
    flags+=("--profile=")
    two_word_flags+=("--profile")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--profile=")
    flags+=("--region=")
    two_word_flags+=("--region")
    two_word_flags+=("-r")
    local_nonpersistent_flags+=("--region=")
    flags+=("--role=")
    two_word_flags+=("--role")
    local_nonpersistent_flags+=("--role=")
    flags+=("--timeout=")
    two_word_flags+=("--timeout")
    local_nonpersistent_flags+=("--timeout=")
    flags+=("--color=")
    two_word_flags+=("--color")
    two_word_flags+=("-C")
    flags+=("--help")
    flags+=("-h")
    flags+=("--verbose=")
    two_word_flags+=("--verbose")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_eksctl_delete()
{
    last_command="eksctl_delete"

    command_aliases=()

    commands=()
    commands+=("cluster")
    commands+=("nodegroup")
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        command_aliases+=("ng")
        aliashash["ng"]="nodegroup"
    fi
    commands+=("iamidentitymapping")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--color=")
    two_word_flags+=("--color")
    two_word_flags+=("-C")
    flags+=("--help")
    flags+=("-h")
    flags+=("--verbose=")
    two_word_flags+=("--verbose")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_eksctl_scale_nodegroup()
{
    last_command="eksctl_scale_nodegroup"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cfn-role-arn=")
    two_word_flags+=("--cfn-role-arn")
    local_nonpersistent_flags+=("--cfn-role-arn=")
    flags+=("--cluster=")
    two_word_flags+=("--cluster")
    local_nonpersistent_flags+=("--cluster=")
    flags+=("--name=")
    two_word_flags+=("--name")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--name=")
    flags+=("--nodes=")
    two_word_flags+=("--nodes")
    two_word_flags+=("-N")
    local_nonpersistent_flags+=("--nodes=")
    flags+=("--profile=")
    two_word_flags+=("--profile")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--profile=")
    flags+=("--region=")
    two_word_flags+=("--region")
    two_word_flags+=("-r")
    local_nonpersistent_flags+=("--region=")
    flags+=("--timeout=")
    two_word_flags+=("--timeout")
    local_nonpersistent_flags+=("--timeout=")
    flags+=("--color=")
    two_word_flags+=("--color")
    two_word_flags+=("-C")
    flags+=("--help")
    flags+=("-h")
    flags+=("--verbose=")
    two_word_flags+=("--verbose")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_eksctl_scale()
{
    last_command="eksctl_scale"

    command_aliases=()

    commands=()
    commands+=("nodegroup")
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        command_aliases+=("ng")
        aliashash["ng"]="nodegroup"
    fi

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--color=")
    two_word_flags+=("--color")
    two_word_flags+=("-C")
    flags+=("--help")
    flags+=("-h")
    flags+=("--verbose=")
    two_word_flags+=("--verbose")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_eksctl_drain_nodegroup()
{
    last_command="eksctl_drain_nodegroup"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--approve")
    local_nonpersistent_flags+=("--approve")
    flags+=("--cfn-role-arn=")
    two_word_flags+=("--cfn-role-arn")
    local_nonpersistent_flags+=("--cfn-role-arn=")
    flags+=("--cluster=")
    two_word_flags+=("--cluster")
    local_nonpersistent_flags+=("--cluster=")
    flags+=("--config-file=")
    two_word_flags+=("--config-file")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--config-file=")
    flags+=("--exclude=")
    two_word_flags+=("--exclude")
    local_nonpersistent_flags+=("--exclude=")
    flags+=("--include=")
    two_word_flags+=("--include")
    local_nonpersistent_flags+=("--include=")
    flags+=("--name=")
    two_word_flags+=("--name")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--name=")
    flags+=("--only-missing")
    local_nonpersistent_flags+=("--only-missing")
    flags+=("--profile=")
    two_word_flags+=("--profile")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--profile=")
    flags+=("--region=")
    two_word_flags+=("--region")
    two_word_flags+=("-r")
    local_nonpersistent_flags+=("--region=")
    flags+=("--timeout=")
    two_word_flags+=("--timeout")
    local_nonpersistent_flags+=("--timeout=")
    flags+=("--undo")
    local_nonpersistent_flags+=("--undo")
    flags+=("--color=")
    two_word_flags+=("--color")
    two_word_flags+=("-C")
    flags+=("--help")
    flags+=("-h")
    flags+=("--verbose=")
    two_word_flags+=("--verbose")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_eksctl_drain()
{
    last_command="eksctl_drain"

    command_aliases=()

    commands=()
    commands+=("nodegroup")
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        command_aliases+=("ng")
        aliashash["ng"]="nodegroup"
    fi

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--color=")
    two_word_flags+=("--color")
    two_word_flags+=("-C")
    flags+=("--help")
    flags+=("-h")
    flags+=("--verbose=")
    two_word_flags+=("--verbose")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_eksctl_utils_wait-nodes()
{
    last_command="eksctl_utils_wait-nodes"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--nodes-min=")
    two_word_flags+=("--nodes-min")
    two_word_flags+=("-m")
    local_nonpersistent_flags+=("--nodes-min=")
    flags+=("--timeout=")
    two_word_flags+=("--timeout")
    local_nonpersistent_flags+=("--timeout=")
    flags+=("--color=")
    two_word_flags+=("--color")
    two_word_flags+=("-C")
    flags+=("--help")
    flags+=("-h")
    flags+=("--verbose=")
    two_word_flags+=("--verbose")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_eksctl_utils_write-kubeconfig()
{
    last_command="eksctl_utils_write-kubeconfig"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--authenticator-role-arn=")
    two_word_flags+=("--authenticator-role-arn")
    local_nonpersistent_flags+=("--authenticator-role-arn=")
    flags+=("--auto-kubeconfig")
    local_nonpersistent_flags+=("--auto-kubeconfig")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--name=")
    two_word_flags+=("--name")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--name=")
    flags+=("--profile=")
    two_word_flags+=("--profile")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--profile=")
    flags+=("--region=")
    two_word_flags+=("--region")
    two_word_flags+=("-r")
    local_nonpersistent_flags+=("--region=")
    flags+=("--set-kubeconfig-context")
    local_nonpersistent_flags+=("--set-kubeconfig-context")
    flags+=("--timeout=")
    two_word_flags+=("--timeout")
    local_nonpersistent_flags+=("--timeout=")
    flags+=("--color=")
    two_word_flags+=("--color")
    two_word_flags+=("-C")
    flags+=("--help")
    flags+=("-h")
    flags+=("--verbose=")
    two_word_flags+=("--verbose")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_eksctl_utils_describe-stacks()
{
    last_command="eksctl_utils_describe-stacks"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all")
    local_nonpersistent_flags+=("--all")
    flags+=("--events")
    local_nonpersistent_flags+=("--events")
    flags+=("--name=")
    two_word_flags+=("--name")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--name=")
    flags+=("--profile=")
    two_word_flags+=("--profile")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--profile=")
    flags+=("--region=")
    two_word_flags+=("--region")
    two_word_flags+=("-r")
    local_nonpersistent_flags+=("--region=")
    flags+=("--timeout=")
    two_word_flags+=("--timeout")
    local_nonpersistent_flags+=("--timeout=")
    flags+=("--trail")
    local_nonpersistent_flags+=("--trail")
    flags+=("--color=")
    two_word_flags+=("--color")
    two_word_flags+=("-C")
    flags+=("--help")
    flags+=("-h")
    flags+=("--verbose=")
    two_word_flags+=("--verbose")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_eksctl_utils_update-cluster-stack()
{
    last_command="eksctl_utils_update-cluster-stack"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--color=")
    two_word_flags+=("--color")
    two_word_flags+=("-C")
    flags+=("--help")
    flags+=("-h")
    flags+=("--verbose=")
    two_word_flags+=("--verbose")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_eksctl_utils_update-kube-proxy()
{
    last_command="eksctl_utils_update-kube-proxy"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--approve")
    local_nonpersistent_flags+=("--approve")
    flags+=("--config-file=")
    two_word_flags+=("--config-file")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--config-file=")
    flags+=("--name=")
    two_word_flags+=("--name")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--name=")
    flags+=("--profile=")
    two_word_flags+=("--profile")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--profile=")
    flags+=("--region=")
    two_word_flags+=("--region")
    two_word_flags+=("-r")
    local_nonpersistent_flags+=("--region=")
    flags+=("--timeout=")
    two_word_flags+=("--timeout")
    local_nonpersistent_flags+=("--timeout=")
    flags+=("--color=")
    two_word_flags+=("--color")
    two_word_flags+=("-C")
    flags+=("--help")
    flags+=("-h")
    flags+=("--verbose=")
    two_word_flags+=("--verbose")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_eksctl_utils_update-aws-node()
{
    last_command="eksctl_utils_update-aws-node"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--approve")
    local_nonpersistent_flags+=("--approve")
    flags+=("--config-file=")
    two_word_flags+=("--config-file")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--config-file=")
    flags+=("--name=")
    two_word_flags+=("--name")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--name=")
    flags+=("--profile=")
    two_word_flags+=("--profile")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--profile=")
    flags+=("--region=")
    two_word_flags+=("--region")
    two_word_flags+=("-r")
    local_nonpersistent_flags+=("--region=")
    flags+=("--timeout=")
    two_word_flags+=("--timeout")
    local_nonpersistent_flags+=("--timeout=")
    flags+=("--color=")
    two_word_flags+=("--color")
    two_word_flags+=("-C")
    flags+=("--help")
    flags+=("-h")
    flags+=("--verbose=")
    two_word_flags+=("--verbose")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_eksctl_utils_update-coredns()
{
    last_command="eksctl_utils_update-coredns"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--approve")
    local_nonpersistent_flags+=("--approve")
    flags+=("--config-file=")
    two_word_flags+=("--config-file")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--config-file=")
    flags+=("--name=")
    two_word_flags+=("--name")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--name=")
    flags+=("--profile=")
    two_word_flags+=("--profile")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--profile=")
    flags+=("--region=")
    two_word_flags+=("--region")
    two_word_flags+=("-r")
    local_nonpersistent_flags+=("--region=")
    flags+=("--timeout=")
    two_word_flags+=("--timeout")
    local_nonpersistent_flags+=("--timeout=")
    flags+=("--color=")
    two_word_flags+=("--color")
    two_word_flags+=("-C")
    flags+=("--help")
    flags+=("-h")
    flags+=("--verbose=")
    two_word_flags+=("--verbose")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_eksctl_utils_update-cluster-logging()
{
    last_command="eksctl_utils_update-cluster-logging"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--approve")
    local_nonpersistent_flags+=("--approve")
    flags+=("--config-file=")
    two_word_flags+=("--config-file")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--config-file=")
    flags+=("--disable-types=")
    two_word_flags+=("--disable-types")
    local_nonpersistent_flags+=("--disable-types=")
    flags+=("--enable-types=")
    two_word_flags+=("--enable-types")
    local_nonpersistent_flags+=("--enable-types=")
    flags+=("--name=")
    two_word_flags+=("--name")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--name=")
    flags+=("--profile=")
    two_word_flags+=("--profile")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--profile=")
    flags+=("--region=")
    two_word_flags+=("--region")
    two_word_flags+=("-r")
    local_nonpersistent_flags+=("--region=")
    flags+=("--timeout=")
    two_word_flags+=("--timeout")
    local_nonpersistent_flags+=("--timeout=")
    flags+=("--color=")
    two_word_flags+=("--color")
    two_word_flags+=("-C")
    flags+=("--help")
    flags+=("-h")
    flags+=("--verbose=")
    two_word_flags+=("--verbose")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_eksctl_utils()
{
    last_command="eksctl_utils"

    command_aliases=()

    commands=()
    commands+=("wait-nodes")
    commands+=("write-kubeconfig")
    commands+=("describe-stacks")
    commands+=("update-cluster-stack")
    commands+=("update-kube-proxy")
    commands+=("update-aws-node")
    commands+=("update-coredns")
    commands+=("update-cluster-logging")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--color=")
    two_word_flags+=("--color")
    two_word_flags+=("-C")
    flags+=("--help")
    flags+=("-h")
    flags+=("--verbose=")
    two_word_flags+=("--verbose")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_eksctl_completion_bash()
{
    last_command="eksctl_completion_bash"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--color=")
    two_word_flags+=("--color")
    two_word_flags+=("-C")
    flags+=("--help")
    flags+=("-h")
    flags+=("--verbose=")
    two_word_flags+=("--verbose")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_eksctl_completion_zsh()
{
    last_command="eksctl_completion_zsh"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--color=")
    two_word_flags+=("--color")
    two_word_flags+=("-C")
    flags+=("--help")
    flags+=("-h")
    flags+=("--verbose=")
    two_word_flags+=("--verbose")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_eksctl_completion()
{
    last_command="eksctl_completion"

    command_aliases=()

    commands=()
    commands+=("bash")
    commands+=("zsh")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--color=")
    two_word_flags+=("--color")
    two_word_flags+=("-C")
    flags+=("--help")
    flags+=("-h")
    flags+=("--verbose=")
    two_word_flags+=("--verbose")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_eksctl_version()
{
    last_command="eksctl_version"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--color=")
    two_word_flags+=("--color")
    two_word_flags+=("-C")
    flags+=("--help")
    flags+=("-h")
    flags+=("--verbose=")
    two_word_flags+=("--verbose")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_eksctl_root_command()
{
    last_command="eksctl"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("get")
    commands+=("update")
    commands+=("delete")
    commands+=("scale")
    commands+=("drain")
    commands+=("utils")
    commands+=("completion")
    commands+=("version")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--color=")
    two_word_flags+=("--color")
    two_word_flags+=("-C")
    flags+=("--help")
    flags+=("-h")
    flags+=("--verbose=")
    two_word_flags+=("--verbose")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

__start_eksctl()
{
    local cur prev words cword
    declare -A flaghash 2>/dev/null || :
    declare -A aliashash 2>/dev/null || :
    if declare -F _init_completion >/dev/null 2>&1; then
        _init_completion -s || return
    else
        __eksctl_init_completion -n "=" || return
    fi

    local c=0
    local flags=()
    local two_word_flags=()
    local local_nonpersistent_flags=()
    local flags_with_completion=()
    local flags_completion=()
    local commands=("eksctl")
    local must_have_one_flag=()
    local must_have_one_noun=()
    local last_command
    local nouns=()

    __eksctl_handle_word
}

if [[ $(type -t compopt) = "builtin" ]]; then
    complete -o default -F __start_eksctl eksctl
else
    complete -o default -o nospace -F __start_eksctl eksctl
fi

# ex: ts=4 sw=4 et filetype=sh
