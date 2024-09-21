// Bulids with zig 0.13.0 (and 0.14.0 previews)
//     zig build-exe uuidv7.zig  -O ReleaseSmall -femit-bin=uuidv7
// Copyright 2024 (c) AJ ONeal
// Licensed under the MPL-2.0

const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const uuid7 = try UUID7.generate();
    const uuid7str = try uuid7.toString();
    try stdout.print("{s}\n", .{uuid7str});
}

pub const UUID7 = packed struct {
    // 48 bit big-endian unsigned number of Unix epoch timestamp as per Section 6.1.
    unix_ts_ms: u48,

    // 4 bit UUIDv7 version set as per Section 4
    ver: u4 = 7,

    // 12 bits pseudo-random data to provide uniqueness as per Section 6.2 and Section 6.6.
    rand_a: u12,

    // The 2 bit variant defined by Section 4.
    @"var": u2 = 2,

    // The final 62 bits of pseudo-random data to provide uniqueness as per Section 6.2 and Section 6.6.
    rand_b: u62,

    fn toString(self: @This()) ![36]u8 {
        // time_h32-t_16-verh-varh-rand03rand04
        // 019212d3-87f4-7d25-902e-b8d39fe07f08
        const hex = std.fmt.hex(@as(u128, @bitCast(self)));
        var buffer: [36]u8 = undefined;

        _ = try std.fmt.bufPrint(&buffer, "{s}-{s}-{s}-{s}-{s}", .{
            hex[0..][0..8].*,
            hex[8..][0..4].*,
            hex[12..][0..4].*,
            hex[16..][0..4].*,
            hex[20..][0..12].*,
        });

        return buffer;
    }

    fn generate() !@This() {
        // Get the current Unix timestamp in milliseconds
        var random_bytes: [10]u8 = undefined;
        try std.posix.getrandom(&random_bytes);

        return .{
            .unix_ts_ms = std.mem.nativeToBig(u48, @truncate(@as(u64, @intCast(std.time.milliTimestamp())))),
            .rand_a = @truncate(@as(u16, @bitCast(random_bytes[0..2].*))),
            .rand_b = @truncate(@as(u64, @bitCast(random_bytes[2..10].*))),
        };
    }
};
