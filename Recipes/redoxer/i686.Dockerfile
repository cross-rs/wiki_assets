FROM ghcr.io/cross-rs/i686-unknown-linux-gnu:main

COPY redoxer.sh /
RUN /redoxer.sh
