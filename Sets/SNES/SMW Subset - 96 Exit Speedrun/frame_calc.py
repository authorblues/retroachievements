import re

fn = 'SMW [Subset - Sub 90-Minute 96 Exit Speedrun].rascript'

def calc_frames(m):
	a, b = int(m.group(1)), int(m.group(2))
	return f"| [frames={b-a}] enter {a}, end {b}"

with open(fn, 'r', encoding='utf8', errors='ignore') as f:
	src = f.read()

src = re.sub('\| \[frames=\d+\]', '|', src)
src = re.sub('\| enter (\d+), end (\d+)', calc_frames, src)

with open(fn, 'w', encoding='utf8', errors='ignore') as f:
	f.write(src)