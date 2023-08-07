const std = @import("std");

fn part1(buffer: []const u8) !i64 {
    const allocator = std.heap.page_allocator;

    const Pair = struct {
        cycle: u64,
        register: i64,

        fn multiply(self: @This()) i64 {
            return @intCast(i64, self.cycle) * self.register;
        }
    };

    var cycle: u64 = 1;
    var register: i64 = 1;
    var values = std.ArrayList(Pair).init(allocator);

    var lines = std.mem.tokenize(u8, buffer, "\n");
    while (lines.next()) |line| {
        var words = std.mem.tokenize(u8, line, " ");
        var instruction = words.next().?;
        if (std.mem.eql(u8, instruction, "noop")) {
            try values.append(.{ .cycle = cycle, .register = register });
            cycle += 1;
        } else {
            var value = try std.fmt.parseInt(i64, words.next().?, 10);
            try values.append(.{ .cycle = cycle, .register = register });
            cycle += 1;
            try values.append(.{ .cycle = cycle, .register = register });
            cycle += 1;
            register += value;
        }
    }

    return values.items[19].multiply() + values.items[59].multiply() + values.items[99].multiply() + values.items[139].multiply() + values.items[179].multiply() + values.items[219].multiply();
}

fn pixel(cycle: u64, register: i64) u8 {
    const c = cycle % 40;
    if (c == register - 1 or c == register or c == register + 1) {
        return '#';
    } else {
        return '.';
    }
}

fn part2(buffer: []const u8) ![]const u8 {
    var cycle: u64 = 0;
    var register: i64 = 1;

    var crt = [_]u8{'.'} ** 240;

    var lines = std.mem.tokenize(u8, buffer, "\n");
    while (lines.next()) |line| {
        var words = std.mem.tokenize(u8, line, " ");
        var instruction = words.next().?;
        if (std.mem.eql(u8, instruction, "noop")) {
            crt[cycle] = pixel(cycle, register);
            cycle += 1;
        } else {
            var value = try std.fmt.parseInt(i64, words.next().?, 10);
            crt[cycle] = pixel(cycle, register);
            cycle += 1;
            crt[cycle] = pixel(cycle, register);
            cycle += 1;
            register += value;
        }
    }

    std.debug.print("\n", .{});
    var i: usize = 0;
    while (i < 240) : (i += 1) {
        if ((i % 40) == 0) {
            std.debug.print("\n", .{});
        }
        std.debug.print("{c}", .{crt[i]});
    }
    std.debug.print("\n", .{});

    return "BJFRHRFU";
}

test "Day 10 part 1" {
    const buf = @embedFile("inputs/day10.txt");
    var timer = try std.time.Timer.start();
    try std.testing.expectEqual(part1(buf), 14620);
    std.debug.print("{d:9.3}ms\n", .{@intToFloat(f64, timer.lap()) / 1000000.0});
}

test "Day 10 part 2" {
    const buf = @embedFile("inputs/day10.txt");
    var timer = try std.time.Timer.start();
    try std.testing.expectEqualStrings(try part2(buf), "BJFRHRFU");
    std.debug.print("{d:9.3}ms\n", .{@intToFloat(f64, timer.lap()) / 1000000.0});
}
