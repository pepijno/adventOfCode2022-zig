const std = @import("std");
const p = @import("parser.zig");

const parser = p.SeparatedBy(p.SeparatedBy(p.Natural(u64, 10), p.Char('-')), p.Char(','));

fn isContained(a1: u64, a2: u64, b1: u64, b2: u64) bool {
    return (a1 <= b1 and a2 >= b2) or (b1 <= a1 and b2 >= a2);
}

fn part1(buffer: []const u8) !u64 {
    const allocator = std.heap.page_allocator;

    const lines = try p.Many(p.Line()).parse(allocator, buffer);
    var total: u64 = 0;
    for (lines.value.items) |line| {
        const pairs = try parser.parse(allocator, line);
        total += @boolToInt(isContained(pairs.value.items[0].items[0], pairs.value.items[0].items[1], pairs.value.items[1].items[0], pairs.value.items[1].items[1]));
    }
    return total;
}

fn isOverlap(a1: u64, a2: u64, b1: u64, b2: u64) bool {
    return (a1 <= b1 and b1 <= a2) or (b1 <= a1 and a1 <= b2);
}

fn part2(buffer: []const u8) !u64 {
    const allocator = std.heap.page_allocator;

    const lines = try p.Many(p.Line()).parse(allocator, buffer);
    var total: u64 = 0;
    for (lines.value.items) |line| {
        const pairs = try parser.parse(allocator, line);
        total += @boolToInt(isOverlap(pairs.value.items[0].items[0], pairs.value.items[0].items[1], pairs.value.items[1].items[0], pairs.value.items[1].items[1]));
    }
    return total;
}

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();

    const buf = @embedFile("inputs/day4.txt");

    try stdout_file.print("{}\n", .{try part1(buf)});
    try stdout_file.print("{}\n", .{try part2(buf)});
}

test {
    const buf = @embedFile("inputs/day4.txt");

    try std.testing.expectEqual(part1(buf), 503);
    try std.testing.expectEqual(part2(buf), 827);
}
