import os
import sys
import json

with open(sys.argv[1], 'r') as f:
	data = json.loads(f.read())
	for set in data["Sets"]:
		title = set["Title"]
		print((title if title is not None else "Core") + ":")
		for ach in set["Achievements"]:
			if '--' in ach["Description"]:
				password = ach["Description"].split('--')[-1].strip().split()[0]
				print(f"[ach={ach['ID']}]\n[code]{password}[/code]\n")