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
const cs = @import("consts.zig");

// import aliases
const heap = std.heap;
const fmt = std.fmt;
const mem = std.mem;
const Allocator = mem.Allocator;
const processCmd = shell.processCmd;
const CommandBuffer = cs.CommandBuffer;

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

    try win.mvaddstr(cs.TOP_LINENO, 2, fmt.comptimePrint("Cypress v1.2", .{}));
    try win.mvaddstr(cs.TOP_LINENO + 1, 2, modeStr);
    try win.mvaddstr(cs.TOP_LINENO + 2, 2, "-----------");
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
        try processCmd(&ally, cmdEntered);
    }

    _ = try curses.endwin();
}

fn printCmdLine(cmd: []u8, offset: u8) !void {
    var lineno = cs.CMD_LINENO + offset;
    try win.mvaddch(lineno + 1, 2, cs.CMD_PROMPT);
    try win.mvaddstr(lineno, 4, cmd);
}

/// Prompts for 1 command until the user presses enter
fn getCmd(ally: *Allocator, lineOffset: u8) !CommandBuffer {
    var cursorPos: u16 = 0;
    var cmd: CommandBuffer = undefined;
    var lineno = cs.CMD_LINENO + lineOffset;

    // we don't need to worry about arrow keys and stuff...
    // this "shell" is gonna be dead simple. the commands
    // aren't gonna be long enough that backspacing and
    // typing over the old character will take much time.

    while (true) {
        // write cmd buffer to prompt
        try drawWin(ally);
        try win.mvaddch(lineno + 1, 2, cs.CMD_PROMPT);
        try win.mvaddstr(lineno, 4, cmd[0..cursorPos]);
        try curses.move(lineno, 4 + cursorPos);

        const key = try win.getch();
        const ch: u32 = @intCast(key);

        switch (key) {
            // user pressed backspace
            cs.BACKSPACE_CH => {
                if (cursorPos > 0) {
                    cursorPos -= 1;
                }
            },

            // user pressed enter
            cs.ENTER_CH => {
                return cmd;
            },

            // user typed a character
            0...cs.ENTER_CH - 1, cs.ENTER_CH + 1...cs.BACKSPACE_CH - 1, cs.BACKSPACE_CH + 1...255 => {
                cmd[cursorPos] = @intCast(ch);
                if (cursorPos < cs.CMD_BUFFER_SIZE - 1) {
                    cursorPos += 1;
                }
            },

            // don't handle unicode sussery wussery shenanigans
            else => {},
        }
    }
}
