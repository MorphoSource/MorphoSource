#!/bin/sh

# Run test suite from Docker container, requires postgres container also

set -e

bundle exec rails morphosource:to_stdout morphosource:docker_test_setup

case "$TEST_GROUP" in
  1)
    # Run test set 1
    echo "Running test group 1: controllers"
    bundle exec rspec spec/controllers --fail-fast
    ;;
  2)
    # Run test set 2
    echo "Running test group 2: actors, config, features, forms, gems, helpers, indexers, jobs, lib"
    bundle exec rspec spec/actors spec/config spec/features spec/forms spec/gems spec/helpers spec/indexers spec/jobs spec/lib --fail-fast
    ;;
  3)
    # Run test set 3
    echo "Running test group 3: models"
    bundle exec rspec spec/models --fail-fast
    ;;
  4)
    # Run test set 4
    echo "Running test group 4: presenters, renderers, routing, search_builders, services, tasks, views, vocabularies"
    bundle exec rspec spec/presenters spec/renderers spec/routing spec/search_builders spec/services spec/tasks spec/views spec/vocabularies --fail-fast --format documentation
    ;;
  *)
    # Fallback: Run all tests or a default set
    echo "No TEST_GROUP specified or unrecognized value. Running all tests."
    bundle exec rspec spec --fail-fast
    ;;
esac
