FROM ghcr.io/cross-rs/x86_64-unknown-linux-gnu:main

RUN yum -y install dbus-devel
