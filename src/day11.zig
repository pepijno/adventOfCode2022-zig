const std = @import("std");

const Monkey = struct {
    const Operation = enum {
        Multiplication,
        Addition,
        Squaring,
    };

    items: std.ArrayList(u64),
    operation: Operation = .Squaring,
    operation_value: ?u64 = null,
    test_value: u64 = 1,
    to_monkey_false: usize = 0,
    to_monkey_true: usize = 0,
    inspections: u64 = 0,
};

fn parseMonkeys(allocator: std.mem.Allocator, buffer: []const u8) !std.ArrayList(Monkey) {
    var monkeys = std.ArrayList(Monkey).init(allocator);
    var lines = std.mem.split(u8, buffer, "\n\n");

    while (lines.next()) |monkey_block| {
        var monkey: Monkey = .{
            .items = std.ArrayList(u64).init(allocator),
        };

        var monkey_lines = std.mem.split(u8, monkey_block, "\n");
        _ = monkey_lines.next();
        var starting_items = std.mem.tokenize(u8, monkey_lines.next().?[17..], ", ");
        while (starting_items.next()) |item| {
            const as_int = try std.fmt.parseInt(u64, item, 10);
            try monkey.items.append(as_int);
        }
        var op_tokens = std.mem.tokenize(u8, monkey_lines.next().?[19..], " ");
        _ = op_tokens.next();
        var opty = op_tokens.next().?;
        var operand = op_tokens.next().?;
        if (std.mem.eql(u8, operand, "old")) {
            monkey.operation = .Squaring;
        } else {
            switch (opty[0]) {
                '*' => monkey.operation = .Multiplication,
                '+' => monkey.operation = .Addition,
                else => unreachable,
            }
            monkey.operation_value = try std.fmt.parseInt(u64, operand, 10);
        }
        monkey.test_value = try std.fmt.parseInt(u64, monkey_lines.next().?[21..], 10);
        monkey.to_monkey_true = try std.fmt.parseInt(u64, monkey_lines.next().?[29..], 10);
        monkey.to_monkey_false = try std.fmt.parseInt(u64, monkey_lines.next().?[30..], 10);

        try monkeys.append(monkey);
    }

    return monkeys;
}

fn doMonkeyRounds(monkeys: *std.ArrayList(Monkey), n: usize, do_div: bool) !void {
    var modulus: u64 = 1;
    for (monkeys.items) |*monkey| {
        modulus *= monkey.test_value;
    }

    var i: usize = 0;
    while (i < n) : (i += 1) {
        for (monkeys.items) |*monkey| {
            while (monkey.items.popOrNull()) |item| {
                monkey.inspections += 1;
                const new_item = switch (monkey.operation) {
                    .Squaring => item * item,
                    .Multiplication => item * monkey.operation_value.?,
                    .Addition => item + monkey.operation_value.?,
                };
                const new_item_div = if (do_div) new_item / 3 else new_item % modulus;
                if ((new_item_div % monkey.test_value) == 0) {
                    try monkeys.items[monkey.to_monkey_true].items.append(new_item_div);
                } else {
                    try monkeys.items[monkey.to_monkey_false].items.append(new_item_div);
                }
            }
        }
    }
}

fn part1(buffer: []const u8) !u64 {
    var allocator = std.heap.page_allocator;

    var monkeys = try parseMonkeys(allocator, buffer);
    defer monkeys.deinit();
    try doMonkeyRounds(&monkeys, 20, true);

    var inspections = std.ArrayList(u64).init(allocator);
    defer inspections.deinit();
    for (monkeys.items) |monkey| {
        try inspections.append(monkey.inspections);
    }
    std.sort.sort(u64, inspections.items, {}, comptime std.sort.desc(u64));

    return inspections.items[0] * inspections.items[1];
}

fn part2(buffer: []const u8) !u64 {
    var allocator = std.heap.page_allocator;

    var monkeys = try parseMonkeys(allocator, buffer);
    defer monkeys.deinit();
    try doMonkeyRounds(&monkeys, 10000, false);

    var inspections = std.ArrayList(u64).init(allocator);
    defer inspections.deinit();
    for (monkeys.items) |monkey| {
        try inspections.append(monkey.inspections);
    }
    std.sort.sort(u64, inspections.items, {}, comptime std.sort.desc(u64));

    return inspections.items[0] * inspections.items[1];
}

test "Day 11 part 1" {
    const buf = @embedFile("inputs/day11.txt");
    var timer = try std.time.Timer.start();
    try std.testing.expectEqual(part1(buf), 108240);
    std.debug.print("{d:9.3}ms\n", .{@intToFloat(f64, timer.lap()) / 1000000.0});
}

test "Day 11 part 2" {
    const buf = @embedFile("inputs/day11.txt");
    var timer = try std.time.Timer.start();
    try std.testing.expectEqual(part2(buf), 25712998901);
    std.debug.print("{d:9.3}ms\n", .{@intToFloat(f64, timer.lap()) / 1000000.0});
}
