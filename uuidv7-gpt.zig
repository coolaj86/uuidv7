const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    const uuid7 = try generateUUIDv7(std.posix.getrandom);
    const uuid7str = try uuidToString(uuid7);
    try stdout.print("{s}\n", .{uuid7str});
}

pub const UUID = struct {
    time_high_and_version: u32,
    time_mid: u16,
    time_low: u16,
    random_a: u16,
    random_b: u64,
};

fn generateUUIDv7(getrandom: anytype) !UUID {
    // Get the current Unix timestamp in milliseconds
    const inow = std.time.milliTimestamp();
    const now: u64 = @intCast(inow);

    // Split the timestamp into parts for the UUID format
    const time_low: u16 = @truncate(now); // The lowest 16 bits
    const time_mid: u16 = @truncate(now >> 16); // The next 16 bits
    const time_high_and_version = @as(u32, @truncate(now >> 32)) & 0x0FFFFFFF; // The next 28 bits
    const version: u32 = 0b0111 << 28; // UUID version 7 has the version bits 0111 in the 4 most significant bits

    // Combine the version bits with the timestamp bits
    const final_time_high_and_version: u32 = time_high_and_version | (version);

    // Generate 74 bits of random data (we'll use two parts)
    var random_bytes: [10]u8 = undefined;
    try getrandom(&random_bytes);

    const random_a = (@as(u16, random_bytes[0]) << 8) | @as(u16, random_bytes[1]); // 16 bits
    const random_b = (@as(u64, random_bytes[2]) << 56) |
        (@as(u64, random_bytes[3]) << 48) |
        (@as(u64, random_bytes[4]) << 40) |
        (@as(u64, random_bytes[5]) << 32) |
        (@as(u64, random_bytes[6]) << 24) |
        (@as(u64, random_bytes[7]) << 16) |
        (@as(u64, random_bytes[8]) << 8) |
        @as(u64, random_bytes[9]); // 48 bits

    return UUID{
        .time_high_and_version = final_time_high_and_version,
        .time_mid = time_mid,
        .time_low = time_low,
        .random_a = random_a,
        .random_b = random_b,
    };
}

fn uuidToString(uuid: UUID) ![]const u8 {
    var buffer: [128]u8 = undefined;
    return std.fmt.bufPrint(&buffer, "{x}-{x}-{x}-{x}-{x}", .{ uuid.time_high_and_version, uuid.time_mid, uuid.time_low, uuid.random_a, uuid.random_b });
}