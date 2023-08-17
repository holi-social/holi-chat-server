#!/bin/sh

# Generate the homeserver.yaml file based on environment variables
envsubst < /data/sygnal.yaml.template > /data/sygnal.yaml

export SYGNAL_CONF=/data/sygnal.yaml
python -m sygnal.sygnal