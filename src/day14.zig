const std = @import("std");

const Point = struct {
    const Self = @This();

    x: i64,
    y: i64,

    fn parseCoord(line: []const u8) !Self {
        var ints = std.mem.split(u8, line, ",");

        return .{
            .x = try std.fmt.parseInt(i64, ints.next().?, 10),
            .y = try std.fmt.parseInt(i64, ints.next().?, 10),
        };
    }
};

fn parseWall(allocator: std.mem.Allocator, buffer: []const u8) !std.AutoHashMap(Point, void) {
    var walls = std.AutoHashMap(Point, void).init(allocator);

    var lines = std.mem.tokenize(u8, buffer, "\n");
    while (lines.next()) |line| {
        var coords = std.mem.tokenize(u8, line, " -> ");

        var coord = try Point.parseCoord(coords.next().?);

        while (coords.next()) |c| {
            var co = try Point.parseCoord(c);

            var i: i64 = 0;
            if (co.x > coord.x) {
                i = coord.x;
                while (i <= co.x) : (i += 1) {
                    try walls.put(.{ .x = i, .y = coord.y }, {});
                }
            } else if (co.x < coord.x) {
                i = co.x;
                while (i <= coord.x) : (i += 1) {
                    try walls.put(.{ .x = i, .y = coord.y }, {});
                }
            } else if (co.y > coord.y) {
                i = coord.y;
                while (i <= co.y) : (i += 1) {
                    try walls.put(.{ .x = coord.x, .y = i }, {});
                }
            } else {
                i = co.y;
                while (i <= coord.y) : (i += 1) {
                    try walls.put(.{ .x = coord.x, .y = i }, {});
                }
            }

            coord = co;
        }
    }

    return walls;
}

fn findMaxY(walls: std.AutoHashMap(Point, void)) i64 {
    var iterator = walls.iterator();
    var max_y: i64 = 0;
    while (iterator.next()) |point| {
        if (point.key_ptr.y > max_y) {
            max_y = point.key_ptr.y;
        }
    }
    return max_y;
}

fn dropGrainOfSand(walls: *std.AutoHashMap(Point, void), max_y: i64) !bool {
    var sand = Point{
        .x = 500,
        .y = 0,
    };
    if (walls.contains(sand)) {
        return false;
    }

    while (sand.y <= max_y) {
        const down = Point{
            .x = sand.x,
            .y = sand.y + 1,
        };
        const down_left = Point{
            .x = sand.x - 1,
            .y = sand.y + 1,
        };
        const down_right = Point{
            .x = sand.x + 1,
            .y = sand.y + 1,
        };

        if (!walls.contains(down)) {
            sand = down;
        } else if (!walls.contains(down_left)) {
            sand = down_left;
        } else if (!walls.contains(down_right)) {
            sand = down_right;
        } else {
            try walls.put(sand, {});
            return true;
        }
    }

    return false;
}

fn part1(buffer: []const u8) !u64 {
    var allocator = std.heap.page_allocator;

    var walls = try parseWall(allocator, buffer);
    defer walls.deinit();

    const max_y = findMaxY(walls);

    var i: u64 = 0;
    while (true) {
        const sand_dropped = try dropGrainOfSand(&walls, max_y);
        if (sand_dropped) {
            i += 1;
        } else {
            break;
        }
    }

    return i;
}

fn part2(buffer: []const u8) !u64 {
    var allocator = std.heap.page_allocator;

    var walls = try parseWall(allocator, buffer);
    defer walls.deinit();

    const max_y = findMaxY(walls) + 2;

    var index: i64 = 490 - max_y;
    while (index < 510 + max_y) : (index += 1) {
        try walls.put(.{ .x = index, .y = max_y }, {});
    }

    var i: u64 = 0;
    while (true) {
        const sand_dropped = try dropGrainOfSand(&walls, max_y);
        if (sand_dropped) {
            i += 1;
        } else {
            break;
        }
    }

    return i;
}

test "Day 14 part 1" {
    const buf = @embedFile("inputs/day14.txt");
    var timer = try std.time.Timer.start();
    try std.testing.expectEqual(part1(buf), 674);
    std.debug.print("{d:9.3}ms\n", .{@intToFloat(f64, timer.lap()) / 1000000.0});
}

test "Day 14 part 2" {
    const buf = @embedFile("inputs/day14.txt");
    var timer = try std.time.Timer.start();
    try std.testing.expectEqual(part2(buf), 24958);
    std.debug.print("{d:9.3}ms\n", .{@intToFloat(f64, timer.lap()) / 1000000.0});
}
