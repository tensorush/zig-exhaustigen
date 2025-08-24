//! Exhaustive testing generator.

const std = @import("std");

const Gen = @This();

const Pair = struct {
    fst: usize = 0,
    scd: usize,
};

pairs: std.ArrayList(Pair),
allocator: std.mem.Allocator,
is_running: bool = false,
pair_idx: usize = 0,

pub fn initCapacity(allocator: std.mem.Allocator, capacity: usize) std.mem.Allocator.Error!Gen {
    return .{
        .pairs = try .initCapacity(allocator, capacity),
        .allocator = allocator,
    };
}

pub fn deinit(self: *Gen) void {
    self.pairs.deinit(self.allocator);
}

/// Returns `true` when every range of values implied by calls to `generate`
/// is finished. Otherwise restarts the innermost incomplete range, continuing
/// the exhaustive scan. This method should be called as the condition of a
/// `while` loop enclosing the test you wish to repeat exhaustively.
pub fn isRunning(self: *Gen) bool {
    if (!self.is_running) {
        self.is_running = true;
        return true;
    }

    var i = self.pairs.items.len;
    while (i > 0) {
        i -= 1;
        if (self.pairs.items[i].fst < self.pairs.items[i].scd) {
            self.pairs.items[i].fst += 1;
            self.pairs.shrinkRetainingCapacity(i + 1);
            self.pair_idx = 0;
            return true;
        }
    }

    return false;
}

/// Returns a value (eventually every value) between 0 and `bound` inclusive.
/// Every other value-generating method in this type ultimately funnels into
/// this method, which is responsible (in concert with `isRunning`) for opening
/// and stepping through ranges of the generator's state-space.
pub fn generate(self: *Gen, bound: usize) std.mem.Allocator.Error!usize {
    if (self.pair_idx == self.pairs.items.len) {
        try self.pairs.append(self.allocator, .{ .scd = bound });
    }
    defer self.pair_idx += 1;
    return self.pairs.items[self.pair_idx].fst;
}

/// Returns false, then true.
pub fn generateBool(self: *Gen) std.mem.Allocator.Error!bool {
    return try self.generate(1) == 1;
}

/// Returns an index (eventually every index) < `bound`.
pub fn generateIndex(self: *Gen, bound: usize) std.mem.Allocator.Error!usize {
    return try self.generate(bound - 1);
}

/// Generates a sequence (eventually every such sequence)
/// of variable-value elements. The sequence's length == `bound`
/// and each element's value <= `max_val`.
pub fn generateSequence(self: *Gen, bound: usize, max_val: usize, output: []usize) std.mem.Allocator.Error!void {
    const fixed = try self.generate(bound);
    std.debug.assert(output.len >= fixed);
    for (0..fixed) |i| {
        output[i] = try self.generate(max_val);
    }
}

/// Generates a combination (eventually every combination) of elements
/// selected from provided `input` slice, up to the size of that slice.
pub fn generateCombination(self: *Gen, comptime T: type, input: []const T, output: []T) std.mem.Allocator.Error!void {
    const fixed = try self.generate(input.len);
    std.debug.assert(output.len >= fixed);
    for (0..fixed) |i| {
        output[i] = input[try self.generateIndex(input.len)];
    }
}

/// Generates a permutation (eventually every permutation) of the `input` slice.
pub fn generatePermutation(self: *Gen, comptime T: type, input: []const T, output: []T) std.mem.Allocator.Error!void {
    std.debug.assert(output.len >= input.len);
    var idxs: std.ArrayList(usize) = try .initCapacity(self.allocator, input.len);
    defer idxs.deinit(self.allocator);
    for (0..input.len) |i| {
        idxs.appendAssumeCapacity(i);
    }
    for (0..input.len) |i| {
        output[i] = input[idxs.orderedRemove(try self.generateIndex(idxs.items.len))];
    }
}

/// Generates a subset (eventually every subset) of the `input` slice.
pub fn generateSubset(self: *Gen, comptime T: type, input: []const T, output: []?T) std.mem.Allocator.Error!void {
    std.debug.assert(output.len >= input.len);
    for (input, 0..) |byte, i| {
        output[i] = if (try self.generateBool()) byte else null;
    }
}

test generateIndex {
    const input = [_]u8{ 1, 2, 3, 4, 5 };

    var gen: Gen = try .initCapacity(std.testing.allocator, input.len);
    defer gen.deinit();

    var i: usize = 0;
    while (gen.isRunning()) {
        std.debug.print("{}\n", .{try gen.generateIndex(input.len)});
        i += 1;
    }

    try std.testing.expectEqual(i, 5);
}

test generateSequence {
    var gen: Gen = try .initCapacity(std.testing.allocator, 5);
    defer gen.deinit();

    const bound: usize = 3;
    var i: usize = 0;
    while (gen.isRunning()) {
        var output: [bound]usize = undefined;
        try gen.generateSequence(bound, 4, &output);
        for (output) |elem| {
            std.debug.print("{} ", .{elem});
        }
        std.debug.print("\n", .{});
        i += 1;
    }

    try std.testing.expectEqual(i, (5 * 5 * 5) + (5 * 5) + 5 + 1);
}

test generateCombination {
    const input = [_]u8{ 1, 2, 3, 4, 5 };

    var gen: Gen = try .initCapacity(std.testing.allocator, input.len);
    defer gen.deinit();

    const bound: usize = input.len;
    var i: usize = 0;
    while (gen.isRunning()) {
        var output: [bound]u8 = undefined;
        try gen.generateCombination(u8, &input, &output);
        for (output) |elem| {
            std.debug.print("{} ", .{elem});
        }
        std.debug.print("\n", .{});
        i += 1;
    }

    try std.testing.expectEqual(i, (5 * 5 * 5 * 5 * 5) + (5 * 5 * 5 * 5) + (5 * 5 * 5) + (5 * 5) + 5 + 1);
}

test generatePermutation {
    const input = [_]u8{ 1, 2, 3, 4, 5 };

    var gen: Gen = try .initCapacity(std.testing.allocator, input.len);
    defer gen.deinit();

    const bound: usize = input.len;
    var i: usize = 0;
    while (gen.isRunning()) {
        var output: [bound]u8 = undefined;
        try gen.generatePermutation(u8, &input, &output);
        for (output) |elem| {
            std.debug.print("{} ", .{elem});
        }
        std.debug.print("\n", .{});
        i += 1;
    }

    try std.testing.expectEqual(i, 5 * 4 * 3 * 2 * 1);
}

test generateSubset {
    const input = [_]u8{ 1, 2, 3, 4, 5 };

    var gen: Gen = try .initCapacity(std.testing.allocator, input.len);
    defer gen.deinit();

    const bound: usize = input.len;
    var i: usize = 0;
    while (gen.isRunning()) {
        var output: [bound]?u8 = undefined;
        try gen.generateSubset(u8, &input, &output);
        for (output) |elem_opt| {
            std.debug.print("{} ", .{elem_opt orelse continue});
        }
        std.debug.print("\n", .{});
        i += 1;
    }

    try std.testing.expectEqual(i, 1 << 5);
}
