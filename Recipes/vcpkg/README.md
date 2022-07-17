# vcpkg

An example of building Rust programs with using [vcpkg](https://vcpkg.io/en/index.html) as a package manager for C/C++ dependencies. It also comes pre-installed with [conan](https://conan.io) and [meson](https://mesonbuild.com/). Note that the CMake builds here are building native C/C++ binaries, but normally should be used with [cmake-rs](https://docs.rs/cmake/latest/cmake/) to build libraries as dependencies for your package.

```bash
$ cross run --target aarch64-unknown-linux-gnu
```

This supports the following targets:
- `armv7-unknown-linux-gnueabihf`
- `aarch64-unknown-linux-gnu`
- `i686-unknown-linux-gnu`
- `x86_64-unknown-linux-gnu`
- `mips64el-unknown-linux-gnuabi64`

Feel free to populate this list with more targets or request additional targets.

### Issues

- `vcpkg` does not work with `i686-unknown-linux-gnu` or `mips64el-unknown-linux-gnuabi64`.
