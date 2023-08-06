#!/bin/sh

# Generate the homeserver.yaml file based on environment variables
envsubst < ./sygnal.yaml.template > ./sygnal.yaml

python -m sygnal.sygnal