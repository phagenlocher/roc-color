app [main!] {
	color: "../src/main.roc",
	pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.26.0/GddgvsGjiNXrHFW6au5i5dUDbTs8FinQdrgE2Gqmw53t.tar.zst",
}

import pf.Stdout
import color.Color exposing [background, formatWith, hidden, rgbHex]

colorBlock = |hex| formatWith([hidden, background(rgbHex(hex))], Str.repeat(" ", 10))

main! = |_args| {
	black = colorBlock("#000")
	white = colorBlock("#FFF")
	red = colorBlock("#F00")
	green = colorBlock("#080")
	blue = colorBlock("#00F")
	pink = colorBlock("#FFC0CB")
	firebrick = colorBlock("#B22222")
	tomato = colorBlock("#FF6347")
	lavender = colorBlock("#E6E6FA")
	royalBlue = colorBlock("#4169E1")
	aquamarine = colorBlock("#7FFFD4")

	Stdout.line!(
		\\Let's look at some basic colors:
		\\Black:        ${black}
		\\White:        ${white}
		\\Red:          ${red}
		\\Green:        ${green}
		\\Blue:         ${blue}
		\\
		\\Now, let's look at some pretty colors:
		\\Pink:         ${pink}
		\\Firebrick:    ${firebrick}
		\\Tomato:       ${tomato}
		\\Lavender:     ${lavender}
		\\Royal Blue:   ${royalBlue}
		\\Aquamarine:   ${aquamarine}
	)?
	Ok({})
}
