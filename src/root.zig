//! Root source file that exposes the library's API to users and Autodoc.

const std = @import("std");

pub const Gen = @import("Gen.zig");

test {
    std.testing.refAllDecls(@This());
}
