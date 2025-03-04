# zig-exhaustigen

## Zig port of [exhaustigen-rs library](https://github.com/graydon/exhaustigen-rs) for exhaustive testing.

### Usage

- Add `exhaustigen` dependency to `build.zig.zon`.

```sh
zig fetch --save git+https://github.com/tensorush/zig-exhaustigen
```

- Use `exhaustigen` dependency in `build.zig`.

```zig
const exhaustigen_dep = b.dependency("exhaustigen", .{
    .target = target,
    .optimize = optimize,
});
const exhaustigen_mod = exhaustigen_dep.module("Gen");
<compile>.root_module.addImport("Gen", exhaustigen_mod);
```
