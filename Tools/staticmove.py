import sys
import os.path

"""
Usage:
	$ python staticmove.py <input notes file> <hex offfset>
	produces new-User.txt containing all the same notes shifted by the provided offset
"""
infn = sys.argv[1]
offset = int(sys.argv[2], base=16)

with open(infn, 'r') as inf:
	with open(os.path.join(os.path.dirname(infn), 'new-User.txt'), 'w') as outf:
		for line in inf:
			groups = line.split(':', 3)
			groups[1] = '0x%x' % (int(groups[1], base=16) + offset)
			outf.write(':'.join(groups))