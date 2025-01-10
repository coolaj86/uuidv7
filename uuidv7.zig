// Bulids with zig 0.13.0 (and 0.14.0 previews)
//     zig build-exe uuidv7.zig  -O ReleaseSmall -femit-bin=uuidv7
// Copyright 2024 (c) AJ ONeal
// Licensed under the MPL-2.0

const std = @import("std");

const version = "v1.0.2"; // git describe --tags
const date = "2025-01-09T20:47:02-0700"; // date +%Y-%m-%dT%H:%M:%S%z

fn showVersion(printer: anytype) !void {
    try printer.print("uuidv7 {s} ({s})\n", .{ version, date });
}

fn showHelp(printer: anytype) !void {
    try showVersion(printer);
    try printer.print(
        \\USAGE
        \\    uuidv7 [OPTIONS]
        \\EXAMPLE
        \\    uuidv7
        \\    uuidv7 -c 10
        \\
        \\FLAGS
        \\    -V, --version    outputs version
        \\    --help           show this help message
        \\
        \\    -c, --count <n>  generate `n` uuids
        \\
    ,
        .{},
    );
}

pub fn main() !void {
    const args = try std.process.argsAlloc(std.heap.page_allocator);
    defer std.heap.page_allocator.free(args);

    const stdout = std.io.getStdOut().writer();

    var count: usize = 1;
    if (args.len > 1) {
        const flag = args[1];
        if (std.mem.eql(u8, flag, "-V") or std.mem.eql(u8, flag, "--version") or std.mem.eql(u8, flag, "version")) {
            try showVersion(stdout);
            return;
        } else if (std.mem.eql(u8, flag, "--help") or std.mem.eql(u8, flag, "help")) {
            try showHelp(stdout);
            return;
        } else if (std.mem.eql(u8, flag, "-c") or std.mem.eql(u8, flag, "--count")) {
            if (args.len > 3) {
                const arg = args[3];
                std.debug.print("unrecognized argument: '{s}'\n", .{arg});
                return error.InvalidArgument;
            }

            const num_str = args[2];
            count = std.fmt.parseInt(usize, num_str, 10) catch {
                try stdout.print("could not parse argument as positive integer: '{any}'\n", .{num_str});
                std.process.exit(1);
                return;
            };
        } else {
            std.debug.print("unrecognized flag: {s}\n\n", .{flag});
            const stderr = std.io.getStdErr().writer();
            try showHelp(stderr);
            return;
        }
    }

    for (0..count) |_| {
        const uuid7 = try UUID7.generate();
        const uuid7str = uuid7.toString();
        try stdout.print("{s}\n", .{uuid7str});
    }
}

pub const UUID7 = packed struct(u128) {
    // 48 bit big-endian unsigned number of Unix epoch timestamp as per Section 6.1.
    unix_ts_ms: u48,

    rand_0: u4,
    // 4 bit UUIDv7 version set as per Section 4
    ver: u4 = 7,

    // this with rand_0 are 12 bits of pseudo-random data to provide uniqueness as per Section 6.2 and Section 6.6.
    rand_1: u8,

    rand_2: u6,
    // The 2 bit variant defined by Section 4.
    @"var": u2 = 2,

    // this with rand_2 are the final 62 bits of pseudo-random data to provide uniqueness as per Section 6.2 and Section 6.6.
    rand_3: u56,

    fn toString(self: @This()) [36]u8 {
        // time_h32-t_16-verh-varh-rand03rand04
        // 019212d3-87f4-7d25-902e-b8d39fe07f08
        //               ^ always 7
        // 019212d3-87f4-7d25-902e-b8d39fe07f08
        //                    ^ always one of these: { 8, 9, a, b }
        const hex = std.fmt.hex(@as(u128, @bitCast(self)));
        var buffer: [36]u8 = undefined;

        _ = std.fmt.bufPrint(&buffer, "{s}-{s}-{s}-{s}-{s}", .{
            hex[0..][0..8].*,
            hex[8..][0..4].*,
            hex[12..][0..4].*,
            hex[16..][0..4].*,
            hex[20..][0..12].*,
        }) catch unreachable;

        return buffer;
    }

    fn generate() !@This() {
        var random_bytes: [10]u8 = undefined;
        try std.posix.getrandom(&random_bytes);

        const milliTimestamp: [6]u8 = @bitCast(std.mem.nativeToBig(u48, @truncate(@as(u64, @intCast(std.time.milliTimestamp())))));

        var result: @This() = @bitCast(milliTimestamp ++ random_bytes);
        result.ver = 7;
        result.@"var" = 2;
        return result;
    }
};
