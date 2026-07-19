import os
import sys

lines = []
with open(sys.argv[1], 'r') as f:
	for line in f:
		al, addr, name = line.split()
		lines.append((addr, name))

with open(sys.argv[2], 'w') as f:
	for addr, name in sorted(lines, key=lambda x: int(x[0], base=16)):
		print(addr, name, file=f)