const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    const uuid7 = try generateUUIDv7(std.posix.getrandom);
    const uuid7str = try uuidToString(uuid7);
    try stdout.print("{s}\n", .{uuid7str});
}

pub const UUID = struct {
    time_high: u32,
    time_low: u16,
    version_random1: u16,
    variant_random2: u16,
    random3: u16,
    random4: u32,
};

fn generateUUIDv7(getrandom: anytype) !UUID {
    // Get the current Unix timestamp in milliseconds
    const inow = std.time.milliTimestamp();
    const now: u64 = @intCast(inow); // we use 48 bits

    const time_low: u16 = @truncate(now);
    const time_high: u32 = @truncate(now >> 16);

    const version = (0b111 << 12); // 0b111 is the 7 in UUIDv7
    const version_mask = 0x0FFF;

    const variant = (0b10 << 14); // 0b10 is the endianness-indicating variant
    const variant_mask = 0b0011111111111111;

    var random_bytes: [10]u8 = undefined;
    try getrandom(&random_bytes);

    const version_random1: u16 = (((@as(u16, random_bytes[0]) << 8) | @as(u16, random_bytes[1])) &
        version_mask) | version;
    const variant_random2: u16 = ((((@as(u16, random_bytes[2]) << 8) | @as(u16, random_bytes[3])) &
        variant_mask)) | variant;
    const random3: u16 = (@as(u16, random_bytes[4]) << 8) | @as(u16, random_bytes[5]);
    const random4: u32 = (@as(u32, random_bytes[6]) << 24) |
        (@as(u32, random_bytes[7]) << 16) |
        (@as(u32, random_bytes[8]) << 8) |
        @as(u32, random_bytes[9]);

    return UUID{
        .time_high = time_high,
        .time_low = time_low,
        .version_random1 = version_random1,
        .variant_random2 = variant_random2,
        .random3 = random3,
        .random4 = random4,
    };
}

fn uuidToString(uuid: UUID) ![]const u8 {
    var buffer: [128]u8 = undefined;
    // time_h32-t_16-verh-varh-rand03rand04
    // 019212d3-87f4-7d25-902e-b8d39fe07f08
    // 70000192-12d3-2252-4dc7-3ca1786320db3172
    return std.fmt.bufPrint(&buffer, "{x:08}-{x}-{x}-{x:04}-{x:04}{x:08}", .{ uuid.time_high, uuid.time_low, uuid.version_random1, uuid.variant_random2, uuid.random3, uuid.random4 });
}