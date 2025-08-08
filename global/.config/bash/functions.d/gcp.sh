#!/usr/bin/env bash

function gcp_auth() {
    local user="$1"

    if [ -z "$user" ] ; then
        echo "Usage: gcp_auth user_id"
        return 1
    fi
    keepassxc-cli attachment-export --key-file ${KEEPASS_KEY} ${KEEPASS_DB} ${KEEPASS_GCP_ENTRY} "$1" ~/.config/gcloud/application_default_credentials.json
}
