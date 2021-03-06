#!/bin/bash

set -ue

# Create CA and USER keys
CA_JSON=$(./create-ca.sh)
USER_JSON=$(./create-user.sh)

# Sign the user public key with the CA private key
export CA_PRIVATE_KEY_CONTENTS=$(echo "${CA_JSON}" | jq -r .ca_private_key)
export USER_PUBLIC_KEY_CONTENTS=$(echo "${USER_JSON}" | jq -r .user_public_key)
SIGNED_JSON=$(./sign.sh)

# Gather remaining contents for output
CA_PUBLIC_KEY_CONTENTS=$(echo "${CA_JSON}" | jq -r .ca_public_key)
USER_PRIVATE_KEY_CONTENTS=$(echo "${USER_JSON}" | jq -r .user_private_key)
USER_PUBLIC_KEY_CONTENTS=$(echo "${USER_JSON}" | jq -r .user_public_key)
USER_PUBLIC_KEY_SIGNED_CONTENTS=$(echo "${SIGNED_JSON}" | jq -r .user_public_key_signed)

# Format output
JSON_STRING=$(jq -n \
    --arg ca_priv "${CA_PRIVATE_KEY_CONTENTS}" \
    --arg ca_pub "${CA_PUBLIC_KEY_CONTENTS}" \
    --arg user_priv "${USER_PRIVATE_KEY_CONTENTS}" \
    --arg user_pub "${USER_PUBLIC_KEY_CONTENTS}" \
    --arg user_signed "${USER_PUBLIC_KEY_SIGNED_CONTENTS}" \
    '{ca_private_key: $ca_priv, ca_public_key: $ca_pub, user_private_key: $user_priv, user_public_key: $user_pub, user_public_key_signed: $user_signed}' \
)

echo ${JSON_STRING}
