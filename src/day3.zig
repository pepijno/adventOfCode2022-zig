const std = @import("std");

fn priorityValue(char: u8) u64 {
    return switch (char) {
        'a'...'z' => char - 'a' + 1,
        'A'...'Z' => char - 'A' + 27,
        else => 0,
    };
}

fn findDuplicate(line: []const u8) u64 {
    const first_half = line[0..(line.len / 2)];
    const second_half = line[(line.len / 2)..];

    var duplicate: u8 = 0;
    outer: for (first_half) |c| {
        for (second_half) |d| {
            if (c == d) {
                duplicate = c;
                break :outer;
            }
        }
    }

    return priorityValue(duplicate);
}

fn part1(buffer: []const u8) u64 {
    var lines = std.mem.tokenize(u8, buffer, "\n");
    var total: u64 = 0;
    while (lines.next()) |line| {
        total += findDuplicate(line);
    }
    return total;
}

fn findGroupBadge(line1: []const u8, line2: []const u8, line3: []const u8) u64 {
    var badge: u8 = 0;
    outer: for (line1) |a| {
        for (line2) |b| {
            if (a == b) {
                for (line3) |c| {
                    if (a == c) {
                        badge = a;
                        break :outer;
                    }
                }
            }
        }
    }

    return priorityValue(badge);
}

fn part2(buffer: []const u8) u64 {
    var lines = std.mem.tokenize(u8, buffer, "\n");
    var total: u64 = 0;
    while (lines.next()) |line| {
        total += findGroupBadge(line, lines.next().?, lines.next().?);
    }
    return total;
}

test "Day 3 part 1" {
    const buf = @embedFile("inputs/day3.txt");
    var timer = try std.time.Timer.start();
    try std.testing.expectEqual(part1(buf), 8088);
    std.debug.print("{d:9.3}ms\n", .{@intToFloat(f64, timer.lap()) / 1000000.0});
}

test "Day 3 part 2" {
    const buf = @embedFile("inputs/day3.txt");
    var timer = try std.time.Timer.start();
    try std.testing.expectEqual(part2(buf), 2522);
    std.debug.print("{d:9.3}ms\n", .{@intToFloat(f64, timer.lap()) / 1000000.0});
}
