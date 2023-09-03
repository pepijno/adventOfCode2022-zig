const std = @import("std");

const Point = struct {
    x: i64,
    y: i64,
    z: i64,

    fn neighbors(self: @This()) [6]Point {
        return [_]Point{
            .{ .x = self.x - 1, .y = self.y, .z = self.z },
            .{ .x = self.x + 1, .y = self.y, .z = self.z },
            .{ .x = self.x, .y = self.y - 1, .z = self.z },
            .{ .x = self.x, .y = self.y + 1, .z = self.z },
            .{ .x = self.x, .y = self.y, .z = self.z - 1 },
            .{ .x = self.x, .y = self.y, .z = self.z + 1 },
        };
    }
};

fn part1(buffer: []const u8) !u64 {
    const allocator = std.heap.page_allocator;

    var coords = std.AutoHashMap(Point, void).init(allocator);

    var lines = std.mem.tokenize(u8, buffer, "\n");
    while (lines.next()) |line| {
        var cs = std.mem.split(u8, line, ",");
        const x = try std.fmt.parseInt(i64, cs.next().?, 10);
        const y = try std.fmt.parseInt(i64, cs.next().?, 10);
        const z = try std.fmt.parseInt(i64, cs.next().?, 10);
        try coords.put(.{ .x = x, .y = y, .z = z }, {});
    }

    var total: u64 = 0;
    var iterator = coords.keyIterator();
    while (iterator.next()) |coord| {
        const neighbors = coord.neighbors();
        for (neighbors) |neighbor| {
            if (coords.getKey(neighbor) == null) {
                total += 1;
            }
        }
    }

    return total;
}

fn bfs(coords: std.AutoHashMap(Point, void), had: *std.AutoHashMap(Point, void), queue: *std.ArrayList(Point), n: u64) !u64 {
    if (queue.items.len == 0) {
        return n;
    }
    const curr = queue.pop();
    if (had.getKey(curr) != null) {
        return bfs(coords, had, queue, n);
    }

    const neighbors = curr.neighbors();
    var sides: u64 = 0;
    for (neighbors) |neighbor| {
        if (coords.getKey(neighbor) != null) {
            sides += 1;
        }
        if (coords.getKey(neighbor) == null and had.getKey(neighbor) == null) {
            try queue.append(neighbor);
        }
    }
    try had.put(curr, {});

    return bfs(coords, had, queue, n + sides);
}

fn part2(buffer: []const u8) !u64 {
    const allocator = std.heap.page_allocator;

    var coords = std.AutoHashMap(Point, void).init(allocator);

    var min_x: i64 = 1000000000;
    var max_x: i64 = 0;
    var min_y: i64 = 1000000000;
    var max_y: i64 = 0;
    var min_z: i64 = 1000000000;
    var max_z: i64 = 0;
    var lines = std.mem.tokenize(u8, buffer, "\n");
    while (lines.next()) |line| {
        var cs = std.mem.split(u8, line, ",");
        const x = try std.fmt.parseInt(i64, cs.next().?, 10);
        const y = try std.fmt.parseInt(i64, cs.next().?, 10);
        const z = try std.fmt.parseInt(i64, cs.next().?, 10);
        if (x < min_x) {
            min_x = x;
        }
        if (x > max_x) {
            max_x = x;
        }
        if (y < min_y) {
            min_y = y;
        }
        if (y > max_y) {
            max_y = y;
        }
        if (z < min_z) {
            min_z = z;
        }
        if (z > max_z) {
            max_z = z;
        }
        try coords.put(.{ .x = x, .y = y, .z = z }, {});
    }

    var edges = std.AutoHashMap(Point, void).init(allocator);
    var y: i64 = min_y - 4;
    while (y < max_y + 4) : (y += 1) {
        var z: i64 = min_z - 4;
        while (z < max_z + 4) : (z += 1) {
            try edges.put(.{ .x = min_x - 4, .y = y, .z = z }, {});
        }
    }
    y = min_y - 4;
    while (y < max_y + 4) : (y += 1) {
        var z: i64 = min_z - 4;
        while (z < max_z + 4) : (z += 1) {
            try edges.put(.{ .x = max_x + 4, .y = y, .z = z }, {});
        }
    }
    var x: i64 = min_x - 4;
    while (x < max_x + 4) : (x += 1) {
        var z: i64 = min_z - 4;
        while (z < max_z + 4) : (z += 1) {
            try edges.put(.{ .x = x, .y = min_y - 4, .z = z }, {});
        }
    }
    x = min_x - 4;
    while (x < max_x + 4) : (x += 1) {
        var z: i64 = min_z - 4;
        while (z < max_z + 4) : (z += 1) {
            try edges.put(.{ .x = x, .y = max_y + 4, .z = z }, {});
        }
    }
    y = min_y - 4;
    while (y < max_y + 4) : (y += 1) {
        x = min_x - 4;
        while (x < max_x + 4) : (x += 1) {
            try edges.put(.{ .x = x, .y = y, .z = min_z - 4 }, {});
        }
    }
    y = min_y - 4;
    while (y < max_y + 4) : (y += 1) {
        x = min_x - 4;
        while (x < max_x + 4) : (x += 1) {
            try edges.put(.{ .x = x, .y = y, .z = max_z + 4 }, {});
        }
    }

    var queue = std.ArrayList(Point).init(allocator);
    try queue.append(.{ .x = 1, .y = 1, .z = 1 });
    return try bfs(coords, &edges, &queue, 0);
}

test "Day input part 1" {
    const buf = @embedFile("inputs/day18.txt");
    var timer = try std.time.Timer.start();
    try std.testing.expectEqual(part1(buf), 4332);
    std.debug.print("{d:9.3}ms\n", .{@as(f64, @floatFromInt(timer.lap())) / 1000000.0});
}

test "Day input part 2" {
    const buf = @embedFile("inputs/day18.txt");
    var timer = try std.time.Timer.start();
    try std.testing.expectEqual(part2(buf), 2524);
    std.debug.print("{d:9.3}ms\n", .{@as(f64, @floatFromInt(timer.lap())) / 1000000.0});
}
