import sys

game = sys.argv[1].upper()
with open('secrets.csv', 'r') as f:
	for line in f:
		addr,name,data = line.strip().split(' | ')
		kind = name.split(' Hit ')[0]
		for loc in data.split(': ')[1].split(', '):
			if loc.strip().startswith(game):
				parts = loc.split(' ', 2)
				if len(parts) > 2 and parts[2].strip() != '':
					kind = parts[2][1:-1].strip()
				print(f"""\t{{"scene": {parts[1]}, "flag": 0x{addr[2:].upper()}, }}, // {kind}""")