import os
import sys
import json

with open(sys.argv[1], 'r') as f:
	data = json.load(f)
	for set in data['Sets']:
		with open(str(set['GameId']) + '.html', 'w') as fw:
			for ach in set['Achievements']:
				fw.write(f"""<img align="left" width="72" height="72" src="{ach['BadgeURL']}">

<big><pre>
[{ach['Title']} ({ach['Points']})](https://retroachievements.org/achievement/{ach['ID']})
_{ach['Description']}_
</pre></big>


""")
		with open(str(set['GameId']) + '-simple.html', 'w') as fw:
			for ach in set['Achievements']:
				fw.write(f"- [{ach['Title']} ({ach['Points']})](https://retroachievements.org/achievement/{ach['ID']})\n  - {ach['Description']}\n")