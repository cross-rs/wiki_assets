# dbus

An example of using cross with a libdbus dependency. `cross` will automatically build the docker image for you

```bash
cross run --target aarch64-unknown-linux-gnu
```

This supports the following targets:

- `armv7-unknown-linux-gnueabihf`
- `aarch64-unknown-linux-gnu`
- `i686-unknown-linux-gnu`
- `x86_64-unknown-linux-gnu`
