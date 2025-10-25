#!/bin/sh
set -e

db-wait.sh "$DB_HOST:$DB_PORT"
db-wait.sh "$FCREPO_HOST:$FCREPO_PORT"
db-wait.sh "$SOLR_HOST:$SOLR_PORT"

bundle exec rails morphosource:to_stdout morphosource:docker_test_setup
NODE_ENV=test RAILS_ENV=test yarn webpack --config config/webpack/test.js
