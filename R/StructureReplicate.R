#' @include structurer-internal.R misc.R generics.R
NULL
 
#' StructureReplicate: An S4 class to results from Structure
#'
#' This class stores results from the Structure program.
#'
#' @slot lnprob \code{numeric} estimated ln probability of the model.
#' @slot loglik \code{numeric} mean negative loglikelihood of model.
#' @slot var_loglik \code{numeric} variance in negative loglikelihood of model.
#' @slot alpha \code{numeric} mean value of alpha.
#' @slot matrix \code{matrix} population membership probabilities. Each row is an individual. Each column is for a different population.
#' @slot sample.names \code{character} name of samples.
#' @slot output \code{character} output file.
#' @slot log \code{character} log file.
#' @slot mcmc \code{data.frame} MCMC updates during run.
#' @seealso \code{\link{StructureReplicate}}.
#' @export
setClass(
	"StructureReplicate",
	representation(
		lnprob='numeric',
		loglik='numeric',
		var_loglik='numeric',
		alpha='numeric',
		matrix='matrix',
		sample.names='character',
		output='character',
		log='character',
		mcmc='data.frame'
	),
	validity=function(object) {
		# check slots are finite
		sapply(c('lnprob', 'loglik', 'var_loglik'),
			function(x) {
				expect_true(is.finite(slot(object, x)))
			}
		)
		# check dimensions of matrix match log file
		pars <- gsub(' ', '', gsub(',', '', strsplit(grep('NUMINDS', object@output, value=TRUE),'\t')[[1]], fixed=TRUE))
		n.inds <- as.numeric(gsub('NUMINDS=', '', grep('NUMINDS', pars, fixed=TRUE, value=TRUE), fixed=TRUE))
		n.pop <- as.numeric(gsub('MAXPOPS=', '', grep('MAXPOPS', pars, fixed=TRUE, value=TRUE), fixed=TRUE))
		expect_equal(ncol(object@matrix), n.pop)
		expect_equal(nrow(object@matrix), n.inds)
		expect_equal(nrow(object@matrix), length(object@sample.names))
		return(TRUE)
	}
)

#' Create StructureReplicate object
#'
#' This function creates a new \code{StructureReplicate} object.
#'
#' @param lnprob \code{numeric} estimated ln probability of the model.
#' @param loglik \code{numeric} mean negative loglikelihood of model.
#' @param var_loglik \code{numeric} variance in negative loglikelihood of model.
#' @param alpha \code{numeric} mean value of alpha.
#' @param matrix \code{matrix} population membership probabilities. Each row is an individual. Each column is for a different population.
#' @param sample.names \code{character} name of samples.
#' @param output \code{character} output file.
#' @param log \code{character} log file.
#' @param mcmc \code{data.frame} MCMC updates during run.
#' @seealso \code{\link{StructureReplicate-class}}.
#' @return \code{\link{StructureReplicate}}.
#' @export
StructureReplicate<-function(lnprob, loglik, var_loglik, alpha, matrix, sample.names, output, log, mcmc) {
	x<-new("StructureReplicate", lnprob=lnprob, loglik=loglik, var_loglik=var_loglik, alpha=alpha, matrix=matrix, sample.names=sample.names, output=output, log=log, mcmc=mcmc)
	validObject(x, test=FALSE)
	return(x)
}

#' @rdname n.pop
#' @method n.pop StructureReplicate
#' @export
n.pop.StructureReplicate <- function(x) {
	return(ncol(x@matrix))
}

#' @rdname n.samples
#' @method n.samples StructureReplicate
#' @export
n.samples.StructureReplicate <- function(x) {
	return(nrow(x@matrix))
}

#' @rdname sample.names
#' @method sample.names StructureReplicate
#' @export
sample.names.StructureReplicate <- function(x) {
	return(x@sample.names)
}

#' @rdname sample.membership
#' @method sample.membership StructureReplicate
sample.membership.StructureReplicate <- function(x) {
	return(apply(x@matrix, 1, which.max))
}

#' @rdname logLik
#' @method logLik StructureReplicate
logLik.StructureReplicate <- function(object, ...) {
	return(object@loglik)
}

#' @rdname lnprob
#' @method lnprob StructureReplicate
lnprob.StructureReplicate <- function(x, ...) {
	return(x@lnprob)
}

#' Read Structure run
#'
#' This function reads the results of a single run of the Structure program.
#'
#' @param file \code{character} file path of output file.
#' @param runfile \code{character} file path of file text printed to console during run.
#' @seealso \code{\link{StructureReplicate-class}}.
#' @return \code{\link{StructureReplicate}}.
#' @export
read.StructureReplicate <- function(file, runfile) {
	# load file
	outputfile <- suppressWarnings(readLines(file))
	runfile <- suppressWarnings(readLines(runfile))
	# load matrix
	pars <- gsub(' ', '', gsub(',', '', strsplit(grep('NUMINDS', outputfile, value=TRUE),'\t')[[1]], fixed=TRUE))
	n.inds <- as.numeric(gsub('NUMINDS=', '', grep('NUMINDS', pars, fixed=TRUE, value=TRUE), fixed=TRUE))
	start.line <- grep('Inferred ancestry of individuals', outputfile, fixed=TRUE)+1
	mat <- fread(file, skip=start.line, nrows=n.inds, data.table=FALSE)
	# load alpha
	alpha <-as.numeric(gsub('Mean value of alpha         = ', '', grep('Mean value of alpha', outputfile, fixed=TRUE, value=TRUE), fixed=TRUE)) 
	if (length(alpha)==0)
		alpha <- NA_real_
	# parse mcmc matrix
	mcmc.matrix <- runfile[seq(grep('Rep#', runfile, fixed=TRUE)[1], grep('MCMC completed', runfile, fixed=TRUE)[1])]
	mcmc.matrix <- mcmc.matrix[!grepl('Alpha',mcmc.matrix,fixed=TRUE)]
	mcmc.matrix <- mcmc.matrix[!grepl('BURNIN',mcmc.matrix,fixed=TRUE)]
	mcmc.matrix <- mcmc.matrix[!grepl('Burnin',mcmc.matrix,fixed=TRUE)]
	mcmc.matrix <- mcmc.matrix[!grepl('completed',mcmc.matrix,fixed=TRUE)]
	mcmc.matrix <- mcmc.matrix[!grepl('Rep',mcmc.matrix,fixed=TRUE)]
	mcmc.matrix <- mcmc.matrix[which(nchar(mcmc.matrix)>0)]
	mcmc.matrix <- gsub(':', ' ', mcmc.matrix, fixed=TRUE)
	mcmc.matrix <- fread(paste(mcmc.matrix, collapse='\n'), sep=' ', header=FALSE, data.table=FALSE)
	# parse mcmc matrix column names
	mcmc.colnames <- grep('Est Ln', runfile, fixed=TRUE, value=TRUE)[1]
	mcmc.colnames <- gsub('#', '', mcmc.colnames, fixed=TRUE)
	mcmc.colnames <- gsub(':', '', mcmc.colnames, fixed=TRUE)
	mcmc.colnames <- gsub('(', '', mcmc.colnames, fixed=TRUE)
	mcmc.colnames <- gsub(')', '', mcmc.colnames, fixed=TRUE)
	mcmc.colnames <- strsplit(mcmc.colnames, '  ')
	mcmc.colnames <- sapply(mcmc.colnames, trimws)
	mcmc.colnames <- mcmc.colnames[which(nchar(mcmc.colnames)>0)]
	mcmc.colnames <- gsub(' ', '.', mcmc.colnames, fixed=TRUE)
	names(mcmc.matrix) <- mcmc.colnames
	# return object
	StructureReplicate(
		lnprob=as.numeric(gsub('Estimated Ln Prob of Data   = ', '', grep('Estimated Ln Prob of Data', outputfile, fixed=TRUE, value=TRUE), fixed=TRUE)),
		loglik=as.numeric(gsub('Mean value of ln likelihood = ', '', grep('Mean value of ln likelihood', outputfile, fixed=TRUE, value=TRUE), fixed=TRUE)),
		var_loglik=as.numeric(gsub('Variance of ln likelihood   = ', '', grep('Variance of ln likelihood', outputfile, fixed=TRUE, value=TRUE), fixed=TRUE)),
		alpha=alpha,
		matrix=as.matrix(mat[,c(-1, -2, -3, -4),drop=FALSE]),
		sample.names=as.character(mat[[2]]),
		output=outputfile,
		log=runfile,
		mcmc=mcmc.matrix
	)
}

#' @method print StructureReplicate
#' @rdname print
#' @export
print.StructureReplicate=function(x, ..., header=TRUE) {
	if (header)
		cat("StructureReplicate object.\n")
	cat('  K:',n.pop(x),'\n')
	cat('  lnprob:',lnprob(x),'\n')
}

#' @rdname show
#' @export
setMethod(
	'show',
	'StructureReplicate',
	function(object)
		print.StructureReplicate(object)
)

