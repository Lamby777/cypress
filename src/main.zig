const std = @import("std");
const curses = @import("curses.zig");
const heap = std.heap;
const fmt = std.fmt;
const mem = std.mem;
const Allocator = mem.Allocator;

// the useful constants that might need to be changed
const CMD_BUFFER_SIZE = 64;
const CMD_PROMPT = '>';
const TOP_LINENO = 3;
const CMD_LINENO = 6;

// the "ignore this magic number" constants
const CommandBuffer = [CMD_BUFFER_SIZE]u8;
const BACKSPACE_CH = 127;
const ENTER_CH = 10;

var pair1: curses.ColorPair = undefined;
var win: curses.Window = undefined;

fn drawWin() !void {
    try win.erase();
    try win.attron(pair1.attr());

    try win.mvaddstr(TOP_LINENO, 2, fmt.comptimePrint("Cypress v1.2", .{}));
    try win.mvaddstr(TOP_LINENO + 1, 2, "q to quit");
    try win.mvaddstr(TOP_LINENO + 2, 2, "-----------");
    try win.boxme();
}

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
    win = try curses.initscr(ally);
    try curses.start_color(); // Enable color support
    try curses.cbreak();
    try curses.noecho();

    // Define color pairs
    pair1 = try curses.ColorPair.init(1, curses.COLOR_RED, curses.COLOR_BLACK);

    while (true) {
        const cmdEntered = try getCmd(0);
        _ = cmdEntered;
        // processCmd(cmdEntered);
    }

    _ = try curses.endwin();
}

fn getCmd(lineOffset: u8) !CommandBuffer {
    var cursorPos: u16 = 0;
    var cmd: CommandBuffer = undefined;
    var lineno = CMD_LINENO + lineOffset;

    // we don't need to worry about arrow keys and stuff...
    // this "shell" is gonna be dead simple. the commands
    // aren't gonna be long enough that backspacing and
    // typing over the old character will take much time.

    while (true) {
        // write cmd buffer to prompt
        try drawWin();
        try win.mvaddch(lineno + 1, 2, CMD_PROMPT);
        try win.mvaddstr(lineno, 4, cmd[0..cursorPos]);
        try curses.move(lineno, 4 + cursorPos);

        const key = try win.getch();
        const ch: u32 = @intCast(key);

        switch (key) {
            // user pressed backspace
            BACKSPACE_CH => {
                if (cursorPos > 0) {
                    cursorPos -= 1;
                }
            },

            // user pressed enter
            ENTER_CH => {
                return cmd;
            },

            // user typed a character
            0...ENTER_CH - 1, ENTER_CH + 1...BACKSPACE_CH - 1, BACKSPACE_CH + 1...255 => {
                cmd[cursorPos] = @intCast(ch);
                if (cursorPos < CMD_BUFFER_SIZE - 1) {
                    cursorPos += 1;
                }
            },

            // don't handle unicode sussery wussery shenanigans
            else => {},
        }
    }
}
