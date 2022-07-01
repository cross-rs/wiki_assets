#!/usr/bin/env bash

project_dir=$(dirname "${BASH_SOURCE[0]}")
project_dir=$(realpath "${project_dir}")

if [[ -z "${TARGET}" ]]; then
    TARGET=x86_64-unknown-linux-musl
fi

mkdir -p "${project_dir}/sccache"
SCCACHE_LOG=trace SCCACHE_DIR="${project_dir}/sccache" \
    cross build --target "${TARGET}" --verbose
