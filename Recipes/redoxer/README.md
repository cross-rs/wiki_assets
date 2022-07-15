# redoxer

An example of building Rust programs with cross inside of Redox.

```bash
$ cross run --target aarch64-unknown-linux-gnu
```

This supports the following targets:
- `armv7-unknown-linux-gnueabihf`
- `aarch64-unknown-linux-gnu`
- `i686-unknown-linux-gnu`
- `x86_64-unknown-linux-gnu`

Please note that this requires a base Ubuntu version of 20.04, and therefore needs you to build the images with [newer Linux versions](https://github.com/cross-rs/cross/wiki/FAQ#newer-linux-versions).
