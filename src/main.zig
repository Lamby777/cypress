const std = @import("std");
const curses = @import("curses.zig");
const heap = std.heap;
const fmt = std.fmt;

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

        try win.mvaddstr(1, 2, fmt.comptimePrint("", .{}));
        try win.mvaddstr(4, 2, "q to quit");
        try win.boxme();

        switch (try win.getch()) {
            'q' => {
                break;
            },

            else => {},
        }
    }

    _ = try curses.endwin();
}
