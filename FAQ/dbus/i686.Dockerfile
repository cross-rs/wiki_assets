FROM ghcr.io/cross-rs/i686-unknown-linux-gnu:main

RUN dpkg --add-architecture i386
RUN apt-get update && apt-get -y install libdbus-1-dev:i386

ENV PKG_CONFIG_PATH="/usr/lib/i386-linux-gnu/pkgconfig/:${PKG_CONFIG_PATH}"
