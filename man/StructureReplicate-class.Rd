% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/StructureReplicate.R
\docType{class}
\name{StructureReplicate-class}
\alias{StructureReplicate-class}
\title{StructureReplicate: An S4 class to results from Structure}
\description{
This class stores results from the Structure program.
}
\section{Slots}{

\describe{
\item{\code{lnprob}}{\code{numeric} estimated ln probability of the model.}

\item{\code{loglik}}{\code{numeric} mean negative loglikelihood of model.}

\item{\code{var_loglik}}{\code{numeric} variance in negative loglikelihood of model.}

\item{\code{alpha}}{\code{numeric} mean value of alpha.}

\item{\code{matrix}}{\code{matrix} population membership probabilities. Each row is an individual. Each column is for a different population.}

\item{\code{sample.names}}{\code{character} name of samples.}

\item{\code{output}}{\code{character} output file.}

\item{\code{log}}{\code{character} log file.}

\item{\code{mcmc}}{\code{data.frame} MCMC updates during run.}
}}
\seealso{
\code{\link{StructureReplicate}}.
}

