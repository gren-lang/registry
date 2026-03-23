#!/usr/bin/env bash

set -euo pipefail

usage() {
    echo "Usage: $(basename "$0") FETCH_SESSION_TOKEN EMAIL_CONFIRMATION_CODE [HOST]"
    echo
    echo "Fetch a session token by POSTing a fetchSessionToken and emailConfirmationCode"
    echo "to the /session/fetch endpoint."
    echo
    echo "Arguments:"
    echo "  FETCH_SESSION_TOKEN       The fetch session token (required)"
    echo "  EMAIL_CONFIRMATION_CODE   The email confirmation code (required)"
    echo "  HOST                      Server host (default: localhost:3000)"
    echo
    echo "Examples:"
    echo "  $(basename "$0") abc-123 ABCD1234"
    echo "  $(basename "$0") abc-123 ABCD1234 registry.gren-lang.org"
}

if [ $# -lt 2 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
    [ "$#" -lt 2 ] && exit 1
    exit 0
fi

FETCH_SESSION_TOKEN="$1"
EMAIL_CONFIRMATION_CODE="$2"
HOST="${3:-localhost:3000}"

curl -sS -w "\nHTTP Status: %{http_code}\n" -o >(jq .) -X POST "http://${HOST}/session/fetch" \
    -H "Content-Type: application/json" \
    -d "{\"fetchSessionToken\": \"${FETCH_SESSION_TOKEN}\", \"emailConfirmationCode\": \"${EMAIL_CONFIRMATION_CODE}\"}"
