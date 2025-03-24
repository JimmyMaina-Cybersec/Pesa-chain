#!/bin/bash

function list_tree() {
    local path=$1
    echo "Checking path: $path"  # Debugging line

    local keys=$(vault list -format=json "$path" 2>/dev/null | jq -r '.[]')

    if [[ -z "$keys" ]]; then
        echo "No keys found at: $path"  # Debugging line
        return
    fi

    for key in $keys; do
        if [[ "$key" == */ ]]; then
            echo "Directory: $path$key"
            list_tree "$path$key"
        else
            echo "Key: $path$key"
        fi
    done
}

list_tree "secret/crypto"
