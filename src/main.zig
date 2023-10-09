const std = @import("std");
const curses = @import("curses.zig");
const heap = std.heap;
const fmt = std.fmt;
const mem = std.mem;
const Allocator = mem.Allocator;

pub fn main() !void {
    var gpa = heap.GeneralPurposeAllocator(.{}){};
    defer {
        const st = gpa.deinit();
        if (st == .leak) {
            std.debug.print("leaked (bruh)", .{});
        }
    }

    var ally = gpa.allocator();

    // Initialize the curses library
    const win = try curses.initscr(ally);
    try curses.start_color(); // Enable color support

    // Define color pairs
    const pair1 = try curses.ColorPair.init(1, curses.COLOR_RED, curses.COLOR_BLACK);

    while (true) {
        // Print some text
        try win.attron(pair1.attr());

        try win.mvaddstr(1, 2, fmt.comptimePrint("", .{}));
        try win.mvaddstr(4, 2, "q to quit");
        try win.boxme();

        const cmdEntered = try getCmd(&ally, &win);
        _ = cmdEntered;
    }

    _ = try curses.endwin();
}

fn intToStr(ally: *Allocator, i: i32) ![]const u8 {
    return fmt.allocPrint(ally.*, "{d}", .{i});
}

fn getCmd(ally: *Allocator, win: *const curses.Window) !void {
    var cursorPos: u8 = 0;
    var cmd: [1024]u8 = undefined;
    _ = cmd;

    while (true) {
        const key = try win.getch();

        if (key == 127) {
            try win.mvaddch(40, cursorPos, 'a');
        }

        try win.mvaddch(20, cursorPos, @intCast(key));
        try win.mvaddstr(21, 3, try intToStr(ally, key));
        cursorPos += 1;
    }
}
