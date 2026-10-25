pub const String = extern struct {
    ptr: [*]const u8,
    len: usize,

    pub fn init(zig: anytype) String {
        return switch (@TypeOf(zig)) {
            []u8, []const u8 => .{
                .ptr = zig.ptr,
                .len = zig.len,
            },
            else => @compileError("String.init requires a byte slice"),
        };
    }
};

test "String.init borrows mutable and immutable byte slices" {
    const testing = @import("std").testing;
    const immutable: []const u8 = "hello";
    for ([_][]const u8{ immutable, immutable[0..0] }) |slice| {
        const c = String.init(slice);
        try testing.expectEqual(slice.len, c.len);
        try testing.expect(c.ptr == slice.ptr);
    }

    var storage = [_]u8{ 'h', 'i' };
    for ([_][]u8{ storage[0..], storage[0..0] }) |slice| {
        const c = String.init(slice);
        try testing.expectEqual(slice.len, c.len);
        try testing.expect(c.ptr == slice.ptr);
    }
    const borrowed = String.init(@as([]u8, storage[0..]));
    storage[0] = 'H';
    try testing.expectEqual(@as(u8, 'H'), borrowed.ptr[0]);
}
