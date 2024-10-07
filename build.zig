const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{ .cpu_arch = .arm, .os_tag = .linux, .abi = .android });
    const optimize = b.standardOptimizeOption(.{ .preferred_optimize_mode = std.builtin.OptimizeMode.ReleaseSmall });
    const cli = b.addExecutable(.{
        .name = "appscmd-cli",
        .root_source_file = b.path("src/cli.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(cli);

    const daemon = b.addExecutable(.{
        .name = "appscmd-daemon",
        .root_source_file = b.path("src/daemon.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(daemon);
}
