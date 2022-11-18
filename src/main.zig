const std = @import("std");

const stdin = std.io.getStdIn();
const stdout = std.io.getStdOut();

const ipv6parse = std.net.Address.parseIp6;

const readLineErr = error{bufOverflow};

const Buffer = struct {
    const Self = @This();

    string: [256]u8 = undefined,
    at: u8 = 0,
    isReady: bool = false,

    pub fn getSlice(self: Self) []const u8 {
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

    pub fn readUntilNewline(self: *Self, reader: anytype) !void {
        while (true) {
            var result: [1]u8 = undefined;
            const readbytes = try reader.read(result[0..]);
            if (readbytes < 0) return;
            if (self.at == 255) return readLineErr.bufOverflow;
            if (result[0] == '\n') {
                self.isReady = true;
                return;
            }
            self.string[self.at] = result[0];
            self.at += 1;
            sleepms(1);
        }
    }
};

fn sleepms(milliseconds: u64) void {
    std.time.sleep(milliseconds * 1_000_000);
    return;
}

pub fn main() !void {
    //var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    //const allocator = gpa.allocator();
    std.debug.print("demo\n>", .{});
    var buffere = Buffer{};
    buffere.string[0] = 'e';
    buffere.at = 1;
    buffere.reset();
    while (!buffere.isReady) {
        try buffere.readUntilNewline(stdin.reader());
    }
    std.debug.print("you said> {s}\n", .{buffere.getSlice()});
    std.debug.print("type of getslice: {any}", .{@TypeOf(buffere.getSlice())});
    std.os.exit(0);
}
