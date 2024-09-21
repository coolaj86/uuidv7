# [zig-uuidv7](https://github.com/coolaj86/zig-uuidv7)

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

-   [UUIDv7 Spec](#uuidv7-spec)
    -   [By the Characters](#by-the-characters)
    -   [By the Bits](#by-the-bits)
-   [Build](#build)
-   [License](#license)

# UUIDv7 Spec

## By the Characters

There are 36 characters total: 32 hex (`0123456789abcdef`) + 4 dashes (`-`)

```text
  8 time    4 time    1v + 3ra   ½v + 3½rb    12 random b
019212d3  -  87f4   -   7d25   -   902e   -   b8d39fe07f08
```

-   8ch hex time high
-   `-`
-   4ch hex time low
-   `-`
-   4ch hex version + "random a"
    -   1ch hex version: `7`
    -   3ch hex "random a"
-   `-`
-   4ch hex variant + "random b"
    -   1ch hex version: `8`, `9`, `a`, `b`
    -   3ch hex "random b"
-   `-`
-   12ch hex randam a
    -   4ch hex random a
    -   8ch hex random a

## By the Bits

```text
   48 time         4ver, 12ra   2var, 14rb        random b
019212d3-87f4    -    7d25    -    902e    -    b8d39fe07f08
```

-   48 bits of timestamp
    -   32-bit high (minutes to years)
    -   16-bit low (seconds & milliseconds)
-   16 bits of version + random
    -   4-bit version (`0b0111`)
    -   12-bit random
-   64-bits variant + random
    -   2-bit variant (`0b10`)
    -   62-bit random

# Build

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
