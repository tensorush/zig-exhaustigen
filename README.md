# zig-exhaustigen

[![CI][ci-shd]][ci-url]
[![CD][cd-shd]][cd-url]
[![DC][dc-shd]][dc-url]
[![LC][lc-shd]][lc-url]

## Zig port of [exhaustigen](https://github.com/graydon/exhaustigen-rs) exhaustive testing library.

### Usage

- Add `exhaustigen` dependency to `build.zig.zon`.

```sh
zig fetch --save git+https://github.com/tensorush/zig-exhaustigen#<git_tag_or_commit_hash>
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

<!-- MARKDOWN LINKS -->

[ci-shd]: https://img.shields.io/github/actions/workflow/status/tensorush/zig-exhaustigen/ci.yaml?branch=main&style=for-the-badge&logo=github&label=CI&labelColor=black
[ci-url]: https://github.com/tensorush/zig-exhaustigen/blob/main/.github/workflows/ci.yaml
[cd-shd]: https://img.shields.io/github/actions/workflow/status/tensorush/zig-exhaustigen/cd.yaml?branch=main&style=for-the-badge&logo=github&label=CD&labelColor=black
[cd-url]: https://github.com/tensorush/zig-exhaustigen/blob/main/.github/workflows/cd.yaml
[dc-shd]: https://img.shields.io/badge/click-F6A516?style=for-the-badge&logo=zig&logoColor=F6A516&label=doc&labelColor=black
[dc-url]: https://tensorush.github.io/zig-exhaustigen
[lc-shd]: https://img.shields.io/github/license/tensorush/zig-exhaustigen.svg?style=for-the-badge&labelColor=black
[lc-url]: https://github.com/tensorush/zig-exhaustigen/blob/main/LICENSE
