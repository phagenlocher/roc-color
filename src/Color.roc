## # Color
##
## This module exposes functionality to format `Str` values with ansi escape
## codes using [Select Graphic Rendition (SGR)](https://vt100.net/docs/vt510-rm/SGR.html)
## to format text on the terminal. For usage, check the examples!
##
## Further reading:
## - [https://graphcomp.com/info/specs/ansi_col.html](https://graphcomp.com/info/specs/ansi_col.html)
## - [https://github.com/termstandard/colors](https://github.com/termstandard/colors)
## - [https://www.hackitu.de/termcolor256/](https://www.hackitu.de/termcolor256/)
## - [https://chrisyeh96.github.io/2020/03/28/terminal-colors.html](https://chrisyeh96.github.io/2020/03/28/terminal-colors.html)

import Hex

## Type that represents a color code for formatting.
## Use `ansi`, `color256bit` or `rgb` to construct it.
Color :: [Ansi(AnsiColor), Color256Bit(U8), TrueColor({ r : U8, g : U8, b : U8 }), NotSpecified].{

	## SGR colors.
	##
	## These colors are most likely to work with most terminals. Use `ansi` to
	## turn them into a `Color` or use the already exported constants provided
	## by this module.
	AnsiColor : [Black, Blue, Cyan, Green, Magenta, Red, White, Yellow]

	## Display attributes for SGR.
	##
	## When using `formatWith` you should use the lowercase variants exported
	## by this module (see the documentation for `formatWith`).
	##
	## Please note that `Italic` is not officially specified for SGR but many
	## terminals support it. `Bold` is sometimes interpreted as "bright".
	## Most terminals however format the text as bold.
	DisplayAttribute : [Reset, Bold, Dim, Italic, Underscore, Blink, Reverse, Hidden]

	## The attributes and fore-/background colors accepted by `formatWith`.
	Attribute : [Display(DisplayAttribute), Foreground(Color), Background(Color)]

	## Wraps the string argument with a SGR that reflects the attributes and
	## colors in the input list and a reset for SGR after it. When printing
	## the resulting string to the terminal, it will be styled acoordingly
	## assuming the terminal supports the chosen display attributes and colors.
	##
	## ## Usage
	## You are meant to import this function and your desired attributes by
	## `exposing` them, so the syntax is less cluttered.
	## ```
	## import color.Color exposing [formatWith, bold, italic, underscore, rgb, blue, whiteBg, foreground]
	##
	## main! = |_| {
	##     line1 = formatWith([bold, blue, whiteBg], "foobar")
	##     echo!("My first text: ${line1}")
	##     line2 = formatWith([italic, underscore, foreground(rgb(25, 233, 143))], "barfoo")
	##     echo!("My second text: ${line2}")
	##     Ok({})
	## }
	## ```
	## Assuming that at most a single `Foreground` and `Background` color is present
	## in the list, the order of elements is not relevant. If multiple `Foreground`
	## and/or `Background` values are present, it's undefined which and if colors
	## will be chosen.
	formatWith : List(Attribute), Str -> Str
	formatWith = |attributes, s| {
		selected : { attrs : List(DisplayAttribute), bgColor : Color, fgColor : Color }
		selected =
			List.fold(
				attributes,
				{ attrs: [], bgColor: NotSpecified, fgColor: NotSpecified },
				|state, attr| match attr {
					Display(displayAttr) => { ..state, attrs: state.attrs.append(displayAttr) }
					Foreground(color) => { ..state, fgColor: color }
					Background(color) => { ..state, bgColor: color }
				},
			)

		"${selectGraphicRendition({ attrs: selected.attrs, bgColor: selected.bgColor, fgColor: selected.fgColor })}${s}${resetGraphicRendition}"
	}

	## Generate a single SGR with the attributes given in a record of optional values.
	## The type of this function is:
	## ```
	## selectGraphicRendition : {
	##     attrs ?: List(DisplayAttribute),
	##     bgColor ?: Color,
	##     fgColor ?: Color,
	## } -> Str
	## ```
	selectGraphicRendition : {
		attrs ?: List(DisplayAttribute),
		bgColor ?: Color,
		fgColor ?: Color,
	} -> Str
	selectGraphicRendition = |options| {
		attrs = options.?attrs ?? []
		bgColor = options.?bgColor ?? NotSpecified
		fgColor = options.?fgColor ?? NotSpecified

		bgColorCode = colorCode(Background, bgColor)
		fgColorCode = colorCode(Foreground, fgColor)
		colorCodes = [bgColorCode, fgColorCode].drop_if(|code| code.is_empty())
		attributeCodes = attrs.map(|attr| attributeCode(attr))

		attributes : Str
		attributes =
			attributeCodes
				.concat(colorCodes)
				.intersperse(";")
				.fold("", |acc, part| acc.concat(part))

		"\u(001b)[${attributes}m"
	}

	## String to reset the SGR.
	## This is equivalent to `selectGraphicRendition {attrs: [Reset]}`.
	resetGraphicRendition : Str
	resetGraphicRendition = "\u(001b)[0m"

	## Turns an `AnsiColor` into a `Color`. It's most likely that your targeted
	## terminals support this color type.
	ansi : AnsiColor -> Color
	ansi = |x| Ansi(x)

	## Turns a byte into a 256 bit color. Please note that this color type might
	## not be supported by your targeted terminals. If you don't need fine-grained
	## control of colors you should stick with `AnsiColor` values.
	color256bit : U8 -> Color
	color256bit = |x| Color256Bit(x)

	## Turns three bytes into a Truecolor RGB color. Please note that this color
	## type might not be supported by your targeted terminals. If you don't need
	## fine-grained control of colors you should stick with `AnsiColor` values.
	rgb : U8, U8, U8 -> Color
	rgb = |r, g, b| TrueColor({ r, g, b })

	## Interprets a [hexadecimal color](https://en.wikipedia.org/wiki/Web_colors)
	## as a Truecolor RGB color. If the supplied string fails to parse, the color
	## will not influence formatting.
	##
	## ## Format
	## `#rrggbb` or `#rgb`
	##
	## The string must contain 3 bytes in hexadecimal format (00-FF).
	## Alternatively, the string can only consist of three characters (0-F) that
	## describe the individual bytes to be made up of the specified character
	## twice, meaning that `F` turns into `FF` and `5` turns into `55`.
	## Letters can be uppercase or lowercase. The string can be prefixed with an
	## optional `#`.
	##
	## ## Examples
	## `"#000"` results in black color.
	## `"#1E90FF"` is an RGB value of (30, 144, 255).
	rgbHex : Str -> Color
	rgbHex = |s| match Hex.fromHexStr(s) {
		Ok({ r, g, b }) => rgb(r, g, b)
		Err(InvalidHexFormat) => NotSpecified
	}

	## Marks a `Color` to be used for the foreground (the text color).
	foreground : Color -> Attribute
	foreground = |x| Foreground(x)

	## Marks a `Color` to be used for the background.
	background : Color -> Attribute
	background = |x| Background(x)

	black : Attribute
	black = Foreground(ansi(Black))
	blue : Attribute
	blue = Foreground(ansi(Blue))
	cyan : Attribute
	cyan = Foreground(ansi(Cyan))
	green : Attribute
	green = Foreground(ansi(Green))
	magenta : Attribute
	magenta = Foreground(ansi(Magenta))
	red : Attribute
	red = Foreground(ansi(Red))
	white : Attribute
	white = Foreground(ansi(White))
	yellow : Attribute
	yellow = Foreground(ansi(Yellow))

	blackBg : Attribute
	blackBg = Background(ansi(Black))
	blueBg : Attribute
	blueBg = Background(ansi(Blue))
	cyanBg : Attribute
	cyanBg = Background(ansi(Cyan))
	greenBg : Attribute
	greenBg = Background(ansi(Green))
	magentaBg : Attribute
	magentaBg = Background(ansi(Magenta))
	redBg : Attribute
	redBg = Background(ansi(Red))
	whiteBg : Attribute
	whiteBg = Background(ansi(White))
	yellowBg : Attribute
	yellowBg = Background(ansi(Yellow))

	blink : Attribute
	blink = Display(Blink)
	bold : Attribute
	bold = Display(Bold)
	italic : Attribute
	italic = Display(Italic)
	dim : Attribute
	dim = Display(Dim)
	hidden : Attribute
	hidden = Display(Hidden)
	reset : Attribute
	reset = Display(Reset)
	reverse : Attribute
	reverse = Display(Reverse)
	underscore : Attribute
	underscore = Display(Underscore)
}

attributeCode : Color.DisplayAttribute -> Str
attributeCode = |attr| match attr {
	Reset => "0"
	Bold => "1"
	Dim => "2"
	Italic => "3"
	Underscore => "4"
	Blink => "5"
	Reverse => "7"
	Hidden => "8"
}

colorCode : [Background, Foreground], Color -> Str
colorCode = |mode, color| match color {
	NotSpecified => ""
	Ansi(ansiColor) =>
		match (mode, ansiColor) {
			(Foreground, Black) => "30"
			(Foreground, Red) => "31"
			(Foreground, Green) => "32"
			(Foreground, Yellow) => "33"
			(Foreground, Blue) => "34"
			(Foreground, Magenta) => "35"
			(Foreground, Cyan) => "36"
			(Foreground, White) => "37"
			(Background, Black) => "40"
			(Background, Red) => "41"
			(Background, Green) => "42"
			(Background, Yellow) => "43"
			(Background, Blue) => "44"
			(Background, Magenta) => "45"
			(Background, Cyan) => "46"
			(Background, White) => "47"
		}

	Color256Bit(n) => "${modeCode(mode)};5;${n.to_str()}"
	TrueColor({ r, g, b }) => "${modeCode(mode)};2;${r.to_str()};${g.to_str()};${b.to_str()}"
}

modeCode : [Background, Foreground] -> Str
modeCode = |mode| match mode {
	Foreground => "38"
	Background => "48"
}

expect Color.resetGraphicRendition == Color.selectGraphicRendition({ attrs: [Reset] })

expect Color.formatWith([Color.bold, Color.red], "x") == "\u(1b)[1;31mx\u(1b)[0m"

expect Color.formatWith([Color.bold, Color.redBg, Color.foreground(Color.color256bit(42))], "x") == "\u(1b)[1;41;38;5;42mx\u(1b)[0m"

expect Color.formatWith([Color.background(Color.rgbHex("#6495ED")), Color.foreground(Color.rgb(30, 144, 255))], "x") == "\u(1b)[48;2;100;149;237;38;2;30;144;255mx\u(1b)[0m"

expect Color.selectGraphicRendition({}) == "\u(1b)[m"

expect Color.selectGraphicRendition({ attrs: [Bold, Underscore] }) == "\u(1b)[1;4m"

expect Color.formatWith([Color.foreground(Color.rgbHex("not-a-color"))], "x") == "\u(1b)[mx\u(1b)[0m"
