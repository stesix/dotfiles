#!/usr/bin/env bash

function find_store_subscription() {
    local store config_file subscription_prefix subscription_suffix

    store="$1"
    subscription_prefix="$2"

    subscription_suffix='subscription_id'

    if [[ -z "$store" ]]; then
        echo "Usage: find_store_subscription store_shortname"
        return 1
    fi

    config_file="$(grep '^service_nickname' "${CWL_REPO_PATH}"/cwl-dcsp/config/*.tfvars |
        grep '"'"${store}"'"' |
        cut -d: -f1)"

    echo "config_location       = $config_file"
    grep "$subscription_suffix" "$config_file"

    if [[ -z "$subscription_prefix" ]]; then
        return 0
    fi

    if [[ "$subscription_prefix" == "config_file" ]]; then
        echo -n "${config_file}"
    else
        grep "$subscription_suffix" "$config_file" | grep "^${subscription_prefix}" | cut -d'"' -f2 | tr -d '\n'
    fi | pbcopy
}
