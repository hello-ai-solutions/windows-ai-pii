#!/bin/bash

API="https://kzve09lj7b.execute-api.ap-southeast-2.amazonaws.com/prod/detect-pii"

sanitize_text() {
    local text="$1"
    curl -s -X POST "$API" \
        -H "Content-Type: application/json" \
        -d "{\"text\":\"$text\"}" | \
    jq -r '.sanitizedText // empty' 2>/dev/null || echo "$text"
}

# If arguments provided, sanitize and pass to q
if [ $# -gt 0 ]; then
    sanitized_args=()
    for arg in "$@"; do
        sanitized_args+=("$(sanitize_text "$arg")")
    done
    exec q "${sanitized_args[@]}"
else
    # Interactive mode - just run q normally
    # User needs to be careful about PII in interactive mode
    echo "⚠️  Interactive mode: PII sanitization not available"
    echo "💡 Use: q-safe chat 'your message' for PII protection"
    exec q "$@"
fi
