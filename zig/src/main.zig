const std = @import("std");

fn add_one(x: i32) i32 {
    return x + 1;
}

pub fn main() void {
    const writer = std.io.getStdOut().writer();

    writer.print("r is {d}\n", .{add_one(1)}) catch unreachable;
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}

const expect = @import("std").testing.expect;

test "if statement" {
    const a = true;
    var x: u16 = 0;
    if (a) {
        x += 1;
    } else {
        x += 2;
    }
    try expect(x == 1);
    std.log.info("hello zig, from test", .{});
}
