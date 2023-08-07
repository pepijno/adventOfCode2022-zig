const std = @import("std");

const Node = struct {
    const Self = @This();

    parent: ?*Node,
    children: std.StringHashMap(Node),
    size: ?u64,

    fn countSize(self: *Self) u64 {
        if (self.size) |s| {
            return s;
        }
        var iterator = self.children.iterator();
        var total: u64 = 0;
        while (iterator.next()) |child| {
            total += child.value_ptr.countSize();
        }
        self.size = total;
        return total;
    }
};

fn accumulateRecursiveSizesInner(node: *const Node, max_size: usize, size: *usize) void {
    if (node.size.? <= max_size and node.children.count() != 0) {
        size.* += node.size.?;
    }
    var it = node.children.iterator();
    while (it.next()) |child| {
        accumulateRecursiveSizesInner(child.value_ptr, max_size, size);
    }
}

fn accumulateRecursiveSizes(root: *const Node, max_size: usize) usize {
    var size: usize = 0;
    accumulateRecursiveSizesInner(root, max_size, &size);
    return size;
}

fn createDirTree(allocator: std.mem.Allocator, buffer: []const u8) !Node {
    var root = Node{
        .parent = null,
        .size = null,
        .children = std.StringHashMap(Node).init(allocator),
    };
    var current = &root;

    var lines = std.mem.tokenize(u8, buffer, "\n");
    while (lines.next()) |line| {
        if (line[0] == '$') {
            if (line[2] == 'c') {
                var words = std.mem.tokenize(u8, line, " ");
                _ = words.next();
                _ = words.next();
                const dir = words.next().?;
                if (dir[0] == '.' and dir[1] == '.') {
                    current = current.parent.?;
                } else if (dir[0] == '/') {
                    current = &root;
                } else {
                    const node = current.children.getPtr(dir);
                    if (node) |n| {
                        current = n;
                    }
                }
            }
        } else {
            var words = std.mem.tokenize(u8, line, " ");
            const t = words.next().?;
            const name = words.next().?;
            const size = if (t[0] != 'd') try std.fmt.parseInt(u64, t, 10) else null;
            try current.children.put(name, .{
                .parent = current,
                .size = size,
                .children = std.StringHashMap(Node).init(allocator),
            });
        }
    }

    _ = root.countSize();

    return root;
}

fn part1(buffer: []const u8) !u64 {
    const allocator = std.heap.page_allocator;

    var root = try createDirTree(allocator, buffer);

    return accumulateRecursiveSizes(&root, 100000);
}

fn findSmallestDirInExcessInner(node: *const Node, min_size: usize, size: *usize) void {
    if (node.size.? >= min_size and node.size.? <= size.* and node.children.count() != 0) {
        size.* = node.size.?;
    }
    var it = node.children.iterator();
    while (it.next()) |child| {
        findSmallestDirInExcessInner(child.value_ptr, min_size, size);
    }
}

fn findSmallestDirInExcess(root: *const Node, min_size: usize) usize {
    var size: usize = std.math.maxInt(usize);
    findSmallestDirInExcessInner(root, min_size, &size);
    return size;
}

fn part2(buffer: []const u8) !u64 {
    const allocator = std.heap.page_allocator;

    var root = try createDirTree(allocator, buffer);

    const disk_space_available: u64 = 70000000;
    const disk_space_needed: u64 = 30000000;
    const disk_space_free = disk_space_available - root.size.?;
    const diff = disk_space_needed - disk_space_free;

    return findSmallestDirInExcess(&root, diff);
}

test "Day 7 part 1" {
    const buf = @embedFile("inputs/day7.txt");
    var timer = try std.time.Timer.start();
    try std.testing.expectEqual(part1(buf), 1642503);
    std.debug.print("{d:9.3}ms\n", .{@intToFloat(f64, timer.lap()) / 1000000.0});
}

test "Day 7 part 2" {
    const buf = @embedFile("inputs/day7.txt");
    var timer = try std.time.Timer.start();
    try std.testing.expectEqual(part2(buf), 6999588);
    std.debug.print("{d:9.3}ms\n", .{@intToFloat(f64, timer.lap()) / 1000000.0});
}
