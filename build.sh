# zig 0.14.0-dev.1511+54b668f8a (2024-09-12)

#!/bin/sh

# libc targets do not need to link against external libc
#
b_libc_targets="aarch64-linux-android
aarch64-linux-gnu
aarch64-linux-musl
aarch64-macos-none
aarch64-windows-gnu
aarch64_be-linux-gnu
aarch64_be-linux-musl
arm-linux-gnu
arm-linux-gnueabi
arm-linux-gnueabihf
arm-linux-musleabi
arm-linux-musleabihf
armeb-linux-gnueabi
armeb-linux-gnueabihf
armeb-linux-musleabi
armeb-linux-musleabihf
loongarch64-linux-gnu
loongarch64-linux-musl
mips-linux-gnueabi
mips-linux-gnueabihf
mips-linux-musleabi
mips-linux-musleabihf
mips64-linux-gnuabi64
mips64-linux-gnuabin32
mips64-linux-musl
mips64el-linux-gnuabi64
mips64el-linux-gnuabin32
mips64el-linux-musl
mipsel-linux-gnueabi
mipsel-linux-gnueabihf
mipsel-linux-musleabi
mipsel-linux-musleabihf
powerpc-linux-gnueabi
powerpc-linux-gnueabihf
powerpc-linux-musleabi
powerpc-linux-musleabihf
powerpc64-linux-gnu
powerpc64-linux-musl
powerpc64le-linux-gnu
powerpc64le-linux-musl
riscv32-linux-gnu
riscv32-linux-musl
riscv64-linux-gnu
riscv64-linux-musl
thumb-linux-musleabi
thumb-linux-musleabihf
thumb-windows-gnu
thumbeb-linux-musleabi
thumbeb-linux-musleabihf
wasm32-wasi-musl
wasm32-wasi-none
x86-linux-gnu
x86-linux-musl
x86-windows-gnu
x86_64-linux-gnu
x86_64-linux-gnux32
x86_64-linux-musl
x86_64-macos-none
x86_64-windows-gnu"

# However, these libc targets were removed because they failed
#
# ERROR: wasm32-freestanding-musl
# ERROR: sparc64-linux-gnu
# ERROR: sparc-linux-gnu
# ERROR: s390x-linux-musl
# ERROR: s390x-linux-gnu
# ERROR: m68k-linux-musl
# ERROR: m68k-linux-gnu
# ERROR: csky-linux-gnueabihf
# ERROR: csky-linux-gnueabi

for b_target in ${b_libc_targets}; do
    echo >&2 "${b_target}"
    zig build-exe ./uuidv7.zig -O ReleaseSmall -target "${b_target}" -femit-bin="uuidv7-${b_target}"
done

# these non-libc targets require a libc to link against
#
# ERROR: aarch64-freebsd-gnu
# ERROR: aarch64-ios-none
# ERROR: aarch64-netbsd-gnu
# ERROR: aarch64-openbsd-gnu
# ERROR: arm-plan9-none
# ERROR: powerpc64-aix-none
# ERROR: s390x-linux-gnu
# ERROR: wasm32-freestanding-none
# ERROR: x86-freebsd-gnu
# ERROR: x86-netbsd-gnu
# ERROR: x86-openbsd-gnu
# ERROR: x86-plan9-none
# ERROR: x86_64-dragonfly-none
# ERROR: x86_64-freebsd-gnu
# ERROR: x86_64-illumos-none
# ERROR: x86_64-netbsd-gnu
# ERROR: x86_64-openbsd-gnu
# ERROR: x86_64-plan9-none
# ERROR: x86_64-solaris-none