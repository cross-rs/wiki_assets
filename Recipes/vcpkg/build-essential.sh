#!/bin/bash
#
# Install the conan package management system.

set -ex pipefail

export DEBIAN_FRONTEND="noninteractive"

main() {
    apt-get update
    apt-get install --assume-yes --no-install-recommends \
        autoconf \
        ca-certificates \
        git \
        make \
        ninja-build

    rm "${0}"
}

main "${@}"
