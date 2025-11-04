# zig-exhaustigen

## Zig port of [exhaustigen-rs library](https://github.com/graydon/exhaustigen-rs) for exhaustive testing.

### Usage

1. Add `exhaustigen` dependency to `build.zig.zon`:

```sh
zig fetch --save git+https://github.com/tensorush/zig-exhaustigen.git
```

2. Use `exhaustigen` dependency in `build.zig`:

```zig
const exhaustigen_dep = b.dependency("exhaustigen", .{
    .target = target,
    .optimize = optimize,
});
const exhaustigen_mod = exhaustigen_dep.module("exhaustigen");

const root_mod = b.createModule(.{
    .target = target,
    .optimize = optimize,
    .imports = &.{
        .{ .name = "exhaustigen", .module = exhaustigen_mod },
    },
});
```
