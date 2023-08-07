const std = @import("std");

const Move = struct {
    amount: u8,
    from: u8,
    to: u8,
};

fn moveCrates(comptime separate: bool, buffer: []const u8) ![9]u8 {
    const allocator = std.heap.page_allocator;

    var crate_stacks = [_]std.ArrayList(u8){std.ArrayList(u8).init(allocator)} ** 9;

    var moves = std.ArrayList(Move).init(allocator);

    var lines = std.mem.tokenize(u8, buffer, "\n");
    while (lines.next()) |line| {
        if (line[1] == '1') {
            continue;
        }
        if (line[0] == 'm') {
            var words = std.mem.split(u8, line, " ");
            _ = words.next();
            const amount = try std.fmt.parseInt(u8, words.next().?, 10);
            _ = words.next();
            const from = try std.fmt.parseInt(u8, words.next().?, 10) - 1;
            _ = words.next();
            const to = try std.fmt.parseInt(u8, words.next().?, 10) - 1;
            try moves.append(.{
                .amount = amount,
                .from = from,
                .to = to,
            });
        }
        var i: usize = 1;
        while (i < line.len) : (i += 4) {
            if (line[i] >= 'A' and line[i] <= 'Z') {
                try crate_stacks[(i - 1) / 4].insert(0, line[i]);
            }
        }
    }

    for (moves.items) |move| {
        if (separate) {
            var i: usize = 0;
            while (i < move.amount) : (i += 1) {
                const crate = crate_stacks[move.from].pop();
                try crate_stacks[move.to].append(crate);
            }
        } else {
            const index = crate_stacks[move.to].items.len;
            var i: usize = 0;
            while (i < move.amount) : (i += 1) {
                const crate = crate_stacks[move.from].pop();
                try crate_stacks[move.to].insert(index, crate);
            }
        }
    }

    var result = [_]u8{0} ** 9;
    for (crate_stacks) |stack, i| {
        result[i] = stack.items[stack.items.len - 1];
    }

    return result;
}

fn part1(buffer: []const u8) [9]u8 {
    return moveCrates(true, buffer) catch unreachable;
}

fn part2(buffer: []const u8) [9]u8 {
    return moveCrates(false, buffer) catch unreachable;
}

test "Day 5 part 1" {
    const buf = @embedFile("inputs/day5.txt");
    var timer = try std.time.Timer.start();
    try std.testing.expectEqualStrings(&part1(buf), "WSFTMRHPP");
    std.debug.print("{d:9.3}ms\n", .{@intToFloat(f64, timer.lap()) / 1000000.0});
}

test "Day 5 part 2" {
    const buf = @embedFile("inputs/day5.txt");
    var timer = try std.time.Timer.start();
    try std.testing.expectEqualStrings(&part2(buf), "GSLCMFBRP");
    std.debug.print("{d:9.3}ms\n", .{@intToFloat(f64, timer.lap()) / 1000000.0});
}
