app [main] {
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.16.0/O00IPk-Krg_diNS2dVWlI0ZQP794Vctxzv0ha96mK0E.tar.br",
    color: "../src/main.roc",
}

import cli.Stdout
import color.Color exposing [selectGraphicRendition, resetGraphicRendition, ansi]

main = Stdout.line
    (
        selectGraphicRendition { attrs: [Bold] }
        |> Str.concat "This text is bold but "
        |> Str.concat (selectGraphicRendition { fgColor: ansi Red })
        |> Str.concat "now it is also red! However, "
        |> Str.concat resetGraphicRendition
        |> Str.concat (selectGraphicRendition { bgColor: ansi White })
        |> Str.concat "now everything is thin again and the background has changed."
        |> Str.concat resetGraphicRendition
        |> Str.concat " Back to normal!"
    )
