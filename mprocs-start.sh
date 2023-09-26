#!/bin/bash

# This file is used by the mprocs yaml files in https://gitlab.holi.team/app/holi-meta 

. ./.envrc.local
./generate-homeserver-config.sh
. ./.envrc-push-gateway.local
./generate-push-gateway-config.sh
docker compose rm -f
docker compose up
