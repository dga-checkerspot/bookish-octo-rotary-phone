#!/usr/bin/env nextflow

params.pacB='s3://wgs.algae.hifi/30-536540905/rawdata/fastX/CHK22.subreads.fastq.gz'



pacb_data = Channel.fromPath(params.pacB)

process correct {
	memory '63G'
	
	input:
	path pacbhifi from pacb_data
	
	output:
	file 'pacb/pacbhifi.correctedReads.fasta.gz' into reads11
	
	"""
	canu -correct -p pacbhifi -d pacb genomeSize=32m corMemory=16 -pacbio $pacbhifi
	"""
}

process trim {
	memory '63G'
	
	input:
	path corrected from reads11
	
	output:
	file 'pacbhifi/pacbhifi.trimmedReads.fasta.gz' into trimfile
	
	"""
	canu -trim -p pacbhifi -d pacbhifi genomeSize=32m -corrected -pacbio $corrected
	"""
}


//split trim into two channels
trimfile.into{trim1; trim3; trim7; trim10}

process assemble1 {
	memory '96G'
	
	input:
	path trimmed from trim1
	
	output:
	file 'pacbhifi/*.fasta' into assembly1
	
	"""
	canu -p pacbhifi3 -d pacbhifi genomeSize=32m correctedErrorRate=0.001 -trimmed -corrected -pacbio $trimmed
	"""
}


process assemble3 {
	memory '63G'
	
	input:
	path trimmed from trim3
	
	output:
	file 'pacbhifi/*.fasta' into assembly3
	
	"""
	canu -p pacbhifi3 -d pacbhifi genomeSize=32m correctedErrorRate=0.0375 -trimmed -corrected -pacbio $trimmed
	"""
}

process assemble7 {
	memory '63G'
	
	input:
	path trimmed from trim7
	
	output:
	file 'pacbhifi/*.fasta' into assembly7
	
	"""
	canu -p pacbhifi7 -d pacbhifi genomeSize=32m correctedErrorRate=0.075 -trimmed -corrected -pacbio $trimmed
	"""
}

process assemble10 {
	memory '63G'
	
	input:
	path trimmed from trim10
	
	output:
	file 'pacbhifi/*.fasta' into assembly10
	
	"""
	canu -p pacbhifi7 -d pacbhifi genomeSize=32m correctedErrorRate=0.10 -trimmed -corrected -pacbio $trimmed
	"""
}








