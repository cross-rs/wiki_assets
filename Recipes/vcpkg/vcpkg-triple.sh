#!/bin/bash
#
# Create the vcpkg wrappers to add the triplet and other
# configurations out-of-the-box.

set -ex pipefail

# Check required environment variables.
if [[ -z "${PROCESSOR}" ]]; then
    echo 'Must set the target processor via `$PROCESSOR`, quitting.'
    exit 1
fi
if [[ -z "${SYSTEM}" ]]; then
    echo 'Must set the target operating system via `$SYSTEM`, quitting.'
    exit 1
fi
if [[ -z "${TRIPLE}" ]]; then
    echo 'Must set the target triplet via `$TRIPLE`, quitting.'
    exit 1
fi
if [[ -z "${LINKAGE}" ]]; then
    echo 'Must set the target triplet via `$LINKAGE`, quitting.'
    echo 'Valid values are `static` and `dynamic`.'
    exit 1
fi

export DEBIAN_FRONTEND="noninteractive"

main() {
    # Install dependencies we need after to use vcpkg.
    apt-get update
    apt-get install --assume-yes --no-install-recommends \
        curl \
        pkg-config \
        tar \
        unzip \
        zip

    # Need to define a custom toolchain file, which gets loaded by our vcpkg one.
    local cmake_toolchain
    cmake_toolchain='CMAKE_MINIMUM_REQUIRED(VERSION 3.3)
SET(CMAKE_SYSTEM_NAME '"${SYSTEM}"')
SET(CMAKE_SYSTEM_PROCESSOR "'"${PROCESSOR}"'")

SET(CMAKE_FIND_ROOT_PATH "'"${SYSROOT}"'")
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
SET(CROSSCOMPILING_EMULATOR "'${QEMU}'")

set(CMAKE_C_COMPILER "'"${CC}"'")
set(CMAKE_CXX_COMPILER "'"${CXX}"'")
set(CMAKE_AR "'"${AR}"'")
set(CMAKE_STRIP "'"${STRIP}"'")

IF(DEFINED CROSS_CHAINLOAD_TOOLCHAIN_FILE AND NOT DEFINED _CROSS_CHAINLOAD_TOOLCHAIN_FILE)
    INCLUDE("${CROSS_CHAINLOAD_TOOLCHAIN_FILE}")
    SET(_CROSS_CHAINLOAD_TOOLCHAIN_FILE ON)
ENDIF()'
    echo "${cmake_toolchain}" > "/opt/cross/toolchain.cmake"

    # Create our custom triple, as a drop-in replacement for a community one.
    local toolchain
    toolchain="set(VCPKG_TARGET_ARCHITECTURE ${VCKPKG_PROCESSOR})
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE ${LINKAGE})
set(VCPKG_CMAKE_SYSTEM_NAME ${SYSTEM})

# The toolchain file can be included multiple times, which can
# cause linkage errors with installing libraries with dependencies.
if(NOT DEFINED VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
    set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE /opt/cross/toolchain.cmake)
endif()

if(NOT CMAKE_HOST_SYSTEM_PROCESSOR)
    execute_process(COMMAND \"uname\" \"-m\" OUTPUT_VARIABLE CMAKE_HOST_SYSTEM_PROCESSOR OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()"

    # Need to add items for MinGW and other systems.
    if [ "${SYSTEM}" = "MinGW" ]; then
        toolchain="${toolchain}
    set(VCPKG_ENV_PASSTHROUGH PATH)"
        if [ "$LINKAGE" = "dynamic" ]; then
            toolchain="${toolchain}
    set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)"
        fi
    elif [ "${SYSTEM}" = "Emscripten" ]; then
        toolchain="${toolchain}
    set(VCPKG_ENV_PASSTHROUGH EMSDK PATH)"
    fi

    local dstdir=/opt/vcpkg/
    local toolchain_file
    toolchain_file="${dstdir}/triplets/community/${TRIPLE}"-cross.cmake

    echo "${toolchain}" > "${toolchain_file}"
    chmod +660 "${toolchain_file}"
    chown -R 1000:1000 "${toolchain_file}"

    # Create an alias for vcpkg.
    echo '#!/bin/bash
    # Wrapper script for vcpkg to ensure we use the correct triplet.
    # Note that the triplet can always be provided: vcpkg does not care.

    "/opt/vcpkg/vcpkg" "$@" --triplet $(cat /opt/vcpkg/triple)-cross' > "/opt/cross/bin/vcpkg"
    chmod +x "/opt/cross/bin/vcpkg"

    # Create an environment variable containing the triplet.
    # Allows us to call the correct triplet whenever we invoke vcpkg.
    echo "${TRIPLE}" > "${dstdir}"/triple

    rm "${0}"
}

main "${@}"
