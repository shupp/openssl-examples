#!/bin/bash

# Generate unique pipe name
PRIVATE_KEY=$(uuidgen)
PUBLIC_KEY=${PRIVATE_KEY}.pub

# Create named pipes
mkfifo ${PRIVATE_KEY} ${PUBLIC_KEY}

# Create private an dpublic keys writing to pipes and then background
(echo 'y' | ssh-keygen -f ${PRIVATE_KEY} -C "CA: myca" -b 2048 -V '-1d:+365d' -N '' > /dev/null)&

# Read in key contents from pipes
PRIVATE_KEY_CONTENTS=$(cat < ${PRIVATE_KEY})
PUBLIC_KEY_CONTENTS=$(cat < ${PUBLIC_KEY})

# Remove named pipes
rm ${PRIVATE_KEY} ${PUBLIC_KEY}

# Format output and then echo
JSON_STRING=$(jq -n \
    --arg priv "${PRIVATE_KEY_CONTENTS}" \
    --arg pub "${PUBLIC_KEY_CONTENTS}" \
    '{ca_private_key: $priv, ca_public_key: $pub}' \
)
echo ${JSON_STRING}
