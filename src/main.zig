const std = @import("std");

const stdin = std.io.getStdIn();
const stdout = std.io.getStdOut();

const clientErr = error{brokenStream};
const clientStat = enum { joining, exiting, waiting };

fn sleepms(milliseconds: u64) void {
    std.time.sleep(milliseconds * 1_000_000);
    return;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    //    var bufferInst = Buffer{};

    std.debug.print("Zirc demo\nEnter Server hostname: ", .{});

    //    var hostname: []const u8 = bufferInst.getSlice();

    const hostname: []const u8 = (try stdin.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', 4096)).?;

    //    bufferInst.reset();

    std.debug.print("\nEnter Server port: ", .{});

    const portslice: []const u8 = (try stdin.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', 4096)).?;

    var port: u16 = std.fmt.parseUnsigned(u16, portslice, 10) catch |err| switch (err) {
        error.Overflow => {
            std.debug.print("Couldn't parse port, enter between 0-65535", .{});
            std.os.exit(1);
        },
        else => @panic("oongaboonga"),
    };
    //    bufferInst.reset();

    std.debug.print("\n Address: {s} {any}", .{ hostname, port });

    if (!std.net.isValidHostName(hostname)) {
        std.debug.print("Couldn't parse thy address", .{});
        std.os.exit(1);
    }

    const connection = std.net.tcpConnectToHost(allocator, hostname, port) catch |err| {
        std.debug.print("Error: Couldn't connect to host: {any}", .{err});
        std.os.exit(1);
    };

    var status: clientStat = .joining;

    while (true) {
        clientLoop(status, connection, stdin.reader(), stdin.writer()) catch |err| switch (err) {
            else => return err,
        };
    }

    allocator.free(hostname);
    allocator.free(portslice);

    //    bufferInst.reset();
}

pub fn clientLoop(status: clientStat, connection: std.net.Stream, input: anytype, output: anytype) !void {
    if (status == .joining) {
        try connection.writer().print("NICK {s}", .{"p32"});
    }
    _ = input;
    _ = output;
}
