app [main!] {
	color: "../src/main.roc",
	pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.26.0/GddgvsGjiNXrHFW6au5i5dUDbTs8FinQdrgE2Gqmw53t.tar.zst",
}

import pf.Stdout
import color.Color exposing [blue, bold, formatWith, green, italic, red, underscore, whiteBg]

boldText = formatWith([bold], "bold")

underlinedText = formatWith([underscore], "underlined")

redCol = formatWith([red], "col")

greenOr = formatWith([green], "or")

blueFul = formatWith([blue], "ful")

mixedText = formatWith([underscore, italic, red], "mix")

matchText = formatWith([bold, green, whiteBg], "match")

main! = |_args| {
	Stdout.line!(
		\\This is ${boldText} text mixed with ${underlinedText} text.
		\\Text can also be ${redCol}${greenOr}${blueFul}!
		\\Of course you can ${mixedText} and ${matchText} attributes and colors freely.
	)?
	Ok({})
}
