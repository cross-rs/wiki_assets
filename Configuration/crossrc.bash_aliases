#!/usr/bin/env bash
# This file contains environment variables definitions and possible
# values to configure cross. The values provided are generally defaults,
# otherwise the default value is documented.

# CROSS CONFIGURATION
# -------------------
# These are environment variables used to configure cross.

# The container engine to run cross in. Defaults to `docker` then `podman`,
# whichever is found first (example: docker, see the FAQ). You can also
# provide a path or the name of a binary on the path.
CROSS_CONTAINER_ENGINE=podman

# Home directory for xargo.
XARGO_HOME=~/.xargo

# The directory for the Nix store.
NIX_STORE=/nix/store

# Set the user identifier for the cross command. Must be a valid user ID.
# Valid user IDs are generally `0` (root), or `1000-60000` (regular users).
# Specifications for valid user IDs are described here:
#   https://en.wikipedia.org/wiki/User_identifier#Conventions
CROSS_CONTAINER_UID=1000

# Set the group identifier for the cross command. This has
# similar restrictions to the user ID.
CROSS_CONTAINER_GID=1000

# Inform cross that it is running inside a container. When unset,
# set to `0`, empty, or `false`, inform `cross` it is not running in
# a container. By default this is false.
CROSS_CONTAINER_IN_CONTAINER=1

# Additional arguments to provide to the container engine during $engine run.
# Useful when needing additional customization or flags passed to `cross`
# not available by other config variables.
CROSS_CONTAINER_OPTS="--env MYVAR=1"

# Specify the path to the `cross` config file.
CROSS_CONFIG="Cross.toml"

# Print debugging information for cross when using the Linux or Android runners.
# When unset, set to `0`, empty, or `false`, do not print debugging information.
# By default this is false.
CROSS_DEBUG=1

# Use older cross behavior. By default this is unset and uses the latest behavior.
CROSS_COMPATIBILITY_VERSION=0.2.1

# Specify that rustup is using a custom toolchain, and therefore should
# not try to add targets/install components. Useful with `cargo-bisect-rustc`.
# When unset, set to `0`, empty, or `false`, assume rustup can install targets
# or components. By default this is false.
CROSS_CUSTOM_TOOLCHAIN=1

# Inform cross it is using a remote container engine, and use data volumes
# rather than local bind mounts. See Remote for more information using
# remote container engines. When unset, set to `0`, empty, or `false`,
# assume cross is running locally. By default this is false.
CROSS_REMOTE=1

# Get a backtrace of of system calls from binaries run using Qemu.
# By default, only “foreign” (non x86_64) use Qemu when run. When unset,
# set to `0`, empty, or `false`, do not provide an strace. By default
# this is false.
QEMU_STRACE=1

# Specify whether to container engine runs as root or is rootless.
# When unset, set to `auto`, `0`, empty, or `false`, it assumes docker
# runs as root and all other container engines are rootless.
CROSS_ROOTLESS_CONTAINER_ENGINE=1

# Custom the container user namespace. If set to none, user namespaces
# will be disabled. If not provided or set to `auto`, it will use the
# default namespace.
CROSS_CONTAINER_USER_NAMESPACE="host"

# CROSS TOML CONFIGURATION
# ------------------------
# These are additional ways to specify configuration values present in
# `Cross.toml` or `Cargo.toml`. Environment variables will override
# values found in `Cross.toml`, however, more specific values will
# still be used over less specific ones. For example, `target.(...).xargo`
# will still override `CROSS_BUILD_XARGO`. The priority order goes as follows:
#   1. Environment variable target.
#   2. Config target.
#   3. Environment variable build.
#   4. Config build.
#
# Values in `Cross.toml` will also override those in `Cargo.toml`. Almost
# all configuration options can be provided, with `build.xargo` being
# provided as `CROSS_BUILD_XARGO`, `build.default-target` as
# `CROSS_BUILD_DEFAULT_TARGET`, `target.aarch64-unknown-linux-gnu.runner`
# as `CROSS_TARGET_AARCH64_UNKNOWN_LINUX_GNU_RUNNER`, etc.

# Sets the default target, similar to specifying --target.
# Soft-deprecated, prefer `CARGO_BUILD_TARGET` instead.
CROSS_BUILD_TARGET="aarch64-unknown-linux-gnu"

# CROSS_TARGET_${TARGET}_RUNNER: provide a runner for the cross target.
# Valid values are `qemu-system`, `qemu-user`, and `native`
# (the last only for native targets).
CROSS_TARGET_X86_64_UNKNOWN_LINUX_GNU_RUNNER=qemu-user

# CARGO CONFIGURATION
# -------------------
# These are values used to configure `cargo`.
# Other variables that can be specified are available here:
#   https://doc.rust-lang.org/cargo/reference/environment-variables.html
#
# Supported environment variables include:
# - BROWSER
# - CARGO_BUILD_DEP_INFO_BASEDIR
# - CARGO_BUILD_INCREMENTAL
# - CARGO_BUILD_JOBS
# - CARGO_BUILD_RUSTDOCFLAGS
# - CARGO_BUILD_RUSTFLAGS
# - CARGO_CACHE_RUSTC_INFO
# - CARGO_FUTURE_INCOMPAT_REPORT_FREQUENCY
# - CARGO_HTTP_CAINFO
# - CARGO_HTTP_CHECK_REVOKE
# - CARGO_HTTP_DEBUG
# - CARGO_HTTP_LOW_SPEED_LIMIT
# - CARGO_HTTP_MULTIPLEXING
# - CARGO_HTTP_PROXY
# - CARGO_HTTP_SSL_VERSION
# - CARGO_HTTP_TIMEOUT
# - CARGO_HTTP_USER_AGENT
# - CARGO_INCREMENTAL
# - CARGO_NET_GIT_FETCH_WITH_CLI
# - CARGO_NET_OFFLINE
# - CARGO_NET_RETRY
# - HTTP_TIMEOUT
# - HTTPS_PROXY
# - RUSTDOCFLAGS
# - RUSTFLAGS
# - TERM

# Sets the default target, similar to specifying --target.
CARGO_BUILD_TARGET="aarch64-unknown-linux-gnu"
# CARGO_TARGET_${TARGET}_LINKER: specify a custom linker passed to rustc.
# This can be multiple arguments, which are evaluated as if passed to
# a Unix shell (for example, `ld-wrapper bfd`)
CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER=link.sh
# CARGO_TARGET_${TARGET}_RUNNER: specify the wrapper to run executables.
# This can be multiple arguments, which are evaluated as if passed to
# a Unix shell (for example, `qemu-aarch64 -cpu cortex-a72`)
CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_RUNNER="qemu-aarch64 -cpu cortex-a72"
# CARGO_TARGET_${TARGET}_RUSTFLAGS: add additional flags passed to rustc.
CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_RUSTFLAGS="-C lto thin -C panic abort"

# UNSTABLE FEATURES
# -----------------
# These are unstable features, which are only available on nightly.

# Enable running doctests when using `cross test`. When unset,
# set to `0`, empty, or `false`, doctests are disabled. Any other
# value enables doctests.
CROSS_UNSTABLE_ENABLE_DOCTESTS=1
