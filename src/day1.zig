const std = @import("std");

fn sumFoods(buffer: []const u8) !std.ArrayList(u64) {
    const allocator = std.heap.page_allocator;

    var foods = std.ArrayList(u64).init(allocator);

    var lines = std.mem.split(u8, buffer, "\n");
    var total: u64 = 0;
    while (lines.next()) |line| {
        if (line.len == 0) {
            try foods.append(total);
            total = 0;
        } else {
            const food = try std.fmt.parseInt(u64, line, 10);
            total += food;
        }
    }
    try foods.append(total);

    return foods;
}

fn part1(buffer: []const u8) u64 {
    const foods = sumFoods(buffer) catch unreachable;
    defer foods.deinit();
    std.sort.sort(u64, foods.items, {}, comptime std.sort.desc(u64));
    return foods.items[0];
}

fn part2(buffer: []const u8) u64 {
    const foods = sumFoods(buffer) catch unreachable;
    defer foods.deinit();
    std.sort.sort(u64, foods.items, {}, comptime std.sort.desc(u64));
    return foods.items[0] + foods.items[1] + foods.items[2];
}

test {
    const buf = @embedFile("inputs/day1.txt");

    try std.testing.expectEqual(part1(buf), 69883);
    try std.testing.expectEqual(part2(buf), 207576);
}
