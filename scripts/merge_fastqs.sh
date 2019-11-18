# This script should merge all files from a given sample (the sample id is provided in the third argument)
# into a single file, which should be stored in the output directory specified by the second argument.
# The directory containing the samples is indicated by the first argument.

sid = $3
dir = $1
merged = $2

for samples in $1
do
	cat 

