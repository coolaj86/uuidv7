/**
 * UUIDv7.js - Simple and Outrageously Efficient UUIDv7 Generation,
 * for Browsers, Node, Bun, etc - everywhere JavaScript™ is sold.
 *
 * Copyright 2024 AJ ONeal <aj@therootcompany.com>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

const UUID_SIZE = 16;
const WINDOW_SIZE = 10;
const TIME_SIZE = 6;
const HEX_RADIX = 16;

let UUIDv7 = {};

UUIDv7._crypto = globalThis.crypto;

UUIDv7._buffer = new Uint8Array(UUID_SIZE * 6); // for efficiency
UUIDv7._cursor = UUIDv7._buffer.length;

/**
 * Generates a new UUIDv7 string from the given or current time.
 * @param {Number} [ms] - time in milliseconds, e.g. Date.now()
 */
UUIDv7.uuidv7 = function (ms) {
  let uuid = UUIDv7.uuidv7Bytes(ms);
  let uuidStr = UUIDv7.format(uuid);
  return uuidStr;
};

/**
 * Generates a slice of UUIDv7 bytes using the given or current time and random buffer.
 * @param {Number} [ms] - time in milliseconds, e.g. Date.now()
 */
UUIDv7.uuidv7Bytes = function (ms) {
  let uuid = UUIDv7._nextSubarray();

  if (!ms) {
    ms = Date.now();
  }
  let ms64 = BigInt(ms);

  void UUIDv7.fill(uuid, UUIDv7._cursor, ms64);
  uuid = uuid.slice(0, UUID_SIZE);

  return uuid;
};

/**
 * Creates a formatted UUIDv7 string from the given bytes.
 * @param {Uint8Array} bytes
 */
UUIDv7.format = function (bytes) {
  let hs = [];
  for (let b of bytes) {
    let h = b.toString(HEX_RADIX);
    h = h.padStart(2, "0"); // 0x1 => 0x01
    hs.push(h);
  }
  let hex = hs.join("");

  let uuidv7 = [
    hex.slice(0, 8),
    hex.slice(8, 12),
    hex.slice(12, 16),
    hex.slice(16, 20),
    hex.slice(20, 32),
  ].join("-");

  return uuidv7;
};

/** @typedef {bigint} BigInt */

/**
 * Fills the given pre-randomized bytes with the lower 48 bits of the given BigInt time.
 * @param {BigInt} ms64
 * @param {Number} start - typically 0
 * @param {Uint8Array} uuid - pre-randomized
 */
UUIDv7.fill = function (uuid, start, ms64) {
  let timeHigh64 = ms64 >> 16n; // drop the lower 16 bits (to get the upper 32 of the 48)
  let timeHigh = Number(timeHigh64);
  let timeLow64 = ms64 & 0xffffn; // the original lower 16 bits
  let timeLow = Number(timeLow64);

  let dv = new DataView(uuid.buffer, start, TIME_SIZE);
  dv.setUint32(0, timeHigh, false); // high 32 bits of time
  dv.setUint16(4, timeLow, false); // low 16 bits of time

  // set the top 4 bits to 0b0111 (0x7 for UUID v7)
  uuid[6] = uuid[6] & 0x0f;
  uuid[6] = uuid[6] | 0x70;

  // set to top 2 bits to 0b10 (RFC 4122 UUID variant)
  uuid[8] = uuid[8] & 0x3f;
  uuid[8] = uuid[8] | 0x80;
};

/**
 * Sets a buffer to be used for random data.
 * @param {Uint8Array?} bytes
 */
UUIDv7.setBytesBuffer = function (bytes) {
  if (!bytes) {
    bytes = new Uint8Array(4096); // 1 page of memory
  }
  if (bytes.length < UUID_SIZE) {
    throw new Error(`minimum UUIDv7 buffer size is ${UUID_SIZE} bytes`);
  }

  UUIDv7._buffer = bytes;
  UUIDv7._cursor = bytes.length;
};

/**
 * (Internal) advances the random buffer cursor, potentially refilling the buffer,
 * and returns a subarray of the random bytes.
 */
UUIDv7._nextSubarray = function () {
  // We advance 10 rather than 16 so that the used random bytes
  // can be overwritten by the time and not waste unused random bytes
  // 1. 6time + 4rand + 6rand
  // 2.                 6time + 4rand + 6rand
  // 3.                                 6time + 4rand + 6rand
  // Note: this means that 10*n + 16 are the most efficient buffer sizes
  //       such as 16, 96, 176, 256, etc
  UUIDv7._cursor += WINDOW_SIZE;

  let end = UUIDv7._cursor + UUID_SIZE;
  if (end > UUIDv7._buffer.length) {
    UUIDv7._crypto.getRandomValues(UUIDv7._buffer);
    UUIDv7._cursor = 0;
    end = UUID_SIZE;
  }

  let bytes = UUIDv7._buffer.subarray(UUIDv7._cursor, end);
  return bytes;
};

export default UUIDv7;
