#!/usr/bin/env bash

set -euo pipefail

usage() {
    echo "Usage: $(basename "$0") EMAIL [HOST]"
    echo
    echo "Create a session by POSTing an email to the /session endpoint."
    echo
    echo "Arguments:"
    echo "  EMAIL    Email address to create a session for (required)"
    echo "  HOST     Server host (default: localhost:3000)"
    echo
    echo "Examples:"
    echo "  $(basename "$0") user@example.com"
    echo "  $(basename "$0") user@example.com registry.gren-lang.org"
}

if [ $# -lt 1 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
    [ "$#" -lt 1 ] && exit 1
    exit 0
fi

EMAIL="$1"
HOST="${2:-localhost:3000}"

curl -sS --fail -X POST "http://${HOST}/session" \
    -H "Content-Type: application/json" \
    -d "{\"email\": \"${EMAIL}\"}" | jq .
