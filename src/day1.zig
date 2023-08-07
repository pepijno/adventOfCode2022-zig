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

test "Day 1 part 1" {
    const buf = @embedFile("inputs/day1.txt");
    var timer = try std.time.Timer.start();
    try std.testing.expectEqual(part1(buf), 69883);
    std.debug.print("{d:9.3}ms\n", .{@intToFloat(f64, timer.lap()) / 1000000.0});
}

test "Day 1 part 2" {
    const buf = @embedFile("inputs/day1.txt");
    var timer = try std.time.Timer.start();
    try std.testing.expectEqual(part2(buf), 207576);
    std.debug.print("{d:9.3}ms\n", .{@intToFloat(f64, timer.lap()) / 1000000.0});
}
