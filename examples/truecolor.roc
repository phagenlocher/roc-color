app [main] {
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.16.0/O00IPk-Krg_diNS2dVWlI0ZQP794Vctxzv0ha96mK0E.tar.br",
    color: "../src/main.roc",
}

import cli.Stdout
import color.Color

main =
    withIndex : List a -> List { index : U64, x : a }
    withIndex = \x -> List.mapWithIndex x \elem, i -> { x: elem, index: i }

    elems : List { index : U64, x : List { index : U64, x : Str } }
    elems = withIndex (List.repeat (withIndex (List.append (List.repeat " # " 16) "\n")) 16)

    freq : F64
    freq = 0.023

    Task.forEach elems \{ index: i, x: row } ->
        Task.forEach! row \{ index: j, x: str } ->
            k = Num.toF64 (i * j)
            # This code is heavily inspired by https://github.com/busyloop/lolcat/blob/master/lib/lolcat/lol.rb#L36
            r = Num.sin (freq * k) * 127 + 128
            g = Num.sin (freq * k + (2 * Num.pi / 3)) * 127 + 128
            b = Num.sin (freq * k + (4 * Num.pi / 3)) * 127 + 128
            r8 = Num.toU8 (Num.floor r)
            g8 = Num.toU8 (Num.floor g)
            b8 = Num.toU8 (Num.floor b)
            formatted = Color.formatWith [Foreground (Color.rgb r8 g8 b8)] str
            Stdout.write formatted
