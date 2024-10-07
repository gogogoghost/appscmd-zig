const std = @import("std");
const lib = @import("./lib.zig");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub fn print_help() void {
    const content =
        \\ appscmd-cli usage:
        \\     install     <path>         Install the application specific by the path.
        \\     install-pwa <url>          Install the PWA specific by the url.
        \\     uninstall   <url>          Uninstall the application specific by the url.
        \\     list                       Print all applications on this device.
    ;
    std.debug.print("{s}\n", .{content});
}

pub fn install(path: []const u8) !void {
    const response = try lib.send(.{ .cmd = "install", .param = path }, allocator);
    if (response.success) |success| {
        std.debug.print("{s}\n", .{success.string});
    } else if (response.@"error") |err| {
        std.debug.print("{s}\n", .{err});
    }
}

pub fn install_pwa(url: []const u8) !void {
    const response = try lib.send(.{ .cmd = "install-pwa", .param = url }, allocator);
    if (response.success) |success| {
        std.debug.print("{s}\n", .{success.string});
    } else if (response.@"error") |err| {
        std.debug.print("{s}\n", .{err});
    }
}

pub fn list() !void {
    const response = try lib.send(.{ .cmd = "list" }, allocator);
    if (response.success) |success| {
        const app_list = try std.json.parseFromSlice(std.json.Value, allocator, success.string, .{});
        for (app_list.value.array.items) |item| {
            const obj = item.object;
            const name = obj.get("name").?;
            std.debug.print(" {s}\n", .{name.string});
            for (obj.keys()) |key| {
                if (!std.mem.eql(u8, key, "name")) {
                    const value = obj.get(key).?;
                    std.debug.print("     {s:<24} ", .{key});
                    switch (value) {
                        .null => {
                            std.debug.print("null", .{});
                        },
                        .string => {
                            std.debug.print("{s}", .{value.string});
                        },
                        .bool => {
                            std.debug.print("{}", .{value.bool});
                        },
                        .integer => {
                            std.debug.print("{}", .{value.integer});
                        },
                        else => {},
                    }
                    std.debug.print("\n", .{});
                }
            }
            std.debug.print("\n", .{});
        }
    } else if (response.@"error") |err| {
        std.debug.print("{s}\n", .{err});
    }
}

fn uninstall(url: []const u8) !void {
    const response = try lib.send(.{ .cmd = "uninstall", .param = url }, allocator);
    if (response.success) |success| {
        std.debug.print("{s}\n", .{success.string});
    } else if (response.@"error") |err| {
        std.debug.print("{s}\n", .{err});
    }
}

pub fn main() !void {
    var args = std.process.args();
    _ = args.next();
    if (args.next()) |cmd| {
        if (std.mem.eql(u8, cmd, "install")) {
            if (args.next()) |path| {
                try install(path);
            } else {
                return print_help();
            }
        } else if (std.mem.eql(u8, cmd, "install-pwa")) {
            if (args.next()) |url| {
                try install_pwa(url);
            } else {
                return print_help();
            }
        } else if (std.mem.eql(u8, cmd, "list")) {
            try list();
        } else if (std.mem.eql(u8, cmd, "uninstall")) {
            if (args.next()) |url| {
                try uninstall(url);
            } else {
                return print_help();
            }
        } else {
            print_help();
        }
    } else {
        print_help();
    }
}
