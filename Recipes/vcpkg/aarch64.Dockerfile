FROM ghcr.io/cross-rs/aarch64-unknown-linux-gnu:main

COPY build-essential.sh /
RUN /build-essential.sh

COPY vcpkg.sh /
RUN /vcpkg.sh

# These are ordered from longest to shortest.
ARG VCKPKG_PROCESSOR=aarch64
ARG PROCESSOR=aarch64
ARG SYSTEM=Linux
ARG TRIPLE=arm64-unknown-linux-gnu
ARG QEMU=qemu-aarch64
ARG SYSROOT=/usr/aarch64-linux-gnu
ARG CC=aarch64-linux-gnu-gcc
ARG CXX=aarch64-linux-gnu-g++
ARG AR=aarch64-linux-gnu-ar
ARG STRIP=aarch64-linux-gnu-strip

RUN mkdir -p /opt/cross/bin

COPY vcpkg-triple.sh /
RUN LINKAGE=static /vcpkg-triple.sh

COPY meson.sh /
RUN CPU_FAMILY=aarch64 /meson.sh

COPY conan.sh /
RUN COMPILER=gcc COMPILER_VERSION="9" /conan.sh

# Copy some extra configuration data.
COPY conan/settings.yml /opt/conan/.conan/
COPY find /opt/cross/
COPY cmake /opt/cross/bin/

ENV PATH=/opt/cross/bin:$PATH \
    QEMU_RUNNER=$QEMU
