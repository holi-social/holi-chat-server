#!/bin/bash

if [ -z "$1" -o -z "$2" -o -z "$3" ]; then
    echo "Usage: $0 <matrix server url> <secret> <password> [username]"
    echo ""
    echo "Creates a user with admin privileges on a Synapse server."
    echo "The secret is the registration_shared_secret from the Synapse config and can be found in Passbolt: HOLI_CHAT_REGISTRATION_SHARED_SECRET."
    echo "Username defaults to chat-admin."
    exit 1
fi

URL=$1
SECRET=$2
PASSWORD=$3
USERNAME="${4:-chat-admin}"
ADMIN="admin"

NONCE=$(curl $URL/_synapse/admin/v1/register | jq -r ".nonce")

HMAC=$(printf '%s\0%s\0%s\0%s' "$NONCE" "$USERNAME" "$PASSWORD" "$ADMIN" |
    openssl sha1 -hmac "$SECRET" |
    awk '{print $2}')

curl -X POST $URL/_synapse/admin/v1/register -H 'Content-Type: application/json' \
    -d "{ \"nonce\": \"$NONCE\", \"username\": \"$USERNAME\", \"password\": \"$PASSWORD\", \"admin\": true, \"mac\": \"$HMAC\" }"
