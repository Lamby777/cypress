/////////////////////////////////////
//          Cypress v1.2           //
//  A simple interactive shell for //
//   auditing CyberPatriot images  //
//                                 //
//       - &Cherry, 8/9/2023       //
/////////////////////////////////////

// imports
const std = @import("std");
const curses = @import("curses.zig");
const shell = @import("shell.zig");

// import aliases
const heap = std.heap;
const fmt = std.fmt;
const mem = std.mem;
const Allocator = mem.Allocator;
const processCmd = shell.processCmd;

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
var mode: Mode = .Exec;

const Mode = enum {
    Exec,
    Audit,

    fn fmt(self: Mode) []const u8 {
        switch (self) {
            .Exec => return "EXEC",
            .Audit => return "AUDIT",
        }
    }
};

fn drawWin(ally: *Allocator) !void {
    try win.erase();
    try win.attron(pair1.attr());

    const modeStr = try fmt.allocPrint(ally.*, "Current mode: {s}", .{mode.fmt()});
    defer ally.free(modeStr);

    try win.mvaddstr(TOP_LINENO, 2, fmt.comptimePrint("Cypress v1.2", .{}));
    try win.mvaddstr(TOP_LINENO + 1, 2, modeStr);
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
        const cmdEntered = try getCmd(&ally, 0);
        processCmd(cmdEntered);
    }

    _ = try curses.endwin();
}

fn printCmdLine(cmd: []u8, offset: u8) !void {
    var lineno = CMD_LINENO + offset;
    try win.mvaddch(lineno + 1, 2, CMD_PROMPT);
    try win.mvaddstr(lineno, 4, cmd);
}

/// Prompts for 1 command until the user presses enter
fn getCmd(ally: *Allocator, lineOffset: u8) !CommandBuffer {
    var cursorPos: u16 = 0;
    var cmd: CommandBuffer = undefined;
    var lineno = CMD_LINENO + lineOffset;

    // we don't need to worry about arrow keys and stuff...
    // this "shell" is gonna be dead simple. the commands
    // aren't gonna be long enough that backspacing and
    // typing over the old character will take much time.

    while (true) {
        // write cmd buffer to prompt
        try drawWin(ally);
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
