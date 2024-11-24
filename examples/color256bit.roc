app [main] {
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.16.0/O00IPk-Krg_diNS2dVWlI0ZQP794Vctxzv0ha96mK0E.tar.br",
    color: "../src/main.roc",
}

import cli.Stdout
import color.Color

count : U8, U8 -> List U8
count = \n, end ->
    if end < n then
        []
    else if end == n then
        [n]
    else
        List.prepend (count (n + 1) end) n

formatU8 : U8 -> Str
formatU8 = \n ->
    s = Num.toStr n
    strLen =
        if n < 10 then
            1
        else if n < 100 then
            2
        else
            3
    "$(Str.repeat " " (5 - strLen))$(s)"

main =
    rows = List.map (count 0 31) \n ->
        k = n * 8
        count k (k + 7)
    Task.forEach rows \row ->
        Task.forEach! row \elem ->
            formatted = Color.formatWith [Background (Color.color256bit elem)] (formatU8 elem)
            Stdout.write! formatted
        Stdout.write "\n"

