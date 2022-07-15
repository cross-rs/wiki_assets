FROM ghcr.io/cross-rs/aarch64-unknown-linux-gnu:main

COPY redoxer.sh /
RUN /redoxer.sh
