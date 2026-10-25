# roc-color
🌈 Roc package for styling terminal contents with ANSI, 256 bit color and Truecolor

The interface of this library is heavily influenced by the Haskell package [colourista](https://github.com/kowainik/colourista).

## Usage

The main function to interact with is `formatWith`. It accepts a list of display attributes plus a fore- and background color, and wraps the given text in the corresponding SGR code. At most one foreground and one background color is used.

```roc
import pf.Stdout
import color.Color exposing [
	blue,
	bold,
	color256bit,
	foreground,
	formatWith,
	italic,
	rgb,
	rgbHex,
	underscore,
	whiteBg,
]

main! = |_args| {
	heading = formatWith([bold, blue, whiteBg], "roc-color")
	accent = formatWith([italic, foreground(color256bit(42))], "256 bit colors")
	hex = formatWith([underscore, foreground(rgbHex("#6495ED"))], "hex colors")
	truecolor = formatWith([bold, foreground(rgb(25, 233, 143))], "truecolor")
	Stdout.line!("${heading}: ${accent}, ${hex} and ${truecolor}!")?
	Ok({})
}
```

More examples live in the [`examples/`](examples) directory.

## Documentation

A more detailed documentation of the exposed functions can be found at https://phagenlocher.github.io/roc-color/
