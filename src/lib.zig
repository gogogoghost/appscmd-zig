const std = @import("std");

const Request = struct { cmd: []const u8, param: ?[]const u8 = null };
const Response = struct { name: []const u8, success: ?std.json.Value = null, @"error": ?[]const u8 = null };

const errors = error{UnexpectEOF};

pub fn send(request: Request, allocator: std.mem.Allocator) !Response {
    //connect
    const stream = try std.net.connectUnixSocket("/data/local/tmp/apps-uds.sock");
    defer stream.close();

    //send
    try std.json.stringify(request, .{}, stream.writer());
    try stream.writeAll("\r\n");

    var list = std.ArrayList(u8).init(allocator);
    // defer list.deinit();
    var buffer: [1024]u8 = undefined;

    while (true) {
        const bytes_read = try stream.read(&buffer);

        if (bytes_read == 0) {
            return errors.UnexpectEOF;
        }

        try list.appendSlice(buffer[0..bytes_read]);

        // 检查是否接收到 "\r\n"
        if (list.items.len >= 2 and list.items[list.items.len - 2] == '\r' and list.items[list.items.len - 1] == '\n') {
            break;
        }
    }
    const parsed = try std.json.parseFromSlice(Response, allocator, list.items[0 .. list.items.len - 2], .{});
    return parsed.value;
}
