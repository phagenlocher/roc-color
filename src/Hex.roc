Hex :: [].{
	fromHexStr : Str -> Try({ r : U8, g : U8, b : U8 }, [InvalidHexFormat])
	fromHexStr = |s| {
		digitFromHex : U8 -> Try(U8, [InvalidHexFormat])
		digitFromHex = |c| match c {
			'0' => Ok(0)
			'1' => Ok(1)
			'2' => Ok(2)
			'3' => Ok(3)
			'4' => Ok(4)
			'5' => Ok(5)
			'6' => Ok(6)
			'7' => Ok(7)
			'8' => Ok(8)
			'9' => Ok(9)
			'a' | 'A' => Ok(10)
			'b' | 'B' => Ok(11)
			'c' | 'C' => Ok(12)
			'd' | 'D' => Ok(13)
			'e' | 'E' => Ok(14)
			'f' | 'F' => Ok(15)
			_ => Err(InvalidHexFormat)
		}

		numberFromDigits : U8, U8 -> Try(U8, [InvalidHexFormat])
		numberFromDigits = |x, y| match (digitFromHex(x), digitFromHex(y)) {
			(Ok(first), Ok(second)) => Ok(first * 16 + second)
			_ => Err(InvalidHexFormat)
		}

		parsedHex :
			Try(
				{
					r : Try(U8, [InvalidHexFormat]),
					g : Try(U8, [InvalidHexFormat]),
					b : Try(U8, [InvalidHexFormat]),
				},
				[InvalidHexFormat],
			)
		parsedHex = match Str.to_utf8(s) {
			[r, g, b] =>
				Ok({
					r: numberFromDigits(r, r),
					g: numberFromDigits(g, g),
					b: numberFromDigits(b, b),
				})

			[r1, r2, g1, g2, b1, b2] =>
				Ok({
					r: numberFromDigits(r1, r2),
					g: numberFromDigits(g1, g2),
					b: numberFromDigits(b1, b2),
				})

			['#', r, g, b] =>
				Ok({
					r: numberFromDigits(r, r),
					g: numberFromDigits(g, g),
					b: numberFromDigits(b, b),
				})

			['#', r1, r2, g1, g2, b1, b2] =>
				Ok({
					r: numberFromDigits(r1, r2),
					g: numberFromDigits(g1, g2),
					b: numberFromDigits(b1, b2),
				})

			_ => Err(InvalidHexFormat)
		}

		match parsedHex {
			Ok({ r: Ok(okR), g: Ok(okG), b: Ok(okB) }) => Ok({ r: okR, g: okG, b: okB })
			_ => Err(InvalidHexFormat)
		}
	}
}

expect {
	withHash = Hex.fromHexStr("#AAA")
	withoutHash = Hex.fromHexStr("AAA")
	withHash == withoutHash
}

expect {
	lowercase = Hex.fromHexStr("abc")
	uppercase = Hex.fromHexStr("ABC")
	lowercase == uppercase
}

expect {
	hexColor = Hex.fromHexStr("000")
	hexColor == Ok({ r: 0, g: 0, b: 0 })
}

expect {
	hexColor = Hex.fromHexStr("fff")
	hexColor == Ok({ r: 255, g: 255, b: 255 })
}

expect {
	hexColor = Hex.fromHexStr("#6495ED")
	hexColor == Ok({ r: 100, g: 149, b: 237 })
}
