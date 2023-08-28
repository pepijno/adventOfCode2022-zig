const std = @import("std");

fn part1(buffer: []const u8) u64 {
    return buffer.len;
}

fn part2(buffer: []const u8) u64 {
    return buffer.len;
}

test "Day input part 1" {
    const buf = @embedFile("inputs/dayinput.txt");
    var timer = try std.time.Timer.start();
    try std.testing.expectEqual(part1(buf), 1);
    std.debug.print("{d:9.3}ms\n", .{@as(f64, @floatFromInt(timer.lap())) / 1000000.0});
}

test "Day input part 2" {
    const buf = @embedFile("inputs/dayinput.txt");
    var timer = try std.time.Timer.start();
    try std.testing.expectEqual(part2(buf), 2);
    std.debug.print("{d:9.3}ms\n", .{@as(f64, @floatFromInt(timer.lap())) / 1000000.0});
}
