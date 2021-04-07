#!/bin/bash

set -x

(cd /etc/ssh; ssh-keygen -A)

exec "$@"
