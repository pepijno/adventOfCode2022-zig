const std = @import("std");

const OrderResult = enum {
    CorrectOrder,
    IncorrectOrder,
    Indeterminate,
};

const DataItem = struct {
    const Self = @This();

    parent: ?*DataItem = null,
    value: ?u32 = null,
    list: std.ArrayList(Self),
    is_divider: bool = false,

    fn deinit(self: *Self) void {
        for (self.list.items) |*item| {
            item.deinit();
        }
        self.list.deinit();
    }

    fn compare(allocator: std.mem.Allocator, left: *const Self, right: *const Self) !OrderResult {
        if (left.value != null and right.value != null) {
            const lv = left.value.?;
            const rv = right.value.?;
            if (lv < rv) {
                return .CorrectOrder;
            } else if (lv > rv) {
                return .IncorrectOrder;
            } else {
                return .Indeterminate;
            }
        } else if (left.value == null and right.value == null) {
            var i: usize = 0;
            const max = @max(left.list.items.len, right.list.items.len);
            while (i < max) : (i += 1) {
                if (i == left.list.items.len) {
                    return .CorrectOrder;
                }
                if (i == right.list.items.len) {
                    return .IncorrectOrder;
                }
                const res = try Self.compare(allocator, &left.list.items[i], &right.list.items[i]);
                if (res != .Indeterminate) {
                    return res;
                }
            }
            return .Indeterminate;
        } else if (left.value) |lv| {
            var item = DataItem{
                .list = std.ArrayList(DataItem).init(allocator),
            };
            defer item.deinit();
            try item.list.append(DataItem{
                .parent = &item,
                .value = lv,
                .list = std.ArrayList(DataItem).init(allocator),
            });
            return try Self.compare(allocator, &item, right);
        } else if (right.value) |rv| {
            var item = DataItem{
                .list = std.ArrayList(DataItem).init(allocator),
            };
            defer item.deinit();
            try item.list.append(DataItem{
                .parent = &item,
                .value = rv,
                .list = std.ArrayList(DataItem).init(allocator),
            });
            return try Self.compare(allocator, left, &item);
        } else {
            return .Indeterminate;
        }
    }
};

fn parseDataItem(allocator: std.mem.Allocator, line: []const u8) !DataItem {
    var root = DataItem{
        .list = std.ArrayList(DataItem).init(allocator),
    };
    var current = &root;
    var intString: [32]u8 = undefined;
    var i: usize = 0;

    for (line) |char| {
        switch (char) {
            '[' => {
                try current.list.append(DataItem{
                    .parent = current,
                    .list = std.ArrayList(DataItem).init(allocator),
                });
                current = &current.list.items[current.list.items.len - 1];
            },
            ']' => {
                if (i > 0) {
                    const value = try std.fmt.parseInt(u32, intString[0..i], 10);
                    i = 0;
                    current.value = value;
                }
                current = current.parent.?;
            },
            ',' => {
                if (i > 0) {
                    const value = try std.fmt.parseInt(u32, intString[0..i], 10);
                    i = 0;
                    current.value = value;
                }
                current = current.parent.?;
                try current.list.append(DataItem{
                    .parent = current,
                    .list = std.ArrayList(DataItem).init(allocator),
                });
                current = &current.list.items[current.list.items.len - 1];
            },
            else => {
                intString[i] = char;
                i += 1;
            },
        }
    }

    return root;
}

fn part1(buffer: []const u8) !u64 {
    const allocator = std.heap.page_allocator;

    var total: u64 = 0;
    var lines = std.mem.tokenize(u8, buffer, "\n");
    var i: usize = 1;
    while (lines.next()) |line| {
        var item = try parseDataItem(allocator, line);
        defer item.deinit();
        var next_item = try parseDataItem(allocator, lines.next().?);
        defer next_item.deinit();
        const is_correct = try DataItem.compare(allocator, &item, &next_item);
        total += if (is_correct != .IncorrectOrder) i else 0;
        i += 1;
    }

    return total;
}

fn sortPackets(allocator: std.mem.Allocator, packets: *std.ArrayList(DataItem)) !void {
    var i: usize = 1;
    while (i < packets.items.len) : (i += 1) {
        var j: usize = i;
        while (j > 0) : (j -= 1) {
            var left = packets.items[j - 1];
            var right = packets.items[j];
            const result = try DataItem.compare(allocator, &left, &right);
            if (result == .IncorrectOrder) {
                packets.items[j - 1] = right;
                packets.items[j] = left;
            } else {
                break;
            }
        }
    }
}

fn part2(buffer: []const u8) !u64 {
    const allocator = std.heap.page_allocator;

    var list = std.ArrayList(DataItem).init(allocator);
    defer {
        for (list.items) |*item| {
            item.deinit();
        }
        list.deinit();
    }

    var lines = std.mem.tokenize(u8, buffer, "\n");
    while (lines.next()) |line| {
        const item = try parseDataItem(allocator, line);
        try list.append(item);
    }

    var item2 = try parseDataItem(allocator, "[[2]]");
    item2.is_divider = true;
    try list.append(item2);
    var item6 = try parseDataItem(allocator, "[[6]]");
    item6.is_divider = true;
    try list.append(item6);

    try sortPackets(allocator, &list);

    var total: u64 = 1;
    var i: u64 = 1;
    for (list.items) |*item| {
        if (item.is_divider) {
            total *= i;
        }
        i += 1;
    }

    return total;
}

test "Day 13 part 1" {
    const buf = @embedFile("inputs/day13.txt");
    var timer = try std.time.Timer.start();
    try std.testing.expectEqual(part1(buf), 5905);
    std.debug.print("{d:9.3}ms\n", .{@intToFloat(f64, timer.lap()) / 1000000.0});
}

test "Day 13 part 2" {
    const buf = @embedFile("inputs/day13.txt");
    var timer = try std.time.Timer.start();
    try std.testing.expectEqual(part2(buf), 21691);
    std.debug.print("{d:9.3}ms\n", .{@intToFloat(f64, timer.lap()) / 1000000.0});
}
