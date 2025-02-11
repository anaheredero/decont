# This script should merge all files from a given sample (the sample id is provided in the third argument)
# into a single file, which should be stored in the output directory specified by the second argument.
# The directory containing the samples is indicated by the first argument.

#$1 --> dirinput
#$2 --> diroutput
#$3 --> sid

dir=$1
output=$2
sid=$3

mkdir -p out/merged

cat $1/$3*.fastq.gz > $2/$3.merged.fastq.gz
