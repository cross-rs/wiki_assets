# sqlx-proc-macro

An example of compiling a crate with external dependencies using procedural macros. This is adapted from [cross-sqlx-test](https://github.com/wiryfuture/cross-sqlx-test/commit/c41851b41ed10787e78dcdead509ff982afec479), which is made available in the public domain. To test [sqlx](https://github.com/launchbadge/sqlx) using SQLite, build and run with:

```bash
$ cross build --target aarch64-unknown-linux-gnu
$ cross run --target aarch64-unknown-linux-gnu
Executing from arch aarch64 with name John!
```
