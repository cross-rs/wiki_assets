#!/bin/bash
#
# Install the conan package management system.

set -ex pipefail

# Check required environment variables.
if [[ -z "${TRIPLE}" ]]; then
    echo 'Must set the target triple via `$TRIPLE`, quitting.'
    exit 1
fi
if [[ -z "${SYSTEM}" ]]; then
    echo 'Must set the target operating system via `$SYSTEM`, quitting.'
    exit 1
fi
if [[ -z "${COMPILER}" ]]; then
    echo 'Must set the compiler type via `$COMPILER`, quitting.'
    exit 1
fi
if [[ -z "${COMPILER_VERSION}" ]]; then
    echo 'Must set the compiler version via `$COMPILER_VERSION`, quitting.'
    exit 1
fi

export DEBIAN_FRONTEND="noninteractive"

# There's numerous issues with wasm and Conan:
#   1. It assumes the toolchain versions is 13.0,
#       when it only supports up to 12.0. This requires
#       shipping a custom `settings.yml` file, which
#       is not fun. We ship with a custom toolchain that
#       effectively provides `ANY` for any compiler versions.
#   2. Can't easily change configuration settings via
#       `conan config set compiler.clang.version=ANY`.
#       This means distributing a `settings.yml` file.
#   3. Even if you do get the compiler version correct,
#       building with a Meson build system produces a warning
#       in wasm-ld, stating it's ignoring an unrecognized
#       option `-rpath`.
#   4. Building with `meson` and `cmake` still gets an issue, `unable to find <library>`,
#       because the files are incorrectly named. For example, `libz.a`
#       is actually named `libzlibstatic.a`. The solution is to trick
#       the compiler into using `Linux` as the operating system, which
#       isn't completely lying.
#
#   This last issue is solvable. Since vcpkg works out-of-the-box,
#   this isn't really a big issue.

main() {
    apt-get update
    apt-get install --assume-yes --no-install-recommends \
        pkg-config \
        python3 \
        python3-pip
    python3 -m pip install conan

    # Need to create a default profile.
    # Don't set the target arch, for reasons.
    # Use mips for everything, since it doesn't add compiler flags.
    # It also means there won't be pre-built packages in most cases,
    # which dramatically simplifies to dependency process.
    local dstdir="/opt/conan"
    mkdir -p "${dstdir}/.conan/profiles"
    chown -R 1000:1000 "${dstdir}/.conan"
    echo "[settings]
os=${SYSTEM}
arch=${arch}
build_type=Release
compiler=${COMPILER}
compiler.version=${COMPILER_VERSION}" > "${dstdir}/.conan/profiles/default"
    if [[ "${TRIPLE}" != *"android"* ]]; then
        # Add the libcxx version for any non-android version.
        echo "compiler.libcxx=libstdc++11" >> "${dstdir}/.conan/profiles/default"
    fi
    chown 1000:1000 "${dstdir}/.conan/profiles/default"

    # Create an alias for the conan profile.
    echo '#!/bin/bash
# Wrapper script for conan to install to a local, toolchain-specific.
# We force a build, and ensure we install the dependencies
# locally.

conan="/usr/local/bin/conan"
. /opt/cross/find

# Copy over our configuration settings.
if [[ -z "${DETACHED}" ]]; then
    # Not in detached mode, change the Conan home so it persists
    # after the image quits. Do not override any custom conan home.
    if [[ -z "${CONAN_USER_HOME}" ]]; then
        export CONAN_USER_HOME="${PWD}"/.cross-'"${TRIPLE}"'-conan
    fi
    mkdir -p "${CONAN_USER_HOME}"/.conan/profiles
    if [[ ! -f "${CONAN_USER_HOME}"/.conan/profiles/default ]]; then
        cp /opt/conan/.conan/profiles/default "${CONAN_USER_HOME}"/.conan/profiles/default
    fi
    if [[ ! -f "${CONAN_USER_HOME}"/.conan/settings.yml ]]; then
        cp /opt/conan/.conan/settings.yml "${CONAN_USER_HOME}"/.conan/settings.yml
    fi
else
    # Can use an install relative to the user home.  Do not override any
    # custom conan home.
    if [[ -z "${CONAN_USER_HOME}" ]]; then
        export {CONAN_USER_HOME}=/opt/conan
    fi
fi

# Check if we need to add the `--build` argument.
arguments=("$@")
if [ "${#arguments[@]}" -ne 0 ]; then
    case "${arguments[0]}" in
        # Consumer commands
        config)
            ;;
        get)
            ;;
        info)
            # Note: info works with `--build`, but it changes the behavior
            # in undesired ways.
            ;;
        search)
            ;;
        # Creator commands
        new)
            ;;
        upload)
            ;;
        export)
            ;;
        export-pkg)
            ;;
        # Package development commands
        source)
            ;;
        package)
            ;;
        editable)
            ;;
        workspace)
            # Note: workspace works, but it has no effect.
            ;;
        # Misc commands
        profile)
            ;;
        remote)
            ;;
        user)
            ;;
        imports)
            ;;
        copy)
            ;;
        remove)
            # Note: remove works, but it has no effect.
            ;;
        alias)
            ;;
        download)
            ;;
        inspect)
            ;;
        help)
            ;;
        lock)
            ;;
        frogarian)
            ;;
        # Command Utilities
        --help)
            ;;
        --version)
            ;;
        *)
            # Commands that work include:
            #   build
            #   install
            #   create
            #   test

            # Do not provide `--build` if it is already provided.
            if ! find --build "${arguments[@]}"; then
                arguments+=("--build")
            fi
            ;;
    esac
fi

# Call our command.
if [ "${VERBOSE}" != "" ]; then
    echo "${conan}" "${arguments[@]}"
fi
"${conan}" "${arguments[@]}"' > "/opt/cross/bin/conan"
    chmod +x "/opt/cross/bin/conan"

    rm "${0}"
}

main "${@}"
