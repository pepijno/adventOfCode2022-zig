const std = @import("std");

const Point = struct {
    x: i64,
    y: i64,
};

const Columns = std.ArrayList(std.ArrayList(i64));
const Rock = std.ArrayList(Point);
const State = [9]i64;
const ReconData = struct {
    max: i64,
    min: i64,
    n: usize,
};
const StateMap = std.AutoHashMap(State, ReconData);

fn checkCollisions(columns: Columns, rock: Rock) bool {
    for (rock.items) |i| {
        if (i.x < 0 or i.x > 6) {
            return true;
        }
        var column = &columns.items[@intCast(i.x)];
        var j: i64 = @as(i64, @intCast(column.items.len)) - 1;
        while (j >= 0) : (j -= 1) {
            if (i.y == column.items[@intCast(j)]) {
                return true;
            }
            if (i.y > column.items[@intCast(j)]) {
                break;
            }
        }
    }
    return false;
}

fn windMove(rock: Rock, columns: Columns, wind: u8) !Rock {
    var new_rock = try rock.clone();

    switch (wind) {
        '>' => {
            for (new_rock.items) |*i| {
                i.x += 1;
            }
        },
        '<' => {
            for (new_rock.items) |*i| {
                i.x -= 1;
            }
        },
        else => unreachable,
    }

    if (checkCollisions(columns, new_rock)) {
        new_rock.deinit();
        return rock;
    }

    rock.deinit();
    return new_rock;
}

fn getColMin(columns: Columns) i64 {
    var min: i64 = std.math.maxInt(i64);
    for (columns.items) |column| {
        min = @min(min, column.items[column.items.len - 1]);
    }
    return min;
}

fn getColMax(columns: Columns) i64 {
    var max: i64 = 0;
    for (columns.items) |column| {
        max = @max(max, column.items[column.items.len - 1]);
    }
    return max;
}

fn updateColumns(rock: Rock, columns: *Columns) !void {
    for (rock.items) |i| {
        var column = &columns.items[@intCast(i.x)];
        try column.append(i.y);
        std.sort.insertion(i64, column.items, {}, comptime std.sort.asc(i64));
    }
}

fn descend(rock: *Rock, columns: *Columns) !bool {
    var new_rock = try rock.clone();

    for (new_rock.items) |*i| {
        i.y -= 1;
    }

    if (checkCollisions(columns.*, new_rock)) {
        new_rock.deinit();
        try updateColumns(rock.*, columns);
        return false;
    }

    rock.deinit();
    rock.* = new_rock;
    return true;
}

fn getRock(allocator: std.mem.Allocator, i: u8, cols: Columns) !Rock {
    const y = getColMax(cols) + 4;
    var rock = Rock.init(allocator);
    switch (i) {
        0 => {
            try rock.append(.{ .x = 2, .y = y });
            try rock.append(.{ .x = 3, .y = y });
            try rock.append(.{ .x = 4, .y = y });
            try rock.append(.{ .x = 5, .y = y });
        },
        1 => {
            try rock.append(.{ .x = 3, .y = y });
            try rock.append(.{ .x = 2, .y = y + 1 });
            try rock.append(.{ .x = 3, .y = y + 1 });
            try rock.append(.{ .x = 4, .y = y + 1 });
            try rock.append(.{ .x = 3, .y = y + 2 });
        },
        2 => {
            try rock.append(.{ .x = 2, .y = y });
            try rock.append(.{ .x = 3, .y = y });
            try rock.append(.{ .x = 4, .y = y });
            try rock.append(.{ .x = 4, .y = y + 1 });
            try rock.append(.{ .x = 4, .y = y + 2 });
        },
        3 => {
            try rock.append(.{ .x = 2, .y = y });
            try rock.append(.{ .x = 2, .y = y + 1 });
            try rock.append(.{ .x = 2, .y = y + 2 });
            try rock.append(.{ .x = 2, .y = y + 3 });
        },
        4 => {
            try rock.append(.{ .x = 2, .y = y });
            try rock.append(.{ .x = 2, .y = y + 1 });
            try rock.append(.{ .x = 3, .y = y });
            try rock.append(.{ .x = 3, .y = y + 1 });
        },
        else => unreachable,
    }

    return rock;
}

fn getState(columns: *Columns, rock_index: usize, wind_index: usize) State {
    var state: State = undefined;
    for (columns.items, 0..) |column, i| {
        state[i] = column.items[column.items.len - 1];
    }
    const min = std.mem.min(i64, state[0..7]);
    for (state[0..7]) |*x| {
        x.* -= min;
    }
    state[7] = @intCast(rock_index);
    state[8] = @intCast(wind_index);
    return state;
}

fn shiftCols(columns: *Columns, dh: i64, min: i64) void {
    for (columns.items) |*column| {
        for (column.items) |*h| {
            if (h.* >= min) {
                h.* += dh;
            }
        }
    }
}

fn doSolution(buffer: []const u8, n_rocks: u64) !u64 {
    const allocator = std.heap.page_allocator;

    var cols = Columns.init(allocator);
    for (0..7) |_| {
        var col = std.ArrayList(i64).init(allocator);
        try col.append(0);
        try cols.append(col);
    }
    defer {
        for (cols.items) |*col| {
            col.deinit();
        }
        cols.deinit();
    }

    var state_map = StateMap.init(allocator);
    defer state_map.deinit();
    var cycle_found = false;

    var rock_index: u8 = 0;
    var buf_idx: usize = 0;

    var n: usize = 0;
    while (n < n_rocks) : (n += 1) {
        var rock = try getRock(allocator, rock_index, cols);
        defer rock.deinit();

        if (!cycle_found) {
            var state = getState(&cols, rock_index, buf_idx);
            var ext_state = state_map.get(state);
            if (ext_state != null) {
                cycle_found = true;
                const recon_data = ext_state.?;
                const dn = n - recon_data.n;
                const ncycles = (n_rocks - n) / dn;
                const dh = (getColMax(cols) - recon_data.max) * @as(i64, @intCast(ncycles));
                shiftCols(&cols, dh, recon_data.min);
                n += ncycles * dn;
                rock.deinit();
                rock = try getRock(allocator, rock_index, cols);
            } else {
                try state_map.put(state, ReconData{ .max = getColMax(cols), .min = getColMin(cols), .n = n });
            }
        }

        while (true) {
            // while (true) {
            const wind = buffer[buf_idx];
            buf_idx = (buf_idx + 1) % (buffer.len - 1);

            rock = try windMove(rock, cols, wind);
            if (!try descend(&rock, &cols)) {
                break;
            }
        }

        rock_index = (rock_index + 1) % 5;
    }

    return @intCast(getColMax(cols));
}

fn part1(buffer: []const u8) !u64 {
    return try doSolution(buffer, 2022);
}

fn part2(buffer: []const u8) !u64 {
    return try doSolution(buffer, 1000000000000);
}

test "Day input part 1" {
    const buf = @embedFile("inputs/day17.txt");
    var timer = try std.time.Timer.start();
    try std.testing.expectEqual(part1(buf), 3111);
    std.debug.print("{d:9.3}ms\n", .{@as(f64, @floatFromInt(timer.lap())) / 1000000.0});
}

test "Day input part 2" {
    const buf = @embedFile("inputs/day17.txt");
    var timer = try std.time.Timer.start();
    try std.testing.expectEqual(part2(buf), 1526744186042);
    std.debug.print("{d:9.3}ms\n", .{@as(f64, @floatFromInt(timer.lap())) / 1000000.0});
}
