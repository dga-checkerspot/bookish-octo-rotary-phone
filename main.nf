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
