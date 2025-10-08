const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const args = std.process.argsAlloc(allocator) catch |err| {
        try stdout.print("Failed to read args: {s}\n", .{@errorName(err)});
        return;
    };
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        try stdout.print("Usage: {s} <filename>\n", .{args[0]});
        return;
    }

    const fileName = args[1];
    var file = std.fs.cwd().openFile(fileName, .{}) catch |err| {
        try stdout.print("Error opening file {s}: {s}\n", .{fileName, @errorName(err)});
        return;
    };
    defer file.close();

    var buffer: [16]u8 = undefined;
    var offset: usize = 0;

    while (true) {
        const bytes_read = file.read(&buffer) catch |err| {
            try stdout.print("Read error at offset {d}: {s}\n", .{offset, @errorName(err)});
            return;
        };
        if (bytes_read == 0) break;

        try stdout.print("{08X}  ", .{offset});

        for (buffer[0..bytes_read]) |b| {
            try stdout.print("{02X} ", .{b});
        }

        if (bytes_read < 16) {
            for (bytes_read..16) |_| {
                try stdout.print("  ", .{});
            }
        }

        try stdout.print(" ", .{});

        for (buffer[0..bytes_read]) |b| {
            const ch: u8 = if (b >= 32 and b < 127) b else '.';
            try stdout.print("{c}", .{ch});
        }

        try stdout.print("\n", .{});
        offset += bytes_read;
    }
    
    try stdout.print("Bytes read: {d}\n", .{offset});
}
