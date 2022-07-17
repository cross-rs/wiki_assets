#!/bin/bash
#
# Install the Meson build system.

set -ex pipefail

# Check required environment variables.
if [[ -z "${PROCESSOR}" ]]; then
    echo 'Must set the target processor via `$PROCESSOR`, quitting.'
    exit 1
fi
if [[ -z "${CPU_FAMILY}" ]]; then
    echo 'Must set the target CPU family via `$CPU_FAMILY`, quitting.'
    exit 1
fi
if [[ -z "${SYSTEM}" ]]; then
    echo 'Must set the target operating system via `$SYSTEM`, quitting.'
    exit 1
fi
if [[ -z "${ENDIAN}" ]]; then
    ENDIAN="little"
fi

export DEBIAN_FRONTEND="noninteractive"

main() {
    # Note: Don't use the system default for meson.
    # It's outdated, and doesn't support flags we need.
    apt-get update
    apt-get install --assume-yes --no-install-recommends \
        python3 \
        python3-pip
    python3 -m pip install meson

    local endian="${ENDIAN}"

    # Need to create a cross file, for the meson build system.
    local dstdir=/opt/meson
    mkdir -p "${dstdir}"
    echo "[build_machine]
system = 'linux'
cpu_family = 'x86'
cpu = 'x86_64'
endian = 'little'

[host_machine]
system = '${SYSTEM}'
cpu_family = '${CPU_FAMILY}'
cpu = '${PROCESSOR}'
endian = '${endian}'

[properties]
needs_exe_wrapper = true

[binaries]
c = '${CC}'
cpp = '${CXX}'
ar = '${AR}'
strip = '${STRIP}'
pkgconfig = 'pkg-config'
cmake = 'cmake'
python = 'python3'" > "${dstdir}"/cross.meson

    if [[ -n "${QEMU}" ]]; then
        echo "exe_wrapper = '${QEMU}'" >> "${dstdir}"/cross.meson
    fi

    # Create a wrapper for the Meson too to automatically inject
    # the cross-compiler toolchain.
    echo '#!/bin/bash
# Wrapper script for Meson to automatically add a cross-compile toolchain.

. /opt/cross/find
meson="/usr/local/bin/meson"
arguments=("$@")

# Check if we need to add the `--cross-file` argument.
if [ "${#arguments[@]}" -ne 0 ]; then
    case "${arguments[0]}" in
        configure)
            ;;
        dist)
            ;;
        install)
            ;;
        introspect)
            ;;
        init)
            ;;
        test)
            ;;
        wrap)
            ;;
        subprojects)
            ;;
        help)
            ;;
        rewrite)
            ;;
        compile)
            ;;
        devenv)
            ;;
        --help)
            ;;
        --version)
            ;;
        *)
            # Commands that work include:
            #   setup
            #
            # If no command is provided, defaults to setup.

            if ! find --cross-file "${arguments[@]}"; then
                arguments+=(--cross-file /opt/meson/cross.meson)
            fi
            ;;
    esac
fi

# Call our command.
if [ "${VERBOSE}" != "" ]; then
    echo PKG_CONFIG_PATH="${PWD}:${PKG_CONFIG_PATH}" "${meson}" "${arguments[@]}"
fi
# Update our pkg-config path, so it can find locally installed files.
PKG_CONFIG_PATH="${PWD}:${PKG_CONFIG_PATH}" "${meson}" "${arguments[@]}"' > "/opt/cross/bin/meson"
    chmod +x "/opt/cross/bin/meson"

    rm "${0}"
}

main "${@}"
