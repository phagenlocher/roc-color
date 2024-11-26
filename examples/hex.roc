app [main] {
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.16.0/O00IPk-Krg_diNS2dVWlI0ZQP794Vctxzv0ha96mK0E.tar.br",
    color: "../src/main.roc",
}

import cli.Stdout
import color.Color exposing [formatWith, rgbHex, background, hidden]

colorBlock = \x -> formatWith [hidden, background (rgbHex x)] (Str.repeat " " 10)

main = Stdout.line
    """
    Let's look at some basic colors:
    Black:        $(colorBlock "#000")
    White:        $(colorBlock "#FFF")
    Red:          $(colorBlock "#F00")
    Green:        $(colorBlock "#080")
    Blue:         $(colorBlock "#00F")

    Now, let's look at some pretty colors:
    Pink:         $(colorBlock "#FFC0CB")
    Firebrick:    $(colorBlock "#B22222")
    Tomato:       $(colorBlock "#FF6347")
    Lavender:     $(colorBlock "#E6E6FA")
    Royal Blue:   $(colorBlock "#4169E1")
    Aquamarine:   $(colorBlock "#7FFFD4")
    """
