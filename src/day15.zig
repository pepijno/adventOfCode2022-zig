const std = @import("std");

const Range = struct {
    start: i64 = 0,
    end: i64 = 0,

    fn merge(a: Range, b: Range) ?Range {
        const start_max = std.math.max(a.start, b.start);
        const end_min = std.math.min(a.end, b.end);
        if (start_max <= end_min + 1) {
            return Range{
                .start = std.math.min(a.start, b.start),
                .end = std.math.max(a.end, b.end),
            };
        }
        return null;
    }
};

const Point = struct {
    const Self = @This();

    x: i64,
    y: i64,

    fn distance(self: Self, to: Self) i64 {
        const x = std.math.absInt(self.x - to.x) catch unreachable;
        const y = std.math.absInt(self.y - to.y) catch unreachable;
        return x + y;
    }
};

const Sensor = struct {
    const Self = @This();

    location: Point,
    closest_beacon: Point,
    distance: i64,
};

fn parseSensors(allocator: std.mem.Allocator, buffer: []const u8) !std.ArrayList(Sensor) {
    var sensors = std.ArrayList(Sensor).init(allocator);

    var lines = std.mem.tokenize(u8, buffer, "\n");
    while (lines.next()) |line| {
        var words = std.mem.tokenize(u8, line, "x=, y=:");
        _ = words.next();
        _ = words.next();
        const location_x = try std.fmt.parseInt(i64, words.next().?, 10);
        const location_y = try std.fmt.parseInt(i64, words.next().?, 10);
        const location = Point{
            .x = location_x,
            .y = location_y,
        };
        _ = words.next();
        _ = words.next();
        _ = words.next();
        _ = words.next();
        const beacon_x = try std.fmt.parseInt(i64, words.next().?, 10);
        const beacon_y = try std.fmt.parseInt(i64, words.next().?, 10);
        const beacon = Point{
            .x = beacon_x,
            .y = beacon_y,
        };
        try sensors.append(.{
            .location = location,
            .closest_beacon = beacon,
            .distance = location.distance(beacon),
        });
    }

    return sensors;
}

fn createRanges(allocator: std.mem.Allocator, sensors: std.ArrayList(Sensor), y: i64) !std.ArrayList(Range) {
    var ranges = std.ArrayList(Range).init(allocator);

    for (sensors.items) |*sensor| {
        const dist = sensor.distance - try std.math.absInt(sensor.location.y - y);
        if (dist < 0) {
            continue;
        }
        const range = Range{
            .start = sensor.location.x - dist,
            .end = sensor.location.x + dist,
        };

        try addToRanges(&ranges, range);
    }

    return ranges;
}

fn addToRanges(ranges: *std.ArrayList(Range), range: Range) !void {
    for (ranges.items) |r, i| {
        const merged = r.merge(range);
        if (merged) |m| {
            _ = ranges.swapRemove(i);
            try addToRanges(ranges, m);
            return;
        }
    }
    try ranges.append(range);
}

fn rangesSizes(ranges: std.ArrayList(Range)) u64 {
    var sum: u64 = 0;
    for (ranges.items) |range| {
        sum += @intCast(u64, range.end - range.start);
    }
    return sum;
}

fn part1(buffer: []const u8) !u64 {
    const allocator = std.heap.page_allocator;

    var sensors = try parseSensors(allocator, buffer);
    defer sensors.deinit();

    const y: i64 = 2000000;
    var ranges = try createRanges(allocator, sensors, y);
    defer ranges.deinit();

    return rangesSizes(ranges);
}

fn part2(buffer: []const u8) !u64 {
    const allocator = std.heap.page_allocator;

    var sensors = try parseSensors(allocator, buffer);
    defer sensors.deinit();

    const max_y: i64 = 4000000;

    var y: i64 = max_y;
    while (y > 0) : (y -= 1) {
        var ranges = try createRanges(allocator, sensors, y);
        defer ranges.deinit();

        if (ranges.items.len > 1) {
            if (ranges.items[0].start > 0) {
                return @intCast(u64, 4000000 * (ranges.items[0].start - 1) + y);
            } else {
                return @intCast(u64, 4000000 * (ranges.items[0].end + 1) + y);
            }
        }
    }

    unreachable;
}

test {
    const buf = @embedFile("inputs/day15.txt");

    try std.testing.expectEqual(part1(buf), 5073496);
    try std.testing.expectEqual(part2(buf), 13081194638237);
}
