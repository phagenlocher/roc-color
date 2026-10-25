app [main!] {
	color: "../src/main.roc",
	pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.26.0/GddgvsGjiNXrHFW6au5i5dUDbTs8FinQdrgE2Gqmw53t.tar.zst",
}

import pf.Stdout
import color.Color

count : U8, U8 -> List(U8)
count = |n, end| {
	if end < n {
		[]
	} else if end == n {
		[n]
	} else {
		List.prepend(count(n + 1, end), n)
	}
}

formatU8 : U8 -> Str
formatU8 = |n| {
	s = n.to_str()
	strLen : U64
	strLen = if (n < 10) 1 else if (n < 100) 2 else 3
	padding = Str.repeat(" ", 5 - strLen)
	"${padding}${s}"
}

main! = |_args| {
	rows = List.map(
		count(0, 31),
		|n| {
			k = n * 8
			count(k, k + 7)
		},
	)
	for row in rows {
		for elem in row {
			formatted = Color.formatWith([Color.background(Color.color256bit(elem))], formatU8(elem))
			Stdout.write!(formatted)?
		}
		Stdout.write!("\n")?
	}
	Ok({})
}
