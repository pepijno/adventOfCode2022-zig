const std = @import("std");

fn isContained(a1: u64, a2: u64, b1: u64, b2: u64) bool {
    return (a1 <= b1 and a2 >= b2) or (b1 <= a1 and b2 >= a2);
}

fn part1(buffer: []const u8) !u64 {
    var lines = std.mem.tokenize(u8, buffer, "\n");
    var total: u64 = 0;
    while (lines.next()) |line| {
        var values = std.mem.tokenize(u8, line, "-,");
        const v1 = try std.fmt.parseInt(u64, values.next().?, 10);
        const v2 = try std.fmt.parseInt(u64, values.next().?, 10);
        const v3 = try std.fmt.parseInt(u64, values.next().?, 10);
        const v4 = try std.fmt.parseInt(u64, values.next().?, 10);
        total += @intFromBool(isContained(v1, v2, v3, v4));
    }
    return total;
}

fn isOverlap(a1: u64, a2: u64, b1: u64, b2: u64) bool {
    return (a1 <= b1 and b1 <= a2) or (b1 <= a1 and a1 <= b2);
}

fn part2(buffer: []const u8) !u64 {
    var lines = std.mem.tokenize(u8, buffer, "\n");
    var total: u64 = 0;
    while (lines.next()) |line| {
        var values = std.mem.tokenize(u8, line, "-,");
        const v1 = try std.fmt.parseInt(u64, values.next().?, 10);
        const v2 = try std.fmt.parseInt(u64, values.next().?, 10);
        const v3 = try std.fmt.parseInt(u64, values.next().?, 10);
        const v4 = try std.fmt.parseInt(u64, values.next().?, 10);
        total += @intFromBool(isOverlap(v1, v2, v3, v4));
    }
    return total;
}

test "Day 4 part 1" {
    const buf = @embedFile("inputs/day4.txt");
    var timer = try std.time.Timer.start();
    try std.testing.expectEqual(part1(buf), 503);
    std.debug.print("{d:9.3}ms\n", .{@as(f64, @floatFromInt(timer.lap())) / 1000000.0});
}

test "Day 4 part 2" {
    const buf = @embedFile("inputs/day4.txt");
    var timer = try std.time.Timer.start();
    try std.testing.expectEqual(part2(buf), 827);
    std.debug.print("{d:9.3}ms\n", .{@as(f64, @floatFromInt(timer.lap())) / 1000000.0});
}
