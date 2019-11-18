# This script should index the genome file specified in the first argument,
# creating the index in a directory specified by the second argument.

# The STAR command is provided for you. You should replace the parts surrounded by "<>" and uncomment it.

# STAR --runThreadN 4 --runMode genomeGenerate --genomeDir <outdir> --genomeFastaFiles <genomefile> --genomeSAindexNbases 9



echo "Running STAR index..."
mkdir -p res/genome/star_index
STAR --runThreadN 4 --runMode genomeGenerate \
--genomeDir res/genome/star_index/ \
--genomeFastaFiles res/genome/ecoli.fasta \
--genomeSAindexNbases 9

