## # Color
## https://graphcomp.com/info/specs/ansi_col.html
## https://github.com/termstandard/colors
## https://www.hackitu.de/termcolor256/
## https://chrisyeh96.github.io/2020/03/28/terminal-colors.html
module [
    formatWith,
    ansi,
    color256bit,
    rgb,
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
    selectGraphicRendition,
    resetGraphicRendition,
]

Optional a : [None, Some a]

DisplayAttribute : [Blink, Bold, Italic, Dim, Hidden, Reset, Reverse, Underscore]

AnsiColor := [Black, Blue, Cyan, Green, Magenta, Red, White, Yellow]

Color256Bit := U8

TrueRGB := { r : U8, g : U8, b : U8 }

Color := [Ansi AnsiColor, Bit256 Color256Bit, TrueColor TrueRGB]

ansi : [Black, Blue, Cyan, Green, Magenta, Red, White, Yellow] -> Color
ansi = \x -> @Color (Ansi (@AnsiColor x))

color256bit : U8 -> Color
color256bit = \x -> @Color (Bit256 (@Color256Bit x))

rgb : U8, U8, U8 -> Color
rgb = \r, g, b -> @Color (TrueColor (@TrueRGB { r, g, b }))

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

formatWith : List [Display DisplayAttribute, Foreground Color, Background Color], Str -> Str
formatWith = \attributes, s ->
    selected : { attrs : List DisplayAttribute, bgColor : Optional Color, fgColor : Optional Color }
    selected =
        List.walk attributes { attrs: [], bgColor: None, fgColor: None } \state, attr ->
            when attr is
                Display displayAttr -> { state & attrs: List.append state.attrs displayAttr }
                Foreground color -> { state & fgColor: Some color }
                Background color -> { state & bgColor: Some color }
    options = { attrs: selected.attrs, bgColor: selected.bgColor, fgColor: selected.fgColor }
    "$(selectGraphicRendition options)$(s)$(resetGraphicRendition)"

selectGraphicRendition : { attrs ? List DisplayAttribute, bgColor ? Optional Color, fgColor ? Optional Color } -> Str
selectGraphicRendition = \{ attrs ? [], bgColor ? None, fgColor ? None } ->
    attributes : Str
    attributes =
        List.map attrs attributeCode
        |> List.intersperse ";"
        |> List.walk "" Str.concat

    getColorCode : [Background, Foreground], Optional Color -> Str
    getColorCode = \mode, x ->
        when x is
            None -> ""
            Some color -> ";$(colorCode mode color)"

    "\u(001b)[$(attributes)$(getColorCode Background bgColor)$(getColorCode Foreground fgColor)m"

resetGraphicRendition : Str
resetGraphicRendition = "\u(001b)[0m"

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
        Ansi (@AnsiColor ansiColor) ->
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

        Bit256 (@Color256Bit n) ->
            modeCode =
                when mode is
                    Foreground -> "38"
                    Background -> "48"
            "$(modeCode);5;$(Num.toStr n)"

        TrueColor (@TrueRGB { r, g, b }) ->
            modeCode =
                when mode is
                    Foreground -> "38"
                    Background -> "48"
            "$(modeCode);2;$(Num.toStr r);$(Num.toStr g);$(Num.toStr b)"

