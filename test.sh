#!/usr/bin/env bash

devbox services up -b && make test
devbox services stop
