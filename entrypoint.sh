#!/bin/bash
set -e

npm install

npm run astro telemetry disable

# run passed commands
exec "$@"
