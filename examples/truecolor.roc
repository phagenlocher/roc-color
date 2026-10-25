app [main!] {
	color: "../src/main.roc",
	pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.26.0/GddgvsGjiNXrHFW6au5i5dUDbTs8FinQdrgE2Gqmw53t.tar.zst",
}

import pf.Stdout
import color.Color

withIndex : List(a) -> List({ index : U64, x : a })
withIndex = |x| List.map_with_index(x, |elem, i| { x: elem, index: i })

main! = |_args| {
	elems : List({ index : U64, x : List({ index : U64, x : Str }) })
	elems = withIndex(List.repeat(withIndex(List.append(List.repeat(" # ", 16), "\n")), 16))

	freq : F64
	freq = 0.023

	for row in elems {
		for cell in row.x {
			k = (row.index * cell.index).to_f64()
			# This code is heavily inspired by https://github.com/busyloop/lolcat/blob/master/lib/lolcat/lol.rb#L36
			r = F64.sin(freq * k) * 127 + 128
			g = F64.sin(freq * k + (2 * F64.pi / 3)) * 127 + 128
			b = F64.sin(freq * k + (4 * F64.pi / 3)) * 127 + 128
			r8 = F64.to_u8_wrap(r)
			g8 = F64.to_u8_wrap(g)
			b8 = F64.to_u8_wrap(b)
			formatted = Color.formatWith([Color.foreground(Color.rgb(r8, g8, b8))], cell.x)
			Stdout.write!(formatted)?
		}
	}
	Ok({})
}
