app [main] {
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.16.0/O00IPk-Krg_diNS2dVWlI0ZQP794Vctxzv0ha96mK0E.tar.br",
    color: "../src/main.roc",
}

import cli.Stdout
import color.Color

displayAttributes = [Blink, Bold, Dim, Hidden, Reset, Reverse, Underscore]
color = [Black, Blue, Cyan, Green, Magenta, Red, White, Yellow]

main =
    Task.forEach displayAttributes \attr ->
        Stdout.line! "$(Inspect.toStr attr):"
        Task.forEach! color \fg ->
            Stdout.write! "\n"
            Task.forEach! color \bg ->
                string = "$(Inspect.toStr fg) on $(Inspect.toStr bg)"
                formatted = Color.formatWith [Display attr, Foreground (Color.ansi fg), Background (Color.ansi bg)] string
                Stdout.write "$(formatted) "
            Stdout.write! "\n"
        Stdout.write! "\n"
