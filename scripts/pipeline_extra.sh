
#Download all the files specified in data/urls
echo "Downloading the sequencing data files..."
sample=${data/*.fastq.gz}
if [ -f $sample ]
then
	echo "These files already exist"
else
	wget -nc -P data -i data/urls
fi

# Download the contaminants fasta file, and uncompress it
echo "Downloading the contaminants database..."
contaminant=res/contaminants.fasta.gz
if [ -f $contaminant ]
then
	echo "$contaminant already exists"
else
	bash scripts/download.sh https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz res yes
fi

# Index the contaminants file
echo "Running index..."
cont_indx=res/contaminants_idx
if [ -d $cont_indx ]
then
	echo "$cont_indx already exists"
else
	bash scripts/index.sh res/contaminants.fasta res/contaminants_idx
fi

# Merge the samples into a single file
echo "Running merged files..."
for sid in $(ls data/*.fastq.gz | cut -d "-" -f1 | sed "s:data/::" | sort | uniq) 
do
	if [ -f out/merged/${sid}.merged.fastq.gz ]
	then
		echo "out/merged/${sid}.merged.fastq.gz already exists"
	else
       		bash scripts/merge_fastqs.sh data out/merged $sid
	fi
done

# Run cutadapt for all merged files
echo "Running cutadapt..."
mkdir -p log/cutadapt
mkdir -p out/trimmed
for sid in $(ls out/merged/*.fastq.gz | cut -d "." -f1 | sed "s:out/merged/::" | sort | uniq)
do
	if [ -f out/trimmed/${sid}.trimmed.fastq.gz ]
       then
               echo "out/trimmed/${sid}.trimmed.fastq.gz already exists"
       else
		cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed  \
		-o out/trimmed/$sid.trimmed.fastq.gz out/merged/$sid.merged.fastq.gz > log/cutadapt/$sid.log
	fi
done


# Run STAR for all trimmed files
echo "Running STAR alignment for all trimmed files..."
for fname in out/trimmed/*.fastq.gz
do
	#you will need to obtain the sample ID from the filename
        sid=$(basename $fname .trimmed.fastq.gz)
        if [ -d out/star/${sid} ]
	then
		echo "out/star/${sid} already exists"
	else
	mkdir -p out/star/${sid}
        STAR --runThreadN 4 --genomeDir res/contaminants_idx \
        --outReadsUnmapped Fastx \
        --readFilesIn out/trimmed/${sid}.trimmed.fastq.gz \
        --readFilesCommand zcat \
        --outFileNamePrefix out/star/${sid}/${sid}.
	fi
done 

# Create a log file containing information from cutadapt and star logs
# (this should be a single log file, and information should be *appended* to it on each run)
# - cutadapt: Reads with adapters and total basepairs
# - star: Percentages of uniquely mapped reads, reads mapped to multiple loci, and to too many lo$

echo "Creating the final report..."
if [ -f log/pipeline.log ]
then
	echo "log/pipeline.log already exists"
else
	for sid in $(ls data/*.fastq.gz | cut -d "-" -f1 | sed "s:data/::" | sort | uniq)
	do
	       	echo "                  ~ ${sid} ~" >> log/pipeline.log
        	echo >> log/pipeline.log
        	cat log/cutadapt/${sid}.log | grep "Reads with adapters:" >> log/pipeline.log
        	cat log/cutadapt/${sid}.log | grep "Total basepairs processed" >> log/pipeline.log
        	cat out/star/${sid}/${sid}.Log.final.out | grep "Uniquely mapped reads %" >> log/pipeline$
        	cat out/star/${sid}/${sid}.Log.final.out | grep "% of reads mapped to multiple loci" >> l$
        	cat out/star/${sid}/${sid}.Log.final.out | grep "% of reads mapped to too many loci" >> l$
        	echo >> log/pipeline.log
	done
fi

