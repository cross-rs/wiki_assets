FROM ghcr.io/cross-rs/mips64el-unknown-linux-gnuabi64:main

COPY build-essential.sh /
RUN /build-essential.sh

COPY vcpkg.sh /
RUN /vcpkg.sh

# These are ordered from longest to shortest.
ARG VCKPKG_PROCESSOR=mips64el
ARG PROCESSOR=mips64el
ARG SYSTEM=Linux
ARG TRIPLE=mips64el-unknown-linux-gnu
ARG QEMU=qemu-mips64el
ARG SYSROOT=/usr/mips64el-linux-gnuabi64
ARG CC=mips64el-linux-gnuabi64-gcc
ARG CXX=mips64el-linux-gnuabi64-g++
ARG AR=mips64el-linux-gnuabi64-ar
ARG STRIP=mips64el-linux-gnuabi64-strip

RUN mkdir -p /opt/cross/bin

COPY vcpkg-triple.sh /
RUN LINKAGE=static /vcpkg-triple.sh

COPY meson.sh /
RUN CPU_FAMILY=mips /meson.sh

COPY conan.sh /
RUN COMPILER=gcc COMPILER_VERSION="9" /conan.sh

# Copy some extra configuration data.
COPY conan/settings.yml /opt/conan/.conan/
COPY find /opt/cross/
COPY cmake /opt/cross/bin/

ENV PATH=/opt/cross/bin:$PATH \
    QEMU_RUNNER=$QEMU
