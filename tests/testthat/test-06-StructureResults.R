test_that('StructureResults', {
	# create data
	dir<-tempdir()
	so <- StructureOpts(MAXPOPS=2, BURNIN=10, NUMREPS=10, NOADMIX=FALSE, ADMBURNIN=10, SEED=NA_real_)
	write.StructureOpts(so,dir)
	sd <- read.StructureData(system.file('extdata', 'example_fstat_aflp.dat', package='structurer'))
	sample.names(sd) <- as.character(seq_len(n.samples(sd)))
	write.StructureData(sd,file.path(dir, 'data.txt'))
	# identify bayescan path
	structure.path <- switch(
		Sys.info()['sysname'],
		'Linux'=system.file('bin', 'structure_linux', package='structurer'),
		'Darwin'=system.file('bin', 'structure_mac', package='structurer'),
		'Windows'=system.file('bin', 'structure_win.exe', package='structurer')
	)
	# update permissions
	if (!grepl(basename(structure.path), 'win'))
		system(paste0('chmod 700 ',structure.path))
	# run BayeScan
	system(paste0(structure.path, ' ', ' -m ',file.path(dir, 'mainparams.txt'),' -e ',file.path(dir, 'extraparams.txt'),' -K ',2,' -L ',n.loci(sd),' -N ',n.samples(sd),' -i ',file.path(dir, 'data.txt'),' -o ',file.path(dir, 'output.txt')))
	# try reading results back into R
	results <- StructureResults(replicates=list(read.StructureReplicate(file.path(dir, 'output.txt_f'))))
	# methods
	print(results)
	results
	n.pop(results)
	n.samples(results)
	loglik(results)
	sample.membership(results)
	sample.names(results)
})