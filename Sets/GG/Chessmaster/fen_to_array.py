def fen_convert(x):
	out = "BOARD = [\n"
	for line in x.split()[0].split('/'):
		out += "\t"
		for ch in line:
			if ch.isnumeric():
				out += "XX_, "*int(ch)
			else:
				c = 'W' if ch.isupper() else 'B'
				d = '_' if ch not in 'Nn' else '1'
				out += f"{c}{ch.upper()}{d}, "
		out += '\n'
	return out + ']\n'

print(fen_convert(input()))