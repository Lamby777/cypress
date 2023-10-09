const std = @import("std");
const curses = @import("curses.zig");
const heap = std.heap;
const fmt = std.fmt;
const mem = std.mem;
const Allocator = mem.Allocator;

// the useful constants that might need to be changed
const CMD_BUFFER_SIZE = 1024;

// the "ignore this magic number" constants
const BACKSPACE_CH = 127;
const ENTER_CH = 10;

var pair1: curses.ColorPair = undefined;

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
    try curses.cbreak();
    try curses.noecho();
    _ = try curses.curs_set(0);

    // Define color pairs
    pair1 = try curses.ColorPair.init(1, curses.COLOR_RED, curses.COLOR_BLACK);

    while (true) {
        try drawWin(&win);

        const cmdEntered = try getCmd(&ally, &win);
        _ = cmdEntered;
    }

    _ = try curses.endwin();
}

fn drawWin(win: *const curses.Window) !void {
    // Print some text
    try win.attron(pair1.attr());

    try win.mvaddstr(1, 2, fmt.comptimePrint("", .{}));
    try win.mvaddstr(4, 2, "q to quit");
    try win.boxme();
}

fn intToStr(ally: *Allocator, i: i32) ![]const u8 {
    return fmt.allocPrint(ally.*, "{d}", .{i});
}

fn getCmd(ally: *Allocator, win: *const curses.Window) !void {
    _ = ally;
    var cursorPos: u16 = 0;
    var cmd: [CMD_BUFFER_SIZE]u8 = undefined;

    // we don't need to worry about arrow keys and stuff...
    // this "shell" is gonna be dead simple. the commands
    // aren't gonna be long enough that backspacing and
    // typing over the old character will take much time.

    while (true) {
        const key = try win.getch();
        const ch: u32 = @intCast(key);

        try drawWin(win);
        switch (key) {
            // user pressed backspace
            BACKSPACE_CH => {
                try win.mvaddch(40, cursorPos, 'a');
                if (cursorPos > 0) {
                    cursorPos -= 1;
                }
            },

            // user typed a character
            // you can't be serious...
            0...ENTER_CH - 1, ENTER_CH + 1...BACKSPACE_CH - 1, BACKSPACE_CH + 1...255 => {
                // try win.mvaddstr(18, 3, "   ");
                // try win.mvaddstr(18, 3, try intToStr(ally, key));
                cmd[cursorPos] = @intCast(ch);
                cursorPos += 1;
            },

            // don't handle unicode sussery wussery shenanigans
            else => {},
        }

        // write cmd buffer to prompt
        try win.mvaddstr(20, 3, cmd[0..cursorPos]);
    }
}
