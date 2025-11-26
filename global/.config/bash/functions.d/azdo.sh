#!/usr/bin/env bash

# Load AzureDevOps credentials into environment
function azdo_auth() {
    export AZURE_ACCESS_TOKEN="$(keepassxc-cli show --key-file ${KEEPASS_KEY} -a PASSWORD ${KEEPASS_DB} ${KEEPASS_AZDO_NAME})"
    export PIP_EXTRA_INDEX_URL="https://${AZURE_USER_NAME}:${AZURE_ACCESS_TOKEN}@${AZDO_CHANNEL}"
}

function azdo_openai() {
    export AZURE_API_KEY="$(keepassxc-cli show --key-file ${KEEPASS_KEY} -a PASSWORD ${KEEPASS_DB} ${KEEPASS_AZOPENAI_NAME})"
    export AZURE_OPENAI_API_KEY="${AZURE_API_KEY}"
}

function azdo_terraform() {
    export AZDO_PERSONAL_ACCESS_TOKEN="$(keepassxc-cli show --key-file ${KEEPASS_KEY} -a PASSWORD ${KEEPASS_DB} ${KEEPASS_AZDO_PAT})"
}
