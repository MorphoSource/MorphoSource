#!/bin/sh
set -e

mkdir -p /app/samvera/hyrax-webapp/tmp/pids
rm -f /app/samvera/hyrax-webapp/tmp/pids/*

# This is here for local dev, to enable UV update on container start
/app/samvera/hyrax-webapp/bin/uv-install

echo "$@"
echo $PWD

# Run the command
exec "$@"
