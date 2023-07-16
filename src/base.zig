const std = @import("std");

pub fn mainFunc(comptime file_path: []const u8, comptime part1: *const fn ([]const u8) anyerror!u64, comptime part2: *const fn ([]const u8) anyerror!u64) !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024 * 1024]u8 = undefined;
    _ = try in_stream.readAll(&buf);

    try stdout.print("{}\n", .{try part1(&buf)});
    try stdout.print("{}\n", .{try part2(&buf)});

    try bw.flush(); // don't forget to flush!
}
