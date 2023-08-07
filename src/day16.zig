const std = @import("std");

const Valve = struct {
    const Self = @This();

    id: u64,
    flow_rate: u64,
    routes_to: std.ArrayList([]const u8),
};

var ids = std.StringHashMap(u64).init(std.heap.page_allocator);
var names = std.AutoHashMap(u64, []const u8).init(std.heap.page_allocator);

fn parseValves(allocator: std.mem.Allocator, buffer: []const u8) !std.StringHashMap(Valve) {
    var map = std.StringHashMap(Valve).init(allocator);

    var lines = std.mem.tokenize(u8, buffer, "\n");
    var id: u64 = 0;
    while (lines.next()) |line| {
        var words = std.mem.tokenize(u8, line, "=;, ");
        _ = words.next();
        const name = words.next().?;
        _ = words.next();
        _ = words.next();
        _ = words.next();
        const flow_rate = try std.fmt.parseInt(u64, words.next().?, 10);
        _ = words.next();
        _ = words.next();
        _ = words.next();
        _ = words.next();
        var elements = std.ArrayList([]const u8).init(allocator);
        while (words.next()) |to| {
            try elements.append(to);
        }
        try map.put(name, .{
            .id = id,
            .flow_rate = flow_rate,
            .routes_to = elements,
        });
        try ids.put(name, id);
        try names.put(id, name);
        id += 1;
    }

    return map;
}

const StepPointKey = struct {
    id: u64,
    opens: std.StaticBitSet(64),
};

const StepPoint = struct {
    name: []const u8,
    opens: std.StaticBitSet(64),
    flow: u64,
};

fn doStep(allocator: std.mem.Allocator, valves: std.StringHashMap(Valve), current: StepPointKey, current_flow: u64, time: u64) !std.AutoHashMap(StepPointKey, u64) {
    var points = std.AutoHashMap(StepPointKey, u64).init(allocator);
    if (time == 0) {
        return points;
    }

    const valve = valves.getPtr(names.get(current.id).?).?;
    const rate = valve.flow_rate;
    const id = current.id;
    if (rate != 0 and !current.opens.isSet(id)) {
        var new_opens = current.opens;
        new_opens.set(id);
        try points.put(.{
            .id = id,
            .opens = new_opens,
        }, current_flow + rate * (time - 1));
    }

    for (valve.routes_to.items) |neighbor| {
        const key = StepPointKey{
            .id = ids.get(neighbor).?,
            .opens = current.opens,
        };
        const val = points.get(key);
        if ((val != null and val.? < current_flow) or val == null) {
            try points.put(key, current_flow);
        }
    }

    return points;
}

fn calcGraph(allocator: std.mem.Allocator, valves: std.StringHashMap(Valve), time: u64, currents: std.AutoHashMap(StepPointKey, u64)) !std.AutoHashMap(StepPointKey, u64) {
    if (time == 0) {
        return currents;
    }

    var map = std.AutoHashMap(StepPointKey, u64).init(allocator);
    var iterator = currents.iterator();
    while (iterator.next()) |current| {
        var l = try doStep(allocator, valves, current.key_ptr.*, current.value_ptr.*, time);
        defer l.deinit();
        var it = l.iterator();
        while (it.next()) |i| {
            const val = map.get(i.key_ptr.*);
            if ((val != null and val.? < i.value_ptr.*) or val == null) {
                try map.put(i.key_ptr.*, i.value_ptr.*);
            }
        }
    }

    return calcGraph(allocator, valves, time - 1, map);
}

fn part1(buffer: []const u8) !u64 {
    const allocator = std.heap.page_allocator;

    var valves = try parseValves(allocator, buffer);
    defer valves.deinit();

    var points = std.AutoHashMap(StepPointKey, u64).init(allocator);
    try points.put(.{
        .id = ids.get("AA").?,
        .opens = std.StaticBitSet(64).initEmpty(),
    }, 0);

    var res = try calcGraph(allocator, valves, 30, points);

    var max: u64 = 0;
    var iterator = res.iterator();
    while (iterator.next()) |i| {
        max = std.math.max(i.value_ptr.*, max);
    }

    return max;
}

fn part2(buffer: []const u8) !u64 {
    const allocator = std.heap.page_allocator;

    var valves = try parseValves(allocator, buffer);
    defer valves.deinit();

    var points = std.AutoHashMap(StepPointKey, u64).init(allocator);
    try points.put(.{
        .id = ids.get("AA").?,
        .opens = std.StaticBitSet(64).initEmpty(),
    }, 0);

    var res = try calcGraph(allocator, valves, 26, points);

    const Pair = struct {
        opens: std.StaticBitSet(64),
        flow: u64,
    };
    var pairs = std.ArrayList(Pair).init(allocator);
    var iterator = res.iterator();
    while (iterator.next()) |item| {
        try pairs.append(.{
            .opens = item.key_ptr.opens,
            .flow = item.value_ptr.*,
        });
    }

    var max: u64 = 0;
    for (pairs.items) |item, i| {
        const opens = item.opens;
        const flow = item.flow;
        var j = i + 1;
        while (j < pairs.items.len) : (j += 1) {
            if ((pairs.items[j].opens.mask & opens.mask) != 0) {
                continue;
            }
            const re = pairs.items[j].flow + flow;
            max = std.math.max(max, re);
        }
    }

    return max;
}

test "Day 16 part 1" {
    const buf = @embedFile("inputs/day16.txt");
    var timer = try std.time.Timer.start();
    try std.testing.expectEqual(part1(buf), 1789);
    std.debug.print("{d:9.3}ms\n", .{@intToFloat(f64, timer.lap()) / 1000000.0});
}

test "Day 16 part 2" {
    const buf = @embedFile("inputs/day16.txt");
    var timer = try std.time.Timer.start();
    try std.testing.expectEqual(part2(buf), 2496);
    std.debug.print("{d:9.3}ms\n", .{@intToFloat(f64, timer.lap()) / 1000000.0});
}
