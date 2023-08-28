const std = @import("std");

const SIZE: u8 = 99;

const Point = struct {
    x: u8,
    y: u8,
};

fn parseTrees(buffer: []const u8) [SIZE][SIZE]u8 {
    var grid = std.mem.zeroes([SIZE][SIZE]u8);

    var lines = std.mem.tokenize(u8, buffer, "\n");
    var y: u8 = 0;
    while (lines.next()) |line| {
        for (line, 0..) |tree, i| {
            grid[y][i] = tree - '0';
        }
        y += 1;
    }
    return grid;
}

fn part1(buffer: []const u8) !u64 {
    const allocator = std.heap.page_allocator;

    const grid = parseTrees(buffer);

    var trees = std.AutoHashMap(Point, void).init(allocator);
    defer trees.deinit();

    for (0..SIZE) |y| {
        try trees.put(.{ .x = 0, .y = @intCast(y) }, {});
        var highest_tree: u8 = grid[y][0];
        for (1..SIZE) |x| {
            if (grid[y][x] > highest_tree) {
                highest_tree = grid[y][x];
                try trees.put(.{ .x = @intCast(x), .y = @intCast(y) }, {});
            }
        }
    }

    for (0..SIZE) |y| {
        try trees.put(.{ .x = SIZE - 1, .y = @intCast(y) }, {});
        var highest_tree: u8 = grid[y][SIZE - 1];
        var xx: i8 = SIZE - 2;
        while (xx >= 0) : (xx -= 1) {
            if (grid[y][@as(u8, @intCast(xx))] > highest_tree) {
                highest_tree = grid[y][@intCast(xx)];
                try trees.put(.{ .x = @intCast(xx), .y = @intCast(y) }, {});
            }
        }
    }

    for (0..SIZE) |x| {
        try trees.put(.{ .x = @intCast(x), .y = 0 }, {});
        var highest_tree: u8 = grid[0][x];
        for (1..SIZE) |y| {
            if (grid[y][x] > highest_tree) {
                highest_tree = grid[y][x];
                try trees.put(.{ .x = @intCast(x), .y = @intCast(y) }, {});
            }
        }
    }

    for (0..SIZE) |x| {
        try trees.put(.{ .x = @intCast(x), .y = SIZE - 1 }, {});
        var highest_tree: u8 = grid[SIZE - 1][x];
        var yy: i8 = SIZE - 2;
        while (yy >= 0) : (yy -= 1) {
            if (grid[@as(u8, @intCast(yy))][x] > highest_tree) {
                highest_tree = grid[@intCast(yy)][x];
                try trees.put(.{ .x = @intCast(x), .y = @intCast(yy) }, {});
            }
        }
    }

    return trees.count();
}

fn part2(buffer: []const u8) u64 {
    const grid = parseTrees(buffer);

    var y: u8 = 1;
    var max: u64 = 0;
    while (y < SIZE - 1) : (y += 1) {
        var x: u8 = 1;
        while (x < SIZE - 1) : (x += 1) {
            var ans: u64 = 1;
            const tree_height = grid[x][y];

            var n_trees: u8 = 0;
            var row: u8 = x + 1;
            while (true) : (row += 1) {
                n_trees += 1;
                if (row == SIZE - 1 or grid[row][y] >= tree_height) {
                    break;
                }
            }
            ans *= n_trees;

            n_trees = 0;
            row = x - 1;
            while (true) : (row -= 1) {
                n_trees += 1;
                if (row == 0 or grid[row][y] >= tree_height) {
                    break;
                }
            }
            ans *= n_trees;

            n_trees = 0;
            var col: u8 = y + 1;
            while (true) : (col += 1) {
                n_trees += 1;
                if (col == SIZE - 1 or grid[x][col] >= tree_height) {
                    break;
                }
            }
            ans *= n_trees;

            n_trees = 0;
            col = y - 1;
            while (true) : (col -= 1) {
                n_trees += 1;
                if (col == 0 or grid[x][col] >= tree_height) {
                    break;
                }
            }
            ans *= n_trees;

            if (ans > max) {
                max = ans;
            }
        }
    }

    return max;
}

test "Day 8 part 1" {
    const buf = @embedFile("inputs/day8.txt");
    var timer = try std.time.Timer.start();
    try std.testing.expectEqual(part1(buf), 1805);
    std.debug.print("{d:9.3}ms\n", .{@as(f64, @floatFromInt(timer.lap())) / 1000000.0});
}

test "Day 8 part 2" {
    const buf = @embedFile("inputs/day8.txt");
    var timer = try std.time.Timer.start();
    try std.testing.expectEqual(part2(buf), 444528);
    std.debug.print("{d:9.3}ms\n", .{@as(f64, @floatFromInt(timer.lap())) / 1000000.0});
}
