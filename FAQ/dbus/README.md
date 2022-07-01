# dbus

An example of using cross with a libdbus dependency. First build the Docker images, then run them as desired.

```bash
$ ./build-docker.sh
$ cross run --target aarch64-unknown-linux-gnu
```

This supports the following targets:
- `armv7-unknown-linux-gnueabihf`
- `aarch64-unknown-linux-gnu`
- `i686-unknown-linux-gnu`
- `x86_64-unknown-linux-gnu`
