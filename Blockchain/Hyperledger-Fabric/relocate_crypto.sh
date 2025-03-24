#!/bin/bash
set -euo pipefail

# Directories containing crypto material
BASE_DIRS=("Pesachain" "org2" "orderer")

# List of file extensions to consider as crypto material.
FILE_EXTENSIONS=( "pem" "crt" "key" "sk" )

# Function to build the 'find' expression for file extensions
build_find_expr() {
    local expr=""
    for ext in "${FILE_EXTENSIONS[@]}"; do
        if [[ "$ext" == "sk" ]]; then
            expr+=" -iname \"*_${ext}\" -o"
        else
            expr+=" -iname \"*.${ext}\" -o"
        fi
    done
    # Remove the trailing -o
    echo "${expr% -o}"
}

# Build the file filter expression for find
FIND_EXPR=$(build_find_expr)

echo "Using file filter expression: $FIND_EXPR"

# Loop over each base directory
for base in "${BASE_DIRS[@]}"; do
    echo "Processing directory: $base"
    eval "find \"$base\" -type f \( $FIND_EXPR \)" | while IFS= read -r file; do
        # Derive a Vault path that mimics the directory structure.
        vault_path="secret/crypto/${file}"
        echo "Uploading $file to Vault path $vault_path"

        # Read file content
        content=$(<"$file")

        # Upload to Vault using the KV put command.
        vault kv put "$vault_path" content="$content"

        # Optionally remove the original file after a successful upload:
        # rm -f "$file"
    done
done

echo "All crypto material has been relocated to Vault."
