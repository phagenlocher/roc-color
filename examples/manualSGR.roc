app [main!] {
	color: "../src/main.roc",
	pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.26.0/GddgvsGjiNXrHFW6au5i5dUDbTs8FinQdrgE2Gqmw53t.tar.zst",
}

import pf.Stdout
import color.Color exposing [ansi, resetGraphicRendition, selectGraphicRendition]

main! = |_args| {
	line =
		selectGraphicRendition({ attrs: [Bold] })
			|> Str.concat("This text is bold but ")
			|> Str.concat(selectGraphicRendition({ fgColor: ansi(Red) }))
			|> Str.concat("now it is also red! However, ")
			|> Str.concat(resetGraphicRendition)
			|> Str.concat(selectGraphicRendition({ bgColor: ansi(White) }))
			|> Str.concat("now everything is thin again and the background has changed.")
			|> Str.concat(resetGraphicRendition)
			|> Str.concat(" Back to normal!")
	Stdout.line!(line)?
	Ok({})
}
