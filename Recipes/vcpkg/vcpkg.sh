#!/bin/bash
#
# Install vcpkg package management system.

set -ex pipefail

# There's a minor, well-known issue with wasm and vcpkg.
# vcpkg runs in script mode for the CMake files, meaning
# the `CMAKE_EXECUTABLE_SUFFIX` is not set, so all binaries
# will not have the `.js` suffix (although the wasm ones will).
#   https://github.com/microsoft/vcpkg/blob/master/docs/maintainers/maintainer-guide.md#useful-implementation-notes

export DEBIAN_FRONTEND="noninteractive"

# shellcheck disable=SC1091
. lib.sh

main() {
    install_packages curl \
        g++ \
        git \
        ca-certificates \
        jq \
        unzip \
        zip

    local td
    td="$(mktemp -d)"
    pushd "${td}"

    local url="https://api.github.com/repos/microsoft/vcpkg/releases/latest"
    local release
    release=$(curl "${url}" --silent | jq -r '.zipball_url')
    curl --retry 3 -sSfL "${release}" -o vcpkg.zip

    local dstdir=/opt/vcpkg/
    mkdir -p "${dstdir}"
    unzip vcpkg.zip -d "${dstdir}"
    local subdir
    subdir=$(ls "${dstdir}")
    shopt -s dotglob
    mv "${dstdir}/${subdir}"/* ${dstdir}
    shopt -u dotglob
    rmdir "${dstdir}/${subdir}"

    # Bootstrap the build, and remove unnecessary extras.
    "${dstdir}/bootstrap-vcpkg.sh"

    # Change our permissions, since we need to be able to write as a user.
    chmod -R +660 "${dstdir}"
    chown -R 1000:1000 "${dstdir}"

    purge_packages

    rm -rf "${td}"
    rm "${0}"
}

main "${@}"
