% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ClumppOpts.R
\name{ClumppOpts}
\alias{ClumppOpts}
\title{Create ClumppOpts object}
\usage{
ClumppOpts(M = "Greedy", W = TRUE, S = FALSE, REPEATS = 1000)
}
\arguments{
\item{M}{\code{character} name of search method. Valid arguments are 'FullSearch', 'Greedy', or 'LargeKGreedy'. Defaults to 'Greedy'.}

\item{W}{\code{logical} weight populations by number of individuals? Defaults to \code{TRUE}.}

\item{S}{\code{logical} if \code{TRUE} the \eqn{G} matrix similarity statistic used used. Else the \eqn{G \prime} statistic is used. Defaults to code{FALSE}.}

\item{REPEATS}{\code{numeric} Number of random input orders tested. Defaults to 1000.}
}
\description{
This function creates a new \code{ClumppOpts} object.
}
\examples{
ClumppOpts(M='Greedy', W=TRUE, S=FALSE, REPEATS=1000)
}
\seealso{
\code{\link{ClumppOpts-class}}.
}

