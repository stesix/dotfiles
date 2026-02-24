#!/usr/bin/env bash

# Load AzureDevOps credentials into environment
function azdo_auth() {
    local token
    token="$(keepassxc-cli show --key-file ${KEEPASS_KEY} -a PASSWORD ${KEEPASS_DB} ${KEEPASS_AZDO_NAME})"
    export AZURE_ACCESS_TOKEN="$token"
    export PIP_EXTRA_INDEX_URL="https://${AZURE_USER_NAME}:${AZURE_ACCESS_TOKEN}@${AZDO_CHANNEL}"
}

function azdo_openai() {
    local key
    key="$(keepassxc-cli show --key-file ${KEEPASS_KEY} -a PASSWORD ${KEEPASS_DB} ${KEEPASS_AZOPENAI_NAME})"
    export AZURE_API_KEY="$key"
    export AZURE_OPENAI_API_KEY="${AZURE_API_KEY}"
}

function azdo_terraform() {
    local pat
    pat="$(keepassxc-cli show --key-file ${KEEPASS_KEY} -a PASSWORD ${KEEPASS_DB} ${KEEPASS_AZDO_PAT})"
    export AZDO_PERSONAL_ACCESS_TOKEN="$pat"
}
