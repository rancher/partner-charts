#!/bin/bash

set -x

(set +x; codefresh auth create-context --api-key $API_KEY --url $API_HOST)

if [[ "$AGENT" == "true" ]]; then
    patch_type="re"
else
    patch_type="sys-re"
fi

modify_accounts() {
    local runtime_name_encoded
    runtime_name_encoded=$(yq -r '.metadata.name' "$1" | jq -Rr @uri)
    local accounts
    accounts=$(yq -o=json '.accounts' "$1")

    if [[ -n $accounts ]]; then
        local payload
        payload=$(echo "$accounts" | jq '{accounts: .}')
        set +x
        curl -X PUT \
            -H "Content-Type: application/json" \
            -H "Authorization: $API_KEY" \
            -d "$payload" \
            "$API_HOST/api/admin/runtime-environments/account/modify/$runtime_name_encoded"
    else
        echo "No accounts to add for $1"
    fi
}

for runtime in /opt/codefresh/*.yaml; do
    if [[ -f $runtime ]]; then
        codefresh patch $patch_type -f $runtime
        if [[ "$AGENT" == "false" ]]; then
            modify_accounts "$runtime"
        fi
    fi
done

for runtime in /opt/codefresh/runtime.d/system/*.yaml; do
    if [[ -f $runtime ]]; then
        codefresh patch sys-re -f $runtime
        modify_accounts "$runtime"
    fi
done
