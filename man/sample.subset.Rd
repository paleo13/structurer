% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/generics.R, R/StructureData.R
\name{sample.subset}
\alias{sample.subset}
\alias{sample.subset.StructureData}
\title{Subset samples}
\usage{
sample.subset(x, samples)

\method{sample.subset}{StructureData}(x, samples)
}
\arguments{
\item{x}{\code{StructureData}, \code{StructureAnalysis}.}

\item{samples}{\code{character}, \code{numeric}, or code{logical} indicating the samples to return.}
}
\value{
\code{StructureData}.
}
\description{
This function returns a subset of the sampels in a \code{Structure} object.
}

