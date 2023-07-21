const std = @import("std");

fn part1(buffer: []const u8) u64 {
    return buffer.len;
}

fn part2(buffer: []const u8) u64 {
    return buffer.len;
}

test {
    const buf = @embedFile("inputs/dayinput.txt");

    try std.testing.expectEqual(part1(buf), 1);
    try std.testing.expectEqual(part2(buf), 2);
}
