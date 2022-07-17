FROM ghcr.io/cross-rs/armv7-unknown-linux-gnueabihf:main

COPY build-essential.sh /
RUN /build-essential.sh

COPY vcpkg.sh /
RUN /vcpkg.sh

# These are ordered from longest to shortest.
ARG VCKPKG_PROCESSOR=armhf
ARG PROCESSOR=arm
ARG SYSTEM=Linux
ARG TRIPLE=armelhf-unknown-linux-gnueabi
ARG QEMU=qemu-arm
ARG SYSROOT=/usr/arm-linux-gnueabihf
ARG CC=arm-linux-gnueabihf-gcc
ARG CXX=arm-linux-gnueabihf-g++
ARG AR=arm-linux-gnueabihf-ar
ARG STRIP=arm-linux-gnueabihf-strip

RUN mkdir -p /opt/cross/bin

COPY vcpkg-triple.sh /
RUN LINKAGE=static /vcpkg-triple.sh

COPY meson.sh /
RUN CPU_FAMILY=arm /meson.sh

COPY conan.sh /
RUN COMPILER=gcc COMPILER_VERSION="9" /conan.sh

# Copy some extra configuration data.
COPY conan/settings.yml /opt/conan/.conan/
COPY find /opt/cross/
COPY cmake /opt/cross/bin/

ENV PATH=/opt/cross/bin:$PATH \
    QEMU_RUNNER=$QEMU
