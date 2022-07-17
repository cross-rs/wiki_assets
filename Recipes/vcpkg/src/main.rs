use std::env;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::{Command, ExitStatus};

use serde::Deserialize;

#[derive(Deserialize)]
struct CargoMetadata {
    workspace_root: PathBuf,
}

fn workspace_root() -> PathBuf {
    let mut command = Command::new("cargo");
    command
        .arg("metadata")
        .arg("--no-deps")
        .args(&["--format-version", "1"]);

    let mut args = env::args().skip(1);
    while let Some(arg) = args.next() {
        if arg.starts_with("--manifest-path") {
            if let Some(path) = arg.strip_prefix("--manifest-path=") {
                command.args(["--manifest-path", path]);
            } else if arg == "--manifest-path" {
                let path = args.next().expect("manifest path cannot be empty.");
                command.args(["--manifest-path", &path]);
            }
        }
    }

    let output = command.output().expect("metadata command failed");
    if !output.status.success() {
        panic!("unable to get metadata for package");
    }
    let manifest: Option<CargoMetadata> =
        serde_json::from_slice(&output.stdout).expect("got invalid metadata");

    let manifest = manifest.expect("unable to deserialize cargo metadata");
    manifest.workspace_root
}

fn main() {
    // create our build directories.
    let home = workspace_root();
    let build_dir = home.join("target").join("build");
    let atoi_dir = build_dir.join("atoi");
    let helloworld_dir = build_dir.join("helloworld");
    let zlib_dir = build_dir.join("zlib");
    fs::create_dir_all(&build_dir).unwrap();
    fs::create_dir_all(&atoi_dir).unwrap();
    fs::create_dir_all(&helloworld_dir).unwrap();
    fs::create_dir_all(&zlib_dir).unwrap();

    // now, run our cmake tests
    let ext_dir = home.join("ext");
    atoi(&atoi_dir, &ext_dir.join("cpp-atoi"));
    helloworld(&helloworld_dir, &ext_dir.join("cpp-helloworld"));
    zlib(&zlib_dir, &ext_dir.join("zlib"));
}

fn to_utf8(path: &Path) -> &str {
    path.as_os_str().to_str().expect("path must be valid UTF-8")
}

fn check_status(status: ExitStatus) -> Result<(), ()> {
    match status.success() {
        true => Ok(()),
        false => Err(()),
    }
}

fn run(qemu: &str, binary: &str) {
    check_status(Command::new(qemu)
        .arg(binary)
        .status()
        .expect("failed to execute process"))
        .expect("must have successful exit status");
}

fn atoi(build_dir: &Path, src_dir: &Path) {
    let qemu = env::var("QEMU_RUNNER").expect("must have qemu runner defined.");

    // test meson
    let meson_dir = build_dir.join("meson");
    fs::create_dir_all(&meson_dir).unwrap();
    env::set_current_dir(&meson_dir).unwrap();

    check_status(Command::new("meson")
        .arg(src_dir)
        .status()
        .expect("failed to execute process"))
        .expect("must have successful exit status");

    check_status(Command::new("meson")
        .arg("compile")
        .status()
        .expect("failed to execute process"))
        .expect("must have successful exit status");
    run(&qemu, "atoi");
    fs::remove_dir_all(&meson_dir).unwrap();

    // test cmake
    let cmake_dir = build_dir.join("cmake");
    fs::create_dir_all(&cmake_dir).unwrap();
    env::set_current_dir(&cmake_dir).unwrap();

    check_status(Command::new("cmake")
        .arg(src_dir)
        .env("VERBOSE", "1")
        .status()
        .expect("failed to execute process"))
        .expect("must have successful exit status");

    check_status(Command::new("cmake")
        .args(&["--build", "."])
        .env("VERBOSE", "1")
        .status()
        .expect("failed to execute process"))
        .expect("must have successful exit status");
    run(&qemu, "atoi");
    fs::remove_dir_all(&cmake_dir).unwrap();
}

fn helloworld(build_dir: &Path, src_dir: &Path) {
    let qemu = env::var("QEMU_RUNNER").expect("must have qemu runner defined.");

    // test meson
    let meson_dir = build_dir.join("meson");
    fs::create_dir_all(&meson_dir).unwrap();
    env::set_current_dir(&meson_dir).unwrap();

    check_status(Command::new("meson")
        .arg(src_dir)
        .status()
        .expect("failed to execute process"))
        .expect("must have successful exit status");

    check_status(Command::new("meson")
        .arg("compile")
        .status()
        .expect("failed to execute process"))
        .expect("must have successful exit status");
    run(&qemu, "hello");
    fs::remove_dir_all(&meson_dir).unwrap();

    // test cmake
    let cmake_dir = build_dir.join("cmake");
    fs::create_dir_all(&cmake_dir).unwrap();
    env::set_current_dir(&cmake_dir).unwrap();

    check_status(Command::new("cmake")
        .arg(src_dir)
        .env("VERBOSE", "1")
        .status()
        .expect("failed to execute process"))
        .expect("must have successful exit status");

    check_status(Command::new("cmake")
        .args(&["--build", "."])
        .env("VERBOSE", "1")
        .status()
        .expect("failed to execute process"))
        .expect("must have successful exit status");
    run(&qemu, "hello");
    fs::remove_dir_all(&cmake_dir).unwrap();
}

fn zlib(build_dir: &Path, src_dir: &Path) {
    let src_dir = to_utf8(src_dir);
    let qemu = env::var("QEMU_RUNNER").expect("must have qemu runner defined.");

    // test meson + conan
    let meson_dir = build_dir.join("meson");
    fs::create_dir_all(&meson_dir).unwrap();
    env::set_current_dir(&meson_dir).unwrap();
    check_status(Command::new("conan")
        .args(&["install", src_dir])
        .arg("--build")
        .status()
        .expect("failed to execute process"))
        .expect("must have successful exit status");

    check_status(Command::new("meson")
        .arg(src_dir)
        .status()
        .expect("failed to execute process"))
        .expect("must have successful exit status");

    check_status(Command::new("conan")
        .args(&["build", src_dir])
        .status()
        .expect("failed to execute process"))
        .expect("must have successful exit status");
    run(&qemu, "zlibexec");
    fs::remove_dir_all(&meson_dir).unwrap();

    // test cmake + conan
    let conan_dir = build_dir.join("conan");
    fs::create_dir_all(&conan_dir).unwrap();
    env::set_current_dir(&conan_dir).unwrap();
    check_status(Command::new("conan")
        .args(&["install", src_dir])
        .arg("--build")
        .status()
        .expect("failed to execute process"))
        .expect("must have successful exit status");

    check_status(Command::new("cmake")
        .arg(src_dir)
        .status()
        .expect("failed to execute process"))
        .expect("must have successful exit status");

    check_status(Command::new("cmake")
        .args(&["--build", "."])
        .status()
        .expect("failed to execute process"))
        .expect("must have successful exit status");
    run(&qemu, "zlibexec");
    fs::remove_dir_all(&conan_dir).unwrap();

    // test cmake + vcpkg
    let vcpkg_dir = build_dir.join("vcpkg");
    fs::create_dir_all(&vcpkg_dir).unwrap();
    env::set_current_dir(&vcpkg_dir).unwrap();
    check_status(Command::new("cmake")
        .arg(src_dir)
        .status()
        .expect("failed to execute process"))
        .expect("must have successful exit status");

    check_status(Command::new("cmake")
        .args(&["--build", "."])
        .status()
        .expect("failed to execute process"))
        .expect("must have successful exit status");
    run(&qemu, "zlibexec");
    fs::remove_dir_all(&vcpkg_dir).unwrap();
}
