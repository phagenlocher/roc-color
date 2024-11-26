app [main] {
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.16.0/O00IPk-Krg_diNS2dVWlI0ZQP794Vctxzv0ha96mK0E.tar.br",
    color: "../src/main.roc",
}

import cli.Stdout
import color.Color exposing [formatWith, bold, underscore, italic, red, green, blue, whiteBg]

main = Stdout.line
    """
    This is $(formatWith [bold] "bold") text mixed with $(formatWith [underscore] "underlined") text.
    Text can also be $(formatWith [red] "col")$(formatWith [green] "or")$(formatWith [blue] "ful")!
    Of course you can $(formatWith [underscore, italic, red] "mix") and $(formatWith [bold, green, whiteBg] "match") attributes and colors freely.
    """
