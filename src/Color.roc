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
module [
    Color,
    AnsiColor,
    DisplayAttribute,
    formatWith,
    selectGraphicRendition,
    resetGraphicRendition,
    ansi,
    color256bit,
    rgb,
    rgbHex,
    black,
    blue,
    cyan,
    green,
    magenta,
    red,
    white,
    yellow,
    blackBg,
    blueBg,
    cyanBg,
    greenBg,
    magentaBg,
    redBg,
    whiteBg,
    yellowBg,
    blink,
    bold,
    italic,
    dim,
    hidden,
    reset,
    reverse,
    underscore,
    foreground,
    background,
]

import Hex

## Type that represents a color code for formatting.
## Use `ansi`, `color256bit` or `rgb` to construct it.
Color := [
    Ansi AnsiColor,
    Color256Bit U8,
    TrueColor { r : U8, g : U8, b : U8 },
    NotSpecified,
]

## Display attributes for SGR.
##
## When using `formatWith` you should use the lowercase variants exported
## by this module (see the documentation for `formatWith`).
##
## Please note that `Italic` is not officially specified for SGR but many
## terminals support it. `Bold` is sometimes interpreted as "bright".
## Most terminals however format the text as bold.
DisplayAttribute : [Reset, Bold, Dim, Italic, Underscore, Blink, Reverse, Hidden]

## SGR colors.
##
## These colors are most likely to work with most terminals. Use `ansi` to
## turn them into a `Color` or use the already exported constants provided
## by this module.
AnsiColor : [Black, Blue, Cyan, Green, Magenta, Red, White, Yellow]

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
## main =
##     line1 = formatWith [bold, blue, whiteBg] "foobar"
##     Stdout.line! "My first text: $(line1)"
##     line2 = formatWith [italic, underscore, foreground (rgb 25 233 143)] "barfoo"
##     Stdout.line! "My second text: $(line2)"
## ```
## Assuming that at most a single `Foreground` and `Background` color is present
## in the list, the order of elements is not relevant. If multiple `Foreground`
## and/or `Background` values are present, it's undefined which and if colors
## will be chosen.
formatWith : List [Display DisplayAttribute, Foreground Color, Background Color], Str -> Str
formatWith = \attributes, s ->
    selected : { attrs : List DisplayAttribute, bgColor : Color, fgColor : Color }
    selected =
        List.walk attributes { attrs: [], bgColor: @Color NotSpecified, fgColor: @Color NotSpecified } \state, attr ->
            when attr is
                Display displayAttr -> { state & attrs: List.append state.attrs displayAttr }
                Foreground color -> { state & fgColor: color }
                Background color -> { state & bgColor: color }
    options = { attrs: selected.attrs, bgColor: selected.bgColor, fgColor: selected.fgColor }
    "$(selectGraphicRendition options)$(s)$(resetGraphicRendition)"

## Generate a single SGR with the attributes given in a record of optional values.
## The type of this function is:
## ```
## selectGraphicRendition : { attrs ? List DisplayAttribute, bgColor ? Color, fgColor ? Color } -> Str
## ```
selectGraphicRendition = \{ attrs ? [], bgColor ? @Color NotSpecified, fgColor ? @Color NotSpecified } ->
    bgColorCode = colorCode Background bgColor
    fgColorCode = colorCode Foreground fgColor
    colorCodes = List.dropIf [bgColorCode, fgColorCode] Str.isEmpty
    attributeCodes = List.map attrs attributeCode

    attributes : Str
    attributes =
        List.concat attributeCodes colorCodes
        |> List.intersperse ";"
        |> List.walk "" Str.concat

    "\u(001b)[$(attributes)m"

## String to reset the SGR.
## This is equivalent to `selectGraphicRendition {attrs: [Reset]}`.
resetGraphicRendition : Str
resetGraphicRendition = "\u(001b)[0m"

expect resetGraphicRendition == selectGraphicRendition { attrs: [Reset] }

## Turns an `AnsiColor` into a `Color`. It's most likely that your targeted
## terminals support this color type.
ansi : AnsiColor -> Color
ansi = \x -> @Color (Ansi x)

## Turns a byte into a 256 bit color. Please note that this color type might
## not be supported by your targeted terminals. If you don't need fine-grained
## control of colors you should stick with `AnsiColor` values.
color256bit : U8 -> Color
color256bit = \x -> @Color (Color256Bit x)

## Turns three bytes into a Truecolor RGB color. Please note that this color
## type might not be supported by your targeted terminals. If you don't need
## fine-grained control of colors you should stick with `AnsiColor` values.
rgb : U8, U8, U8 -> Color
rgb = \r, g, b -> @Color (TrueColor { r, g, b })

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
rgbHex = \s ->
    when Hex.fromHexStr s is
        Ok { r, g, b } -> rgb r g b
        Err InvalidHexFormat -> @Color NotSpecified

attributeCode : DisplayAttribute -> Str
attributeCode = \attr ->
    when attr is
        Reset -> "0"
        Bold -> "1"
        Dim -> "2"
        Italic -> "3"
        Underscore -> "4"
        Blink -> "5"
        Reverse -> "7"
        Hidden -> "8"

colorCode : [Background, Foreground], Color -> Str
colorCode = \mode, @Color color ->
    when color is
        NotSpecified ->
            ""

        Ansi ansiColor ->
            when mode is
                Foreground ->
                    when ansiColor is
                        Black -> "30"
                        Red -> "31"
                        Green -> "32"
                        Yellow -> "33"
                        Blue -> "34"
                        Magenta -> "35"
                        Cyan -> "36"
                        White -> "37"

                Background ->
                    when ansiColor is
                        Black -> "40"
                        Red -> "41"
                        Green -> "42"
                        Yellow -> "43"
                        Blue -> "44"
                        Magenta -> "45"
                        Cyan -> "46"
                        White -> "47"

        Color256Bit n ->
            modeCode =
                when mode is
                    Foreground -> "38"
                    Background -> "48"
            "$(modeCode);5;$(Num.toStr n)"

        TrueColor { r, g, b } ->
            modeCode =
                when mode is
                    Foreground -> "38"
                    Background -> "48"
            "$(modeCode);2;$(Num.toStr r);$(Num.toStr g);$(Num.toStr b)"

## Marks a `Color` to be used for the foreground (the text color).
foreground : Color -> [Foreground Color]
foreground = \x -> Foreground x

## Marks a `Color` to be used for the background.
background : Color -> [Background Color]
background = \x -> Background x

black = Foreground (ansi Black)
blue = Foreground (ansi Blue)
cyan = Foreground (ansi Cyan)
green = Foreground (ansi Green)
magenta = Foreground (ansi Magenta)
red = Foreground (ansi Red)
white = Foreground (ansi White)
yellow = Foreground (ansi Yellow)

blackBg = Background (ansi Black)
blueBg = Background (ansi Blue)
cyanBg = Background (ansi Cyan)
greenBg = Background (ansi Green)
magentaBg = Background (ansi Magenta)
redBg = Background (ansi Red)
whiteBg = Background (ansi White)
yellowBg = Background (ansi Yellow)

blink = Display Blink
bold = Display Bold
italic = Display Italic
dim = Display Dim
hidden = Display Hidden
reset = Display Reset
reverse = Display Reverse
underscore = Display Underscore

