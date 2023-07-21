const std = @import("std");
const p = @import("parser.zig");

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

const parser = p.Many(p.Line());

fn part1(buffer: []const u8) !u64 {
    const allocator = std.heap.page_allocator;

    const lines = try parser.parse(allocator, buffer);
    var total: u64 = 0;
    for (lines.value.items) |line| {
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

fn part2(buffer: []const u8) !u64 {
    const allocator = std.heap.page_allocator;

    const lines = try parser.parse(allocator, buffer);
    var total: u64 = 0;
    var i: usize = 0;

    while (i < lines.value.items.len) : (i += 3) {
        total += findGroupBadge(lines.value.items[i], lines.value.items[i + 1], lines.value.items[i + 2]);
    }

    return total;
}

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();

    const buf = @embedFile("inputs/day3.txt");

    try stdout_file.print("{}\n", .{try part1(buf)});
    try stdout_file.print("{}\n", .{try part2(buf)});
}

test {
    const buf = @embedFile("inputs/day3.txt");

    try std.testing.expectEqual(part1(buf), 8088);
    try std.testing.expectEqual(part2(buf), 2522);
}
