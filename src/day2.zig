const std = @import("std");
const mainFunc = @import("base.zig").mainFunc;
const p = @import("parser.zig");

const parser = p.Many(p.Line());

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

fn part1(buffer: []const u8) !u64 {
    const allocator = std.heap.page_allocator;

    const lines = try parser.parse(allocator, buffer);
    defer lines.value.deinit();
    var total: u64 = 0;

    for (lines.value.items) |line| {
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

fn part2(buffer: []const u8) !u64 {
    const allocator = std.heap.page_allocator;

    const lines = try parser.parse(allocator, buffer);
    defer lines.value.deinit();
    var total: u64 = 0;

    for (lines.value.items) |line| {
        total += score2(line);
    }

    return total;
}

pub fn main() !void {
    try mainFunc("inputs/day2.txt", part1, part2);
}
