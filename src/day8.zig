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
        for (line) |tree, i| {
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

    var x: u8 = 0;
    var y: u8 = 0;
    while (y < SIZE) : (y += 1) {
        try trees.put(.{ .x = 0, .y = y }, {});
        var highest_tree: u8 = grid[y][0];
        x = 1;
        while (x < SIZE) : (x += 1) {
            if (grid[y][x] > highest_tree) {
                highest_tree = grid[y][x];
                try trees.put(.{ .x = x, .y = y }, {});
            }
        }
    }

    y = 0;
    while (y < SIZE) : (y += 1) {
        try trees.put(.{ .x = SIZE - 1, .y = y }, {});
        var highest_tree: u8 = grid[y][SIZE - 1];
        var xx: i8 = SIZE - 2;
        while (xx >= 0) : (xx -= 1) {
            if (grid[y][@intCast(u8, xx)] > highest_tree) {
                highest_tree = grid[y][@intCast(u8, xx)];
                try trees.put(.{ .x = @intCast(u8, xx), .y = y }, {});
            }
        }
    }

    x = 0;
    while (x < SIZE) : (x += 1) {
        try trees.put(.{ .x = x, .y = 0 }, {});
        var highest_tree: u8 = grid[0][x];
        y = 1;
        while (y < SIZE) : (y += 1) {
            if (grid[y][x] > highest_tree) {
                highest_tree = grid[y][x];
                try trees.put(.{ .x = x, .y = y }, {});
            }
        }
    }

    x = 0;
    while (x < SIZE) : (x += 1) {
        try trees.put(.{ .x = x, .y = SIZE - 1 }, {});
        var highest_tree: u8 = grid[SIZE - 1][x];
        var yy: i8 = SIZE - 2;
        while (yy >= 0) : (yy -= 1) {
            if (grid[@intCast(u8, yy)][x] > highest_tree) {
                highest_tree = grid[@intCast(u8, yy)][x];
                try trees.put(.{ .x = x, .y = @intCast(u8, yy) }, {});
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

test {
    const buf = @embedFile("inputs/day8.txt");

    // try std.testing.expectEqual(part1(buf), 1805);
    try std.testing.expectEqual(part2(buf), 444528);
}
