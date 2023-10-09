// Katz, a command-line chat client for
// the Sparklet Katz protocol
// --- by &Cherry and III_zP0_III (npxTSC)
//
// Used this repo for Zig ncurses boilerplate:
// https://github.com/Akuli/curses-minesweeper
// <3 Open Source

const std = @import("std");
const curses = @import("curses.zig");
const heap = std.heap;
const fmt = std.fmt;

// yes, this is how we're doing it til I find a single
// piece of documentation about build.zig.zon files.
//
// shut up, it's not a code smell, YOU'RE a code smell ;-;
const VERSION = [3]u8{ 0, 1, 0 };
const VERSION_STR = fmt.comptimePrint("{}.{}.{}", .{
    VERSION[0],
    VERSION[1],
    VERSION[2],
});

// info for default ws server (users can host their own)
const SRV_ADDR = "127.0.0.1";
const SRV_PORT = 9098; // so serious :3

pub fn main() !void {
    var gpa = heap.GeneralPurposeAllocator(.{}){};
    defer {
        const st = gpa.deinit();
        if (st == .leak) {
            std.debug.print("leaked (bruh)", .{});
        }
    }

    const ally = gpa.allocator();

    // Initialize the curses library
    const win = try curses.initscr(ally);
    try curses.start_color(); // Enable color support

    // Define color pairs
    const pair1 = try curses.ColorPair.init(1, curses.COLOR_RED, curses.COLOR_BLACK);

    while (true) {
        // Print some text
        try win.attron(pair1.attr());

        try win.mvaddstr(1, 2, fmt.comptimePrint("katz v{s}", .{VERSION_STR}));
        try win.mvaddstr(4, 2, "q to quit");
        try win.boxme();

        switch (try win.getch()) {
            'i' => {
                try enterMode(.input, &win);
            },

            'q' => {
                break;
            },

            else => {},
        }
    }

    _ = try curses.endwin(); // End curses mode
}

const MODES = enum {
    input,
};

fn enterMode(mode: MODES, win: *const curses.Window) !void {
    var cursorPos: u8 = 0;

    while (true) {
        switch (mode) {
            .input => {
                switch (try win.getch()) {
                    127 => {
                        // TODO doesn't detect esc, fix later
                        break;
                    },

                    else => |key| {
                        try win.mvaddch(20, cursorPos, @intCast(key));
                        cursorPos += 1;
                    },
                }
            },
        }
    }
}
