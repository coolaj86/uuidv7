# [uuidv7](https://github.com/coolaj86/uuidv7)

Generate UUID v7 strings, like `019212d3-87f4-7d25-902e-b8d39fe07f08`.

```sh
uuidv7 > uuidv7.txt
```

```text
019212d3-87f4-7d25-902e-b8d39fe07f08
```

|        32-bit time         | 16-bit time | 4 ver + 12 rnd | 2 var + 14 rnd |              16 rnd + 32 rnd               |
| :------------------------: | :---------: | :------------: | :------------: | :----------------------------------------: |
| 01&nbsp;92&nbsp;12&nbsp;d3 | 87&nbsp;f4  |   7d&nbsp;25   |   90&nbsp;2e   | b8&nbsp;d3&nbsp;9f&nbsp;e0&nbsp;7f&nbsp;08 |

# Table of Contents

- [Install](#install)
- [In JavaScript](#javascript-version)
- [UUIDv7 Spec](#uuidv7-spec)
  - [By the Characters](#by-the-characters)
  - [By the Bits](#by-the-bits)
- [Build](#build)
  - [Go Build (and TinyGo)](#go)
  - [Swift](#swift)
  - [Zig Build](#zig)
- [License](#license)

# Install

Pre-built archives available for Mac, Linux, & Widows. \
Compile from source for FreeBSD, OpenBSD, etc.

1. Download from GitHub Releases: <https://github.com/coolaj86/uuidv7/releases>
2. Extract
3. Place in your `PATH`

```sh
b_triplet='x86_64-linux-musl'
curl -L -O https://github.com/coolaj86/uuidv7/releases/download/v1.0.0/uuidv7-v1.0.0-"$b_triplet".tar.gz
tar xvf ./uuidv7-v1.0.0-"$b_triplet".tar.gz
mv ./uuidv7 ~/bin/
```

# JavaScript Version

Supports both `import` and `require`.

Extremely simple implementation that can be tuned for speed or memory
efficiency.

```sh
npm install --save @root/uuidv7
```

High-level API:

```js
import UUIDv7 from "@root/uuidv7";

UUIDv7.uuidv7();
// 01922aa4-88ad-7cae-a517-a298a491d35c

UUIDv7.uuidv7Bytes();
// Uint8Array(16) [ 1, 146,  42, 176, 37, 122, 114, 189
//                 172, 240,  1, 146, 42, 176,  37, 122 ]
```

Low-level API:

```js
let buffer = new Uint8Array(4096); // optional, if you need lots of UUIDs, and fast
UUIDv7.setBytesBuffer(buffer);
```

```js
let now = Date.now();
let ms64 = BigInt(now);
let bytes = new Uint8Array(16);
let start = 0;
globalThis.crypto.getRandomValues(bytes);

void UUIDv7.fill(bytes, start, ms64);

console.log(bytes);
// Uint8Array(16) [ 1, 146,  42, 176, 37, 122, 114, 189
//                 172, 240,  1, 146, 42, 176,  37, 122 ]
```

```js
let uuidv7 = UUIDv7.format(bytes);
console.log(uuidv7);
// 01922aa4-88ad-7cae-a517-a298a491d35c
```

# UUIDv7 Spec

## By the Characters

There are 36 characters total: 32 hex (`0123456789abcdef`) + 4 dashes (`-`)

```text
  8 time    4 time    1v + 3ra   ½v + 3½rb    12 random b
019212d3  -  87f4   -   7d25   -   902e   -   b8d39fe07f08
```

- 8ch hex time high
- `-`
- 4ch hex time low
- `-`
- 4ch hex version + "random a"
  - 1ch hex version: `7`
  - 3ch hex "random a"
- `-`
- 4ch hex variant + "random b"
  - 1ch hex version: `8`, `9`, `a`, `b`
  - 3ch hex "random b"
- `-`
- 12ch hex randam a
  - 4ch hex random a
  - 8ch hex random a

## By the Bits

There are 128 bits total: \
48 time and 80 random, with 4 version and 2 variant bits substituted

```text
   48 time         4ver, 12ra   2var, 14rb        random b
019212d3-87f4    -    7d25    -    902e    -    b8d39fe07f08
```

- 48 bits of timestamp
  - 32-bit high (minutes to years)
  - 16-bit low (seconds & milliseconds)
- 16 bits of version + random
  - 4-bit version (`0b0111`)
  - 12-bit random
- 64-bits variant + random
  - 2-bit variant (`0b10`)
  - 62-bit random

# Build

## Go

```sh
curl https://webi.sh/go | sh
source ~/.config/envman/PATH.env
```

For the current platform:

```sh
go build -o uuidv7 ./cmd/.
```

For Linux containers:

```sh
GOOS=linux GOARCH=amd64 GOAMD64=v2 go build -o uuidv7 ./cmd/.
```

The entire build matrix (into `./dist/`):

```sh
goreleaser --snapshot --skip=publish --clean
```

### TinyGo

```sh
curl https://webi.sh/go | sh
source ~/.config/envman/PATH.env
```

```sh
tinygo build -o uuidv7 ./cmd/.
```

```sh
GOOS=linux GOARCH=amd64 GOAMD64=v2 tinygo build -o uuidv7 ./cmd/.
```

## Swift

```sh
swift build --configuration release --show-bin-path

./.build/arm64-apple-macosx/release/uuidv7
```

## Zig

See </build.sh>.

Builds with zig v0.13 and the v0.14 previews so far.

```sh
curl https://webi.sh/zig@0.13 | sh
source ~/.config/envman/PATH.env
```

```sh
zig build-exe ./uuidv7.zig -O ReleaseSmall -femit-bin="uuidv7"

for b_target in x86-linux-musl aarch64-macos-none x86_64-windows-gnu; do
    zig build-exe ./uuidv7.zig -O ReleaseSmall \
        -target "${b_target}" -femit-bin="uuidv7-${b_target}"
done
```

# License

Copyright 2024 AJ ONeal <aj@therootcompany.com>

This Source Code Form is subject to the terms of the Mozilla Public \
License, v. 2.0. If a copy of the MPL was not distributed with this \
file, You can obtain one at https://mozilla.org/MPL/2.0/.
