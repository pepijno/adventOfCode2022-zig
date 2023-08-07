const std = @import("std");

fn signum(x: i32) i32 {
    if (x < 0) {
        return -1;
    } else if (x > 0) {
        return 1;
    } else {
        return 0;
    }
}

fn abs(x: i32) i32 {
    if (x < 0) {
        return -1 * x;
    } else {
        return x;
    }
}

const Point = struct {
    x: i32,
    y: i32,
};

const Direction = enum {
    Up,
    Down,
    Left,
    Right,
};

fn Rope(comptime size: usize) type {
    return struct {
        const Self = @This();

        pieces: [size]Point = [_]Point{.{ .x = 0, .y = 0 }} ** size,

        fn moveHead(self: *Self, direction: Direction) void {
            var head = &self.pieces[0];
            switch (direction) {
                .Up => head.y += 1,
                .Down => head.y -= 1,
                .Left => head.x -= 1,
                .Right => head.x += 1,
            }
            self.updateTail();
        }

        fn updateTail(self: *Self) void {
            var i: usize = 1;
            while (i < size) : (i += 1) {
                var current = &self.pieces[i];
                var previous = &self.pieces[i - 1];
                if (abs(current.x - previous.x) <= 1 and abs(current.y - previous.y) <= 1) {
                    break;
                }

                current.x = signum(previous.x - current.x) + current.x;
                current.y = signum(previous.y - current.y) + current.y;
            }
        }

        fn lastPiece(self: Self) Point {
            return self.pieces[size - 1];
        }
    };
}

fn countTailPositions(allocator: std.mem.Allocator, buffer: []const u8, rope: anytype) !u64 {
    var set = std.AutoHashMap(Point, void).init(allocator);
    defer set.deinit();

    var lines = std.mem.tokenize(u8, buffer, "\n");
    while (lines.next()) |line| {
        var chs = std.mem.split(u8, line, " ");
        const dir = chs.next().?[0];
        const int = chs.next().?[0..];
        const amount = try std.fmt.parseInt(u32, int, 10);
        var i: u32 = 0;
        while (i < amount) : (i += 1) {
            switch (dir) {
                'D' => rope.moveHead(.Down),
                'U' => rope.moveHead(.Up),
                'L' => rope.moveHead(.Left),
                'R' => rope.moveHead(.Right),
                else => {},
            }
            try set.put(rope.lastPiece(), {});
        }
    }

    return set.count();
}

fn part1(buffer: []const u8) !u64 {
    const allocator = std.heap.page_allocator;
    var rope: Rope(2) = .{};
    return countTailPositions(allocator, buffer, &rope);
}

fn part2(buffer: []const u8) !u64 {
    const allocator = std.heap.page_allocator;
    var rope: Rope(10) = .{};
    return countTailPositions(allocator, buffer, &rope);
}

test "Day 9 part 1" {
    const buf = @embedFile("inputs/day9.txt");
    var timer = try std.time.Timer.start();
    try std.testing.expectEqual(part1(buf), 6037);
    std.debug.print("{d:9.3}ms\n", .{@intToFloat(f64, timer.lap()) / 1000000.0});
}

test "Day 9 part 2" {
    const buf = @embedFile("inputs/day9.txt");
    var timer = try std.time.Timer.start();
    try std.testing.expectEqual(part2(buf), 2485);
    std.debug.print("{d:9.3}ms\n", .{@intToFloat(f64, timer.lap()) / 1000000.0});
}
