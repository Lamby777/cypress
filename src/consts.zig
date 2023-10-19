// the useful constants that might need to be changed
pub const CMD_BUFFER_SIZE = 64;
pub const CMD_PROMPT = '>';
pub const TOP_LINENO = 3;
pub const CMD_LINENO = 7;

// the "ignore this magic number" constants
pub const CommandBuffer = [CMD_BUFFER_SIZE]u8;
pub const BACKSPACE_CH = 127;
pub const ENTER_CH = 10;
