const std = @import("std");

const readLineErr = error{bufOverflow};

pub const Buffer = struct {
    const Self = @This();

    string: [256]u8 = undefined,
    at: u8 = 0,
    isReady: bool = false,

    pub fn getSlice(self: *Self) []u8 {
        return self.string[0..self.at];
    }

    pub fn reset(self: *Self) void {
        for (self.string) |value, index| {
            _ = value;
            self.string[index] = 0;
        }
        self.at = 0;
        self.isReady = false;
    }
};
