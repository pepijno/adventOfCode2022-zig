const std = @import("std");

const height = 41;
const width = 81;

const Point = struct {
    x: u8,
    y: u8,

    fn neighbors(self: @This(), allocator: std.mem.Allocator) !std.ArrayList(Point) {
        var points = std.ArrayList(Point).init(allocator);

        if (self.x != 0) {
            try points.append(.{ .x = self.x - 1, .y = self.y });
        }
        if (self.y != 0) {
            try points.append(.{ .x = self.x, .y = self.y - 1 });
        }
        if (self.x != width - 1) {
            try points.append(.{ .x = self.x + 1, .y = self.y });
        }
        if (self.y != height - 1) {
            try points.append(.{ .x = self.x, .y = self.y + 1 });
        }

        return points;
    }
};

fn createGrid(buffer: []const u8, start: *Point, end: *Point) [width][height]u8 {
    var grid: [width][height]u8 = std.mem.zeroes([width][height]u8);
    var lines = std.mem.tokenize(u8, buffer, "\n");
    var y: u8 = 0;
    while (lines.next()) |line| {
        var x: u8 = 0;
        for (line) |char| {
            if (char == 'S') {
                grid[x][y] = 0;
                start.*.x = x;
                start.*.y = y;
            } else if (char == 'E') {
                grid[x][y] = 25;
                end.*.x = x;
                end.*.y = y;
            } else {
                grid[x][y] = char - 'a';
            }
            x += 1;
        }
        y += 1;
    }
    return grid;
}

fn bfs(allocator: std.mem.Allocator, grid: [width][height]u8, start: Point) ![width][height]u16 {
    var visited = std.mem.zeroes([width][height]bool);
    var lengths = [_][height]u16{[_]u16{width * height} ** height} ** width;

    var queue = std.ArrayList(Point).init(allocator);
    lengths[start.x][start.y] = 0;
    visited[start.x][start.y] = true;

    const ns = try start.neighbors(allocator);
    defer ns.deinit();
    for (ns.items) |neighbor| {
        if (grid[neighbor.x][neighbor.y] == grid[start.x][start.y] or grid[neighbor.x][neighbor.y] == grid[start.x][start.y] + 1) {
            try queue.insert(0, neighbor);
        }
    }

    while (queue.popOrNull()) |point| {
        if (visited[point.x][point.y]) {
            continue;
        }

        const neighbors = try point.neighbors(allocator);
        defer neighbors.deinit();

        var min: ?u16 = null;
        for (neighbors.items) |neighbor| {
            if (grid[neighbor.x][neighbor.y] >= grid[point.x][point.y] or grid[neighbor.x][neighbor.y] + 1 == grid[point.x][point.y]) {
                const val = lengths[neighbor.x][neighbor.y];
                if (min == null or val < min.?) {
                    min = val;
                }
            }

            if (grid[neighbor.x][neighbor.y] <= grid[point.x][point.y] or grid[neighbor.x][neighbor.y] == grid[point.x][point.y] + 1) {
                try queue.insert(0, neighbor);
            }
        }
        if (min) |val| {
            lengths[point.x][point.y] = val + 1;
        }

        visited[point.x][point.y] = true;
    }

    return lengths;
}

fn part1(buffer: []const u8) !u64 {
    var allocator = std.heap.page_allocator;

    var start: Point = .{ .x = 0, .y = 0 };
    var end: Point = .{ .x = 0, .y = 0 };

    const grid = createGrid(buffer, &start, &end);

    const lengths = try bfs(allocator, grid, start);

    return lengths[end.x][end.y];
}

fn part2(buffer: []const u8) !u64 {
    var allocator = std.heap.page_allocator;

    var start: Point = .{ .x = 0, .y = 0 };
    var end: Point = .{ .x = 0, .y = 0 };

    var grid = createGrid(buffer, &start, &end);
    for (0..height) |y| {
        for (0..width) |x| {
            grid[x][y] = 25 - grid[x][y];
        }
    }

    const lengths = try bfs(allocator, grid, end);

    var min: u16 = width * height;
    for (0..height) |y| {
        for (0..width) |x| {
            if (grid[x][y] == 25 and lengths[x][y] < min) {
                min = lengths[x][y];
            }
        }
    }

    return min;
}

test "Day 12 part 1" {
    const buf = @embedFile("inputs/day12.txt");
    var timer = try std.time.Timer.start();
    try std.testing.expectEqual(part1(buf), 350);
    std.debug.print("{d:9.3}ms\n", .{@as(f64, @floatFromInt(timer.lap())) / 1000000.0});
}

test "Day 12 part 2" {
    const buf = @embedFile("inputs/day12.txt");
    var timer = try std.time.Timer.start();
    try std.testing.expectEqual(part2(buf), 349);
    std.debug.print("{d:9.3}ms\n", .{@as(f64, @floatFromInt(timer.lap())) / 1000000.0});
}
