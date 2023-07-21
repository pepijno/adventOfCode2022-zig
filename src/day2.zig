const std = @import("std");
const p = @import("parser.zig");

fn score1(line: []const u8) u64 {
    const enemy = line[0];
    const mine = line[2];
    return switch (enemy) {
        'A' => {
            return switch (mine) {
                'X' => 4,
                'Y' => 8,
                'Z' => 3,
                else => 0,
            };
        },
        'B' => {
            return switch (mine) {
                'X' => 1,
                'Y' => 5,
                'Z' => 9,
                else => 0,
            };
        },
        'C' => {
            return switch (mine) {
                'X' => 7,
                'Y' => 2,
                'Z' => 6,
                else => 0,
            };
        },
        else => 0,
    };
}

fn part1(buffer: []const u8) u64 {
    var lines = std.mem.tokenize(u8, buffer, "\n");
    var total: u64 = 0;

    while (lines.next()) |line| {
        total += score1(line);
    }

    return total;
}

fn score2(line: []const u8) u64 {
    const enemy = line[0];
    const mine = line[2];
    return switch (enemy) {
        'A' => {
            return switch (mine) {
                'X' => 3,
                'Y' => 4,
                'Z' => 8,
                else => 0,
            };
        },
        'B' => {
            return switch (mine) {
                'X' => 1,
                'Y' => 5,
                'Z' => 9,
                else => 0,
            };
        },
        'C' => {
            return switch (mine) {
                'X' => 2,
                'Y' => 6,
                'Z' => 7,
                else => 0,
            };
        },
        else => 0,
    };
}

fn part2(buffer: []const u8) u64 {
    var lines = std.mem.tokenize(u8, buffer, "\n");
    var total: u64 = 0;

    while (lines.next()) |line| {
        total += score2(line);
    }

    return total;
}

test {
    const buf = @embedFile("inputs/day2.txt");

    try std.testing.expectEqual(part1(buf), 13009);
    try std.testing.expectEqual(part2(buf), 10398);
}
