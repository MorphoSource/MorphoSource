#!/bin/sh

# Run test suite from Docker container, requires postgres container also

set -e

bundle exec rails morphosource:to_stdout morphosource:docker_test_setup
bundle exec rspec spec --fail-fast