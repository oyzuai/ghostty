const std = @import("std");
const Color = @import("Color.zig").Color;
const formatterpkg = @import("entry_formatter.zig");

pub const BoldColor = union(enum) {
    color: Color,
    bright,

    pub fn parseCLI(input_: ?[]const u8) !BoldColor {
        const input = input_ orelse return error.ValueRequired;
        if (std.mem.eql(u8, input, "bright")) return .bright;
        return .{ .color = try Color.parseCLI(input) };
    }

    /// Used by Formatter
    pub fn formatEntry(self: BoldColor, formatter: formatterpkg.EntryFormatter) !void {
        switch (self) {
            .color => try self.color.formatEntry(formatter),
            .bright => try formatter.formatEntry(
                [:0]const u8,
                @tagName(self),
            ),
        }
    }

    test "parseCLI" {
        const testing = std.testing;

        try testing.expectEqual(
            BoldColor{ .color = Color{ .r = 78, .g = 42, .b = 132 } },
            try BoldColor.parseCLI("#4e2a84"),
        );
        try testing.expectEqual(
            BoldColor{ .color = Color{ .r = 0, .g = 0, .b = 0 } },
            try BoldColor.parseCLI("black"),
        );
        try testing.expectEqual(
            BoldColor.bright,
            try BoldColor.parseCLI("bright"),
        );

        try testing.expectError(error.InvalidValue, BoldColor.parseCLI("a"));
    }

    test "formatConfig" {
        const testing = std.testing;
        var buf: std.Io.Writer.Allocating = .init(testing.allocator);
        defer buf.deinit();

        var sc: BoldColor = .bright;
        try sc.formatEntry(formatterpkg.entryFormatter("a", &buf.writer));
        try testing.expectEqualSlices(u8, "a = bright\n", buf.written());
    }
};
