% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/generics.R, R/StructureReplicate.R, R/StructureResults.R, R/StructureData.R, R/StructureAnalysis.R, R/StructureCollection.R
\name{n.samples}
\alias{n.samples}
\alias{n.samples.StructureAnalysis}
\alias{n.samples.StructureCollection}
\alias{n.samples.StructureData}
\alias{n.samples.StructureReplicate}
\alias{n.samples.StructureResults}
\title{Number of samples}
\usage{
n.samples(x)

\method{n.samples}{StructureReplicate}(x)

\method{n.samples}{StructureResults}(x)

\method{n.samples}{StructureData}(x)

\method{n.samples}{StructureAnalysis}(x)

\method{n.samples}{StructureCollection}(x)
}
\arguments{
\item{x}{\code{StructureData}, \code{StructureAnalysis}.}
}
\value{
\code{integer}.
}
\description{
This function returns the number of samples in a \code{Structure} object.
}

