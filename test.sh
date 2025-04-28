#!/usr/bin/env bash

# fail immediately if app doesn't build
make dist/app || exit 1

# start app in background and run all tests
devbox services up -b && \
npx -y wait-on tcp:3000 -t 5s && \
make test

# shutdown backgrounded app
devbox services stop
