#!/usr/bin/env bash

# fail immediately if app doesn't build
make dist/app || exit 1

TEST_DB_PATH=./db/test.db
TEST_LOG_PATH=./log/test.log
TEST_POSTMARK_TOKEN=POSTMARK_API_TEST

export REGISTRY_DB_PATH="$TEST_DB_PATH"
export SERVER_LOG_PATH="$TEST_LOG_PATH"
export POSTMARK_SERVER_TOKEN="$TEST_POSTMARK_TOKEN"

# clear leftover state from previous runs
rm -f "$TEST_DB_PATH"
rm -f "$TEST_LOG_PATH"

# start app in background and run all tests
devbox services up -b && \
npx -y wait-on tcp:3000 -t 5s && \
make test
test_exit=$?

# shutdown backgrounded app
devbox services stop

exit $test_exit
