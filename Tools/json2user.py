import sys
import os.path
import json
import re

def make_achievement_row(asset, outf):
	aid = asset['ID']
	mem = asset['MemAddr']
	title = asset['Title'].replace('"', '\"')
	desc = asset['Description'].replace('"', '\"')
	type = asset.get("Type", "")
	author = asset['Author']
	points = asset['Points']
	badge = asset['BadgeName']
	outf.write(f"""{aid}:"{mem}":"{title}":"{desc}":::{type}:{author}:{points}:::::{badge}\n""")

def make_leaderboard_row(asset, outf):
	aid = asset['ID']
	mem = re.match('STA:(.+)::CAN:(.+)::SUB:(.+)::VAL:(.+)', asset['Mem'])
	title = asset['Title'].replace('"', '\"')
	desc = asset['Description'].replace('"', '\"')
	format = asset.get("Format", "VALUE")
	lower = asset.get("LowerIsBetter", 1)
	outf.write(f"""L{aid}:"{mem.group(1)}":"{mem.group(2)}":"{mem.group(3)}":"{mem.group(4)}":{format}:"{title}":"{desc}":{lower}\n""")

infn = sys.argv[1]
with open(infn, 'r') as inf:
	data = json.loads(inf.read())

	gid = os.path.basename(infn).split('.')[0]
	with open(os.path.join(os.path.dirname(infn), '{0}-User.txt'.format(gid)), 'w') as outf:
		outf.write("1.0.0.0\n")
		outf.write(data.get('Title', '') + '\n')
		for ach in data.get('Achievements', []):
			make_achievement_row(ach, outf)
		for set in data.get('Sets', dict()):
			for ach in set.get('Achievements', []):
				make_achievement_row(ach, outf)
		for lb in data.get('Leaderboards', []):
			make_leaderboard_row(lb, outf)
		for set in data.get('Sets', dict()):
			for lb in set.get('Leaderboards', []):
				make_leaderboard_row(lb, outf)