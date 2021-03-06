#' @include structurer-internal.R misc.R generics.R
NULL
 
#' StructureOpts: An S4 class to represent Structure parameters
#'
#' This class stores input parameters for the Structure program.
#'
#' @slot NUMRUNS \code{numeric} Number of replicate Structure runs. Defaults to 2.
#' @slot MAXPOPS \code{numeric} Number of populations assumed. Defaults to 2.
#' @slot BURNIN \code{numeric} Length of burnin period. Defaults to 10000.
#' @slot NUMREPS \code{numeric} Number of MCMC iterations for inference. Defaults to 20000.
#' @slot NOADMIX \code{logical} Do not use admixture model. Defaults to \code{FALSE}.
#' @slot ADMBURNIN \code{numeric} Initial period of burnin with admixture model. Defaults to 500.
#' @slot FREQSCORR \code{logical} Allele frequencies are correlated among populations? Defaults to \code{TRUE}.
#' @slot SEED \code{numeric} Seed for random number generator. Defaults to NA so a random seed is used.
#' @slot UPDATEFREQ \code{numeric} Frequency to store updates to loglikelihood for traceplots. Defaults to 200.
#' @seealso \code{\link{StructureOpts}}.
#' @export
setClass(
	"StructureOpts",
	representation(
		NUMRUNS="numeric",
		MAXPOPS="numeric",
		BURNIN="numeric",
		NUMREPS="numeric",
		NOADMIX="logical",
		ADMBURNIN="numeric",
		FREQSCORR="logical",
		SEED="numeric",
		UPDATEFREQ="numeric"
	),
	prototype=list(
		NUMRUNS=2,
		MAXPOPS=2,
		BURNIN=10000,
		NUMREPS=20000,
		NOADMIX=FALSE,
		ADMBURNIN=5000,
		FREQSCORR=TRUE,
		SEED=NA_real_,
		UPDATEFREQ=200
	),
	validity=function(object) {
		# check that parameters are greater than zero and not NA
		sapply(
			c('MAXPOPS','BURNIN', 'NUMREPS', 'NUMRUNS'),
			function(x) {
				expect_true(is.finite(slot(object, x)))
				expect_true(slot(object, x)>0)
				expect_equal(length(slot(object, x)),1)
				return(invisible())
		})
		# check that all seeds are finite
		expect_true(all(!is.na(object@SEED)))
		# check number of seeds equal to number of runs
		expect_equal(length(object@SEED),object@NUMRUNS)
		# check not NA
		expect_true(!is.na(object@NOADMIX))
		return(TRUE)
	}
)

#' Create StructureOpts object
#'
#' This function creates a new \code{StructureOpts} object.
#'
#' @param NUMRUNS \code{numeric} Number of replicate Structure runs. Defaults to 2.
#' @param MAXPOPS \code{numeric} Number of populations assumed. Defaults to 2.
#' @param BURNIN \code{numeric} Length of burnin period. Defaults to 10000.
#' @param NUMREPS \code{numeric} Number of MCMC iterations for inference. Defaults to 20000.
#' @param NOADMIX \code{logical} Do not use admixture model. Defaults to \code{FALSE}.
#' @param ADMBURNIN \code{numeric} Initial period of burnin with admixture model. Defaults to 500.
#' @param FREQSCORR \code{logical} Allele frequencies are correlated among populations? Defaults to \code{TRUE}.
#' @param SEED \code{numeric} Seed for random number generator. Defaults to NA so a random seed is used.
#' @param UPDATEFREQ \code{numeric} Frequency to store updates to loglikelihood for traceplots. Defaults to yield 1000 frequencies.
#' @seealso \code{\link{StructureOpts-class}}.
#' @examples 
#' StructureOpts(NUMRUNS=2, MAXPOPS=2, BURNIN=10000,
#'   NUMREPS=20000, NOADMIX=FALSE, ADMBURNIN=500, 
#'   FREQSCORR=TRUE, SEED=1:2, UPDATEFREQ=100)
#' @export
StructureOpts<-function(NUMRUNS=2, MAXPOPS=2, BURNIN=10000, NUMREPS=20000, NOADMIX=FALSE, ADMBURNIN=500, FREQSCORR=TRUE, SEED=sample.int(1e5,NUMRUNS), UPDATEFREQ=max(floor(BURNIN+NUMREPS)/1000,1)) {
	x<-new("StructureOpts", NUMRUNS=NUMRUNS, MAXPOPS=MAXPOPS, BURNIN=BURNIN, NUMREPS=NUMREPS, NOADMIX=NOADMIX, ADMBURNIN=ADMBURNIN, FREQSCORR=FREQSCORR, SEED=SEED, UPDATEFREQ=UPDATEFREQ)
	validObject(x, test=FALSE)
	return(x)
}

#' @method print StructureOpts
#' @rdname print
#' @export
print.StructureOpts=function(x, ..., header=TRUE) {
	if (header)
		cat("StructureOpts object.\n")
	cat('  NUMRUNS:',x@NUMRUNS,'\n')
	cat('  MAXPOPS:',x@MAXPOPS,'\n')
	cat('  BURNIN:',x@BURNIN,'\n')
	cat('  NUMREPS:',x@NUMREPS,'\n')
	cat('  NOADMIX:',x@NOADMIX,'\n')
	cat('  ADMBURNIN:',x@ADMBURNIN,'\n')
	cat('  FREQSCORR:',x@FREQSCORR,'\n')
	cat('  UPDATEFREQ:',x@UPDATEFREQ,'\n')
	cat('  SEED:',x@SEED,'\n')
}

#' @rdname n.pop
#' @method n.pop StructureOpts
#' @export
n.pop.StructureOpts <- function(x) {
	return(x@MAXPOPS)
}

#' @rdname show
#' @export
setMethod(
	'show',
	'StructureOpts',
	function(object)
		print.StructureOpts(object)
)

#' Write Structure parameters to file
#'
#' This function writes a \code{StructureOpts} object to file.
#'
#' @param x \code{StructureOpts} object.
#' @param dir \code{character} directory to save files.
#' @seealso \code{\link{StructureOpts}}.
write.StructureOpts <- function(x, dir) {
	# save main params
	cat(paste0('
KEY PARAMETERS FOR THE PROGRAM structure.  YOU WILL NEED TO SET THESE
IN ORDER TO RUN THE PROGRAM.  VARIOUS OPTIONS CAN BE ADJUSTED IN THE
FILE extraparams.


"(int)" means that this takes an integer value.
"(B)"   means that this variable is Boolean 
        (ie insert 1 for True, and 0 for False)
"(str)" means that this is a string (but not enclosed in quotes!) 


Basic Program Parameters

#define MAXPOPS    2      // (int) number of populations assumed
#define BURNIN    ',sprintf('%i',x@BURNIN),'   // (int) length of burnin period
#define NUMREPS   ',sprintf('%i',x@NUMREPS),'   // (int) number of MCMC reps after burnin

Input/Output files

#define INFILE   infile   // (str) name of input data file
#define OUTFILE  outfile  //(str) name of output data file

Data file format

#define NUMINDS    1    // (int) number of diploid individuals in data file
#define NUMLOCI    1    // (int) number of loci in data file
#define PLOIDY       1    // (int) ploidy of data
#define MISSING     -9999    // (int) value given to missing genotype data
#define ONEROWPERIND 0    // (B) store data for individuals in a single line


#define LABEL     1     // (B) Input file contains individual labels
#define POPDATA   0     // (B) Input file contains a population identifier
#define POPFLAG   0     // (B) Input file contains a flag which says whether to use popinfo when USEPOPINFO==1
#define LOCDATA   0     // (B) Input file contains a location identifier

#define PHENOTYPE 0     // (B) Input file contains phenotype information
#define EXTRACOLS 0     // (int) Number of additional columns of data before the genotype data start.

#define MARKERNAMES      1  // (B) data file contains row of marker names
#define RECESSIVEALLELES 1  // (B) data file contains dominant markers (eg AFLPs) and a row to indicate which alleles are recessive
#define MAPDISTANCES     0  // (B) data file contains row of map distances between loci


Advanced data file options

#define PHASED           0 // (B) Data are in correct phase (relevant for linkage model only)
#define PHASEINFO        0 // (B) the data for each individual contains a line indicating phase (linkage model)
#define MARKOVPHASE      0 // (B) the phase info follows a Markov model.
#define NOTAMBIGUOUS  -999 // (int) for use in some analyses of polyploid data

'), sep='', file=file.path(dir, 'mainparams.txt'))

	# save extra params
	cat(paste0(
'

EXTRA PARAMS FOR THE PROGRAM structure.  THESE PARAMETERS CONTROL HOW THE
PROGRAM RUNS.  ATTRIBUTES OF THE DATAFILE AS WELL AS K AND RUNLENGTH ARE 
SPECIFIED IN mainparams.

"(int)" means that this takes an integer value.
"(d)"   means that this is a double (ie, a Real number such as 3.14).
"(B)"   means that this variable is Boolean 
        (ie insert 1 for True, and 0 for False).

PROGRAM OPTIONS

#define NOADMIX     ',as.numeric(x@NOADMIX),' // (B) Use no admixture model (0=admixture model, 1=no-admix)
#define LINKAGE     0 // (B) Use the linkage model
#define USEPOPINFO  0 // (B) Use prior population information to pre-assign individuals to clusters
#define LOCPRIOR    0 //(B)  Use location information to improve weak data

#define FREQSCORR   ',as.numeric(x@FREQSCORR),' // (B) allele frequencies are correlated among pops
#define ONEFST      0 // (B) assume same value of Fst for all subpopulations.

#define INFERALPHA  1 // (B) Infer ALPHA (the admixture parameter)
#define POPALPHAS   0 // (B) Individual alpha for each population
#define ALPHA     1.0 // (d) Dirichlet parameter for degree of admixture (this is the initial value if INFERALPHA==1).

#define INFERLAMBDA 0 // (B) Infer LAMBDA (the allele frequencies parameter)
#define POPSPECIFICLAMBDA 0 //(B) infer a separate lambda for each pop (only if INFERLAMBDA=1).
#define LAMBDA    1.0 // (d) Dirichlet parameter for allele frequencies 

PRIORS

//#define FPRIORMEAN 0.01 // (d) Prior mean and SD of Fst for pops.
// #define FPRIORSD   0.05  // (d) The prior is a Gamma distribution with these parameters

// #define UNIFPRIORALPHA 1 // (B) use a uniform prior for alpha; otherwise gamma prior
// #define ALPHAMAX     10.0 // (d) max value of alpha if uniform prior
// #define ALPHAPRIORA   1.0 // (only if UNIFPRIORALPHA==0): alpha has a gamma prior with mean A*B, and 
// #define ALPHAPRIORB   2.0 // variance A*B^2.  


// #define LOG10RMIN     -4.0   //(d) Log10 of minimum allowed value of r under linkage model
// #define LOG10RMAX      1.0   //(d) Log10 of maximum allowed value of r
// #define LOG10RPROPSD   0.1   //(d) standard deviation of log r in update
// #define LOG10RSTART   -2.0   //(d) initial value of log10 r

                         
USING PRIOR POPULATION INFO (USEPOPINFO)

// #define GENSBACK    2  //(int) For use when inferring whether an individual is an immigrant, or has an immigrant ancestor in the past GENSBACK generations.  eg, if GENSBACK==2, it tests for immigrant ancestry back to grandparents. 
// #define MIGRPRIOR 0.01 //(d) prior prob that an individual is a migrant (used only when USEPOPINFO==1).  This should be small, eg 0.01 or 0.1.
// #define PFROMPOPFLAGONLY 0 // (B) only use individuals with POPFLAG=1 to update P. This is to enable use of a reference set of individuals for clustering additional "test" individuals.

LOCPRIOR MODEL FOR USING LOCATION INFORMATION

#define LOCISPOP      0    //(B) use POPDATA for location information 
#define LOCPRIORINIT  1.0  //(d) initial value for r, the location prior
#define MAXLOCPRIOR  20.0  //(d) max allowed value for r

OUTPUT OPTIONS

#define PRINTNET     0 // (B) Print the "net nucleotide distance" to screen during the run
#define PRINTLAMBDA  0 // (B) Print current value(s) of lambda to screen
#define PRINTQSUM    0 // (B) Print summary of current population membership to screen

#define SITEBYSITE   0  // (B) whether or not to print site by site results. (Linkage model only) This is a large file!
#define PRINTQHAT    0  // (B) Q-hat printed to a separate file.  Turn this on before using STRAT.
#define UPDATEFREQ   ',x@UPDATEFREQ,' // (int) frequency of printing update on the screen. Set automatically if this is 0.
#define PRINTLIKES   0  // (B) print current likelihood to screen every rep
#define INTERMEDSAVE 0  // (int) number of saves to file during run

#define ECHODATA     0  // (B) Print some of data file to screen to check that the data entry is correct. (NEXT 3 ARE FOR COLLECTING DISTRIBUTION OF Q:)
#define ANCESTDIST   0  // (B) collect data about the distribution of ancestry coefficients (Q) for each individual
#define NUMBOXES   1000 // (int) the distribution of Q values is stored as a histogram with this number of boxes. 
#define ANCESTPINT 0.90 // (d) the size of the displayed probability interval on Q (values between 0.0--1.0)

MISCELLANEOUS

#define COMPUTEPROB 1     // (B) Estimate the probability of the Data under the model.  This is used when choosing the best number of subpopulations.
#define ADMBURNIN  ',x@ADMBURNIN,'    // (int) [only relevant for linkage model]: Initial period of burnin with admixture model (see Readme)
#define ALPHAPROPSD 0.025 // (d) SD of proposal for updating alpha
#define STARTATPOPINFO 0  // Use given populations as the initial condition for population origins.  (Need POPDATA==1).  It is assumed that the PopData in the input file are between 1 and k where k<=MAXPOPS.
#define RANDOMIZE    0    // (B) use new random seed for each run 
#define SEED        100  // (int) seed value for random number generator (must set RANDOMIZE=0) 
#define METROFREQ    10   // (int) Frequency of using Metropolis step to update Q under admixture model (ie use the metr. move every i steps).  If this is set to 0, it is never used. (Proposal for each q^(i) sampled from prior.  The goal is to improve mixing for small alpha.)
#define REPORTHITRATE 0 //   (B) report hit rate if using METROFREQ

'), sep='', file=file.path(dir, 'extraparams.txt'))
}



