import argparse

#docs.python.org/dev/library/argparse.html
parser = argparse.ArgumentParser()
parser.add_argument("--input", help="Input fasta")
parser.add_argument("--output", help="Output fasta")
parser.add_argument("--start", help="How many nucleotides to trim from the start", type=int)
parser.add_argument("--end", help="How many nucleotides to trim from the end", type=int)

args = parser.parse_args()
start = int(args.start)
end = int(args.end)

print args.input
print args.output
print start
print end

if end <= 0 and start <= 0:
	import shutil
	shutil.copy(args.input, args.output)
	import sys
	sys.exit()
	
def trim(string, s, e):
	if e == 0:
		return string[s:]
	else:
		return string[s:-e]

currentSeq = ""
currentId = ""
with open(args.input, 'r') as i, open(args.output, 'w') as o:
	for line in i:
		print "ID:", currentId
		if line[0] == ">":
			currentSeq = trim(currentSeq, start, end)
			if len(currentId) > 0 and len(currentSeq) > 0:
				o.write(currentId)
				o.write(currentSeq + "\n")
			currentId = line
			currentSeq = ""
		else:
			currentSeq += line.rstrip()
	o.write(currentId)
	o.write(currentSeq + "\n")
