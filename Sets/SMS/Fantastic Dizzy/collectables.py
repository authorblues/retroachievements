import re

with open('collectables.txt', 'r') as f:
	addr = None
	for line in f:
		line = line.strip()
		if line == '':
			addr = None
			continue
		if addr is None:
			addr = line
			continue
		if result := re.match(r"bit(\d) \| (\S+) \((0x..) - (.+)\)", line):
			print(f'{{"addr": {addr}, "bit": {result.group(1)}, "screen": {result.group(3)}, "type": "{result.group(2).lower()}"}}, // {result.group(4)}')