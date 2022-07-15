FROM ghcr.io/cross-rs/armv7-unknown-linux-gnueabihf:main

COPY redoxer.sh /
RUN /redoxer.sh
