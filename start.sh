#!/bin/sh

# Generate the homeserver.yaml file based on environment variables
envsubst < ./data/homeserver.yaml.template > ./data/homeserver.yaml

synctl --no-daemonize start ./data/homeserver.yaml