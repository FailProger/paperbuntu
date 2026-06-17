#!/usr/bin/env bash

set -eu

# Scripts consts     WARN: Don't change
readonly REPO_URL='https://github.com/FailProger/paperbuntu'
readonly CONFIG_DIR="$(dirname ${BASH_SOURCE[0]})/user-config"

# Installation params
readonly DEFAULT_USERNAME='paperbuntu'
readonly DEFAULT_PASSWORD='paperbuntu'

readonly RELEASE='noble'
readonly MIRROR='http://archive.ubuntu.com/ubuntu'
readonly ARCH='amd64'
readonly VARIANT='minbase'

# System params
readonly LOCALE='en_US.UTF-8'
