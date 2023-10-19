// This file is for processing commands
const std = @import("std");
const ChildProcess = std.ChildProcess;
const Allocator = std.mem.Allocator;

const cs = @import("consts.zig");
const CommandBuffer = cs.CommandBuffer;
const os = std.os.linux;

pub fn processCmd(ally: *Allocator, cmd: CommandBuffer) !void {
    if (std.mem.eql(u8, &cmd, "touch")) {
        try system(ally, &.{ "touch", "/home/cascade/bruh.txt" });
    }
}

pub fn system(ally: *Allocator, argv: []const []const u8) !void {
    var cp = ChildProcess.init(argv, ally.*);
    try cp.spawn();
}
