const std = @import("std");

fn findStartOfMessageMarker(comptime window: u64, buffer: []const u8) u64 {
    var lines = std.mem.tokenize(u8, buffer, "\n");
    var total: u64 = 0;
    while (lines.next()) |line| {
        var i: u64 = 0;
        while (true) : (i += 1) {
            var j: u64 = 0;
            var bit_set = std.bit_set.IntegerBitSet(26).initEmpty();
            while (j < window) : (j += 1) {
                const bit = @intCast(usize, line[i + j] - 'a');
                if (bit_set.isSet(bit)) {
                    break;
                }
                bit_set.set(bit);
            }
            if (bit_set.count() == window) {
                total += i + window;
                break;
            }
        }
    }
    return total;
}

fn part1(buffer: []const u8) u64 {
    return findStartOfMessageMarker(4, buffer);
}

fn part2(buffer: []const u8) u64 {
    return findStartOfMessageMarker(14, buffer);
}

test "Day 6 part 1" {
    const buf = @embedFile("inputs/day6.txt");
    var timer = try std.time.Timer.start();
    try std.testing.expectEqual(part1(buf), 1300);
    std.debug.print("{d:9.3}ms\n", .{@intToFloat(f64, timer.lap()) / 1000000.0});
}

test "Day 6 part 2" {
    const buf = @embedFile("inputs/day6.txt");
    var timer = try std.time.Timer.start();
    try std.testing.expectEqual(part2(buf), 3986);
    std.debug.print("{d:9.3}ms\n", .{@intToFloat(f64, timer.lap()) / 1000000.0});
}
