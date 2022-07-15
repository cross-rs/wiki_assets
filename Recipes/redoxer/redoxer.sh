#!/bin/bash

apt-get update && apt-get install --assume-yes curl libfuse-dev pkg-config

export RUSTUP_HOME=/tmp/rustup
export CARGO_HOME=/tmp/cargo

curl --retry 3 -sSfL https://sh.rustup.rs -o rustup-init.sh
sh rustup-init.sh -y --no-modify-path --profile minimal
rm rustup-init.sh
PATH="${CARGO_HOME}/bin:${PATH}" rustup install nightly

PATH="${CARGO_HOME}/bin:${PATH}" cargo +nightly install redoxer --root /usr/local
rm -r "${RUSTUP_HOME}" "${CARGO_HOME}"
redoxer toolchain
