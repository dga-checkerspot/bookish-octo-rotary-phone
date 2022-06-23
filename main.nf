#!/usr/bin/env nextflow

params.pacB='s3://pipe.scratch.3/resources/hic/CHK*fastq.gz'



pacb_data = Channel.fromPath(params.pacB)

process correct {
	memory '63G'
	errorStrategy 'retry'
	
	input:
	path pacbhifi from pacb_data
	
	output:
	file "pacb/${pacbhifi.baseName}.correctedReads.fasta.gz" into reads11
	
	"""
	canu -correct -p ${pacbhifi.baseName} -d pacb genomeSize=32m corMemory=16 -pacbio $pacbhifi
	"""
}

process trim {
	memory '63G'
	errorStrategy 'retry'
	
	input:
	path corrected from reads11
	
	output:
	file "pacbhifi/${corrected.baseName}.trimmedReads.fasta.gz" into trimfile
	
	"""
	canu -trim -p ${corrected.baseName} -d pacbhifi genomeSize=32m -corrected -pacbio $corrected
	"""
}


//split trim into two channels
trimfile.into{trim1; trim3; trim7; trim10; trimOut}

/*
process assemble1 {
	memory '96G'
	errorStrategy 'retry'
	
	input:
	path trimmed from trim1
	
	output:
	file "pacbhifi/*.fasta" into assembly1
	
	"""
	canu -p "${trimmed.baseName}_1" -d pacbhifi genomeSize=32m correctedErrorRate=0.001 -trimmed -corrected -pacbio $trimmed
	"""
}
*/

process assemble3 {
	memory '63G'
	errorStrategy 'retry'
	
	input:
	path trimmed from trim3
	
	output:
	file "pacbhifi/*.fasta" into assembly3
	
	"""
	canu -p "${trimmed.baseName}_3" -d pacbhifi genomeSize=32m correctedErrorRate=0.0375 -trimmed -corrected -pacbio $trimmed
	"""
}

/*
process assemble7 {
	memory '63G'
	errorStrategy 'retry'
	
	input:
	path trimmed from trim7
	
	output:
	file "pacbhifi/*.fasta" into assembly7
	
	"""
	canu -p "${trimmed.baseName}_7" -d pacbhifi genomeSize=32m correctedErrorRate=0.075 -trimmed -corrected -pacbio $trimmed
	"""
}


process assemble10 {
	memory '63G'
	errorStrategy 'retry'
	
	input:
	path trimmed from trim10
	
	output:
	file "pacbhifi/*.fasta" into assembly10
	
	"""
	canu -p "${trimmed.baseName}_10" -d pacbhifi genomeSize=32m correctedErrorRate=0.10 -trimmed -corrected -pacbio $trimmed
	"""
}
*/


//Create a directory for output and drop assemblies and trimmed files into it
params.results = "s3://pipe.scratch.3/resources/CanuOut/"

myDir = file(params.results)

trimOut.subscribe { it.copyTo(myDir) }
assembly3.subscribe { it.copyTo(myDir) }




