# AGENTS.md

This repository is a Roc package for styling terminal text with ANSI escape
codes, 256-bit colors and Truecolor. Its interface is inspired by the Haskell
package [colourista](https://github.com/kowainik/colourista).

## Layout

| Path | Purpose |
| --- | --- |
| `src/main.roc` | Package declaration. Exposes the `Color` module and nothing else. |
| `src/Color.roc` | Public API: formatting, SGR generation, color constructors and attribute constants. |
| `src/Hex.roc` | Internal helper for parsing hexadecimal colors. Not exposed by the package. |
| `examples/` | Standalone Roc applications demonstrating the library. |
| `.github/workflows/` | CI plus release-time bundling and documentation deployment. |

## Toolchain

The package is developed against the Roc new-compiler nightlies. The examples
use the `basic-cli` platform version `0.26.0`, which requires
`nightly-2026-10-12-2664a27` or later.

```sh
roc version
```

## Commands

| Task | Command |
| --- | --- |
| Type-check the library | `roc check src/main.roc` |
| Run the tests | `roc test src/main.roc` |
| Type-check all examples | `for example in examples/*.roc; do roc check "$example"; done` |
| Check formatting | `roc fmt --check src examples` |
| Format everything | `roc fmt src examples` |
| Run an example | `roc run examples/simple.roc` |
| Generate documentation | `roc docs src/main.roc` |

CI runs the first four commands, so run them before committing.

## Testing

- Tests are top-level `expect` declarations in the module they cover. There is
  no separate test directory or test framework.
- `roc test src/main.roc` runs the expects in `Color` and `Hex` as well.
- Expected SGR strings use the `\u(1b)` escape, for example
  `"\u(1b)[1;31mx\u(1b)[0m"`.
- Add expects for every new formatting, color or parsing behavior.

## Code conventions

- Run `roc fmt` before committing. The formatter uses tabs; do not hand-format.
- Function and constant names are camelCase, types and tags PascalCase.
- Use `##` doc comments for exposed items and keep the module docs current.
- Keep `Color` opaque (`::`). Users must go through constructors such as `ansi`,
  `color256bit`, `rgb` and `rgbHex`, or the exported attribute constants
  (`bold`, `red`, `redBg`, ...). Do not expose or construct its tags outside
  the module.
- Keep `Hex` internal. The package entrypoint must continue to expose only
  `Color`.
- Existing public names are part of the API; avoid renaming them in refactors.

## Examples

- Each file in `examples/` is an application with the `basic-cli` platform and a
  path dependency on `../src/main.roc`.
- Examples must type-check and stay formatted; CI enforces both.
- Use the effectful `main! = |_args| { ...; Ok({}) }` entrypoint and propagate
  errors from `Stdout.line!`/`Stdout.write!` with `?`.
- Prefer the exposed `Color` helpers over constructing tags.
- The current compiler cannot parse string literals nested inside `${...}`.
  Bind the value first, then interpolate the binding.
- Multiline strings use `\\`-prefixed lines, not `"""`.

## CI and releases

- `.github/workflows/ci.yaml` runs on pushes, pull requests and manual
  dispatches: formatting, library type-check, example type-checks and tests.
- `.github/workflows/bundle.yaml` bundles and releases the library when a
  release is published.
- `.github/workflows/generate-docs.yaml` generates and deploys the API docs to
  GitHub Pages when a release is published.

## Commits

Write an imperative subject line, similar to `Add color parsing` or
`Port examples to current Roc syntax`. Add a short body with a bullet list for
changes that need more explanation.
