FROM ghcr.io/cross-rs/i686-unknown-linux-gnu:main

COPY build-essential.sh /
RUN /build-essential.sh

COPY vcpkg.sh /
RUN /vcpkg.sh

# These are ordered from longest to shortest.
ARG VCKPKG_PROCESSOR=i386
ARG PROCESSOR=i386
ARG SYSTEM=Linux
ARG TRIPLE=i686-unknown-linux-gnu
ARG QEMU=qemu-i386
ARG SYSROOT=/usr
ARG CC=gcc
ARG CXX=g++
ARG AR=ar
ARG STRIP=strip

RUN mkdir -p /opt/cross/bin

COPY vcpkg-triple.sh /
RUN LINKAGE=static /vcpkg-triple.sh

COPY meson.sh /
RUN CPU_FAMILY=x86 /meson.sh

COPY conan.sh /
RUN COMPILER=gcc COMPILER_VERSION="9" /conan.sh

# Copy some extra configuration data.
COPY conan/settings.yml /opt/conan/.conan/
COPY find /opt/cross/
COPY cmake /opt/cross/bin/

ENV PATH=/opt/cross/bin:$PATH \
    QEMU_RUNNER=$QEMU \
    CFLAGS="-m32" \
    CXXFLAGS="-m32" \
    LDFLAGS="-m32"
