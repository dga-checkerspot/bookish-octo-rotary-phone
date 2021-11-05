#!/usr/bin/env nextflow

sequences1='s3://wgs.algae.hifi/pacb.fq.gz'

process correct {
	memory '96G'
	
	input:
	path pacbhifi from sequences1
	
	output:
	file 'pacb/pacbhifi.correctedReads.fasta.gz' into reads11
	
	"""
	canu -correct -p pacbhifi -d pacb genomeSize=32m -pacbio $pacbhifi
	"""
}

process trim {
	memory '96G'
	
	input:
	path corrected from reads11
	
	output:
	file 'pacbhifi/pacbhifi.trimmedReads.fasta.gz' into trimfile
	
	"""
	canu -trim -p pacbhifi -d pacbhifi genomeSize=32m -corrected -pacbio $corrected
	"""
}


//split trim into two channels
trimfile.into{trim3; trim7}

process assemble3 {
	memory '96G'
	
	input:
	path trimmed from trim3
	
	output:
	file 'pacbhifi/*.fasta' into assembly3
	
	"""
	canu -p pacbhifi3 -d pacbhifi genomeSize=32m correctedErrorRate=0.0375 -trimmed -corrected -pacbio $trimmed
	"""
}

process assemble7 {
	memory '96G'
	
	input:
	path trimmed from trim7
	
	output:
	file 'pacbhifi/*.fasta' into assembly7
	
	"""
	canu -p pacbhifi7 -d pacbhifi genomeSize=32m correctedErrorRate=0.075 -trimmed -corrected -pacbio $trimmed
	"""
}












