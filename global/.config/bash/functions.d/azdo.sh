#!/usr/bin/env bash

# Load AzureDevOps credentials into environment
function azdo_auth() {
    export AZURE_ACCESS_TOKEN="$(keepassxc-cli show --key-file ${KEEPASS_KEY} -a PASSWORD ${KEEPASS_DB} ${KEEPASS_AZDO_NAME})"
    export PIP_EXTRA_INDEX_URL="${AZURE_USER_NAME}:${AZURE_ACCESS_TOKEN}@${AZDO_CHANNEL}"
}
