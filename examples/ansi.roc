app [main!] {
	color: "../src/main.roc",
	pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.26.0/GddgvsGjiNXrHFW6au5i5dUDbTs8FinQdrgE2Gqmw53t.tar.zst",
}

import pf.Stdout
import color.Color

attributes = [
	{ name: "Blink", attr: Color.blink },
	{ name: "Bold", attr: Color.bold },
	{ name: "Dim", attr: Color.dim },
	{ name: "Hidden", attr: Color.hidden },
	{ name: "Reset", attr: Color.reset },
	{ name: "Reverse", attr: Color.reverse },
	{ name: "Underscore", attr: Color.underscore },
]

colors = [
	{ name: "Black", fg: Color.black, bg: Color.blackBg },
	{ name: "Blue", fg: Color.blue, bg: Color.blueBg },
	{ name: "Cyan", fg: Color.cyan, bg: Color.cyanBg },
	{ name: "Green", fg: Color.green, bg: Color.greenBg },
	{ name: "Magenta", fg: Color.magenta, bg: Color.magentaBg },
	{ name: "Red", fg: Color.red, bg: Color.redBg },
	{ name: "White", fg: Color.white, bg: Color.whiteBg },
	{ name: "Yellow", fg: Color.yellow, bg: Color.yellowBg },
]

main! = |_args| {
	for attribute in attributes {
		Stdout.line!("${attribute.name}:")?
		for fg in colors {
			Stdout.write!("\n")?
			for bg in colors {
				formatted = Color.formatWith(
					[attribute.attr, fg.fg, bg.bg],
					"${fg.name} on ${bg.name}",
				)
				Stdout.write!("${formatted} ")?
			}
			Stdout.write!("\n")?
		}
		Stdout.write!("\n")?
	}
	Ok({})
}
