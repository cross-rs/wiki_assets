FROM ghcr.io/cross-rs/x86_64-unknown-linux-gnu:main

COPY redoxer.sh /
RUN /redoxer.sh
