#!/usr/bin/env bash

set -eu

# Scripts consts     WARN: Don't change
readonly REPO_URL="https://github.com/FailProger/paperbuntu"
readonly CONFIG_DIR="$(dirname ${BASH_SOURCE[0]})/user-config"

# Installation params
DEFAULT_USERNAME="paperbuntu"
DEFAULT_PASSWORD="paperbuntu"

RELEASE="resolute"
MIRROR="http://archive.ubuntu.com/ubuntu"
ARCH="amd64"
VARIANT="minbase"

# System params
LOCALE=en_US.UTF-8
