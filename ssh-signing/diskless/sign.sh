#!/bin/bash

# NOTE: This requires the CA_PRIVATE_KEY_CONTENTS and USER_PUBLIC_KEY_CONTENTS
# environment variables to be set

set -ue

# Generate dynamic pipe names
CA_PRIVATE_KEY=$(uuidgen)
USER_KEY_ID=$(uuidgen)
USER_PUBLIC_KEY=${USER_KEY_ID}.pub
USER_PUBLIC_KEY_SIGNED=${USER_KEY_ID}-cert.pub

# Create named pipes
mkfifo -m 0600 ${CA_PRIVATE_KEY} ${USER_PUBLIC_KEY} ${USER_PUBLIC_KEY_SIGNED}

# Write private key from environment to pipe and background
echo "${CA_PRIVATE_KEY_CONTENTS}" > ${CA_PRIVATE_KEY} &

# Write public key from environment to pipe and background
echo "${USER_PUBLIC_KEY_CONTENTS}" > ${USER_PUBLIC_KEY} &

# Sign the key and background
(echo 'y' \
    | ssh-keygen \
        -I "Signed by myca" \
        -n "group1,group2" \
        -s ${CA_PRIVATE_KEY} \
        -V '+1h' \
        -z $(date '+%s') \
        ${USER_PUBLIC_KEY} 2>/dev/null
)&

# Read in the the signed key from the pipe
SIGNED_KEY_CONTENTS=$(cat < ${USER_PUBLIC_KEY_SIGNED})

# Delete named pipes
rm ${CA_PRIVATE_KEY} ${USER_PUBLIC_KEY} ${USER_PUBLIC_KEY_SIGNED}

# Format output
JSON_STRING=$(jq -n \
    --arg signed "${SIGNED_KEY_CONTENTS}" \
    '{user_public_key_signed: $signed}' \
)

echo ${JSON_STRING}
