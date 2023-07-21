const std = @import("std");
const parser = @import("parser.zig");

const newline_parser = parser.Char('\n');
const pars = parser.SeparatedBy(parser.SeparatedBy(parser.Natural(u64, 10), newline_parser), newline_parser);

fn part1(buffer: []const u8) !u64 {
    const allocator = std.heap.page_allocator;

    const result = try pars.parse(allocator, buffer);
    defer result.value.deinit();

    var totals = std.ArrayList(u64).init(allocator);
    defer totals.deinit();
    for (result.value.items) |foods| {
        var total: u64 = 0;
        for (foods.items) |item| {
            total += item;
        }
        try totals.append(total);
    }

    std.sort.sort(u64, totals.items, {}, comptime std.sort.desc(u64));
    return totals.items[0];
}

fn part2(buffer: []const u8) !u64 {
    const allocator = std.heap.page_allocator;

    const result = try pars.parse(allocator, buffer);
    defer result.value.deinit();

    var totals = std.ArrayList(u64).init(allocator);
    defer totals.deinit();
    for (result.value.items) |foods| {
        var total: u64 = 0;
        for (foods.items) |item| {
            total += item;
        }
        try totals.append(total);
    }

    std.sort.sort(u64, totals.items, {}, comptime std.sort.desc(u64));
    return totals.items[0] + totals.items[1] + totals.items[2];
}

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();

    const buf = @embedFile("inputs/day1.txt");

    try stdout_file.print("{}\n", .{try part1(buf)});
    try stdout_file.print("{}\n", .{try part2(buf)});
}

test {
    const buf = @embedFile("inputs/day1.txt");

    try std.testing.expectEqual(part1(buf), 69883);
    try std.testing.expectEqual(part2(buf), 207576);
}
