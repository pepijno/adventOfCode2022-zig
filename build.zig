const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});

    const mode = b.standardReleaseOptions();
    {
        const exe = b.addExecutable("adventOfCode2022-zig-day4", "src/day4.zig");
        exe.setTarget(target);
        exe.setBuildMode(mode);
        exe.install();

        const run_cmd = exe.run();
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step("day4", "Run day 4");
        run_step.dependOn(&run_cmd.step);
    }
    {
        const exe = b.addExecutable("adventOfCode2022-zig-day3", "src/day3.zig");
        exe.setTarget(target);
        exe.setBuildMode(mode);
        exe.install();

        const run_cmd = exe.run();
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step("day3", "Run day 3");
        run_step.dependOn(&run_cmd.step);
    }
    {
        const exe = b.addExecutable("adventOfCode2022-zig-day2", "src/day2.zig");
        exe.setTarget(target);
        exe.setBuildMode(mode);
        exe.install();

        const run_cmd = exe.run();
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step("day2", "Run day 2");
        run_step.dependOn(&run_cmd.step);
    }
    {
        const exe = b.addExecutable("adventOfCode2022-zig-day1", "src/day1.zig");
        exe.setTarget(target);
        exe.setBuildMode(mode);
        exe.install();

        const run_cmd = exe.run();
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step("day1", "Run day 1");
        run_step.dependOn(&run_cmd.step);
    }

    const exe_tests = b.addTest("src/tests.zig");
    exe_tests.setTarget(target);
    exe_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}
