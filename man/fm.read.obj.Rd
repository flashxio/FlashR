% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/FlashR.R
\name{fm.read.obj}
\alias{fm.read.obj}
\title{Read a FlashR object (vector/matrix) from a file.}
\usage{
fm.read.obj(file)
}
\arguments{
\item{file}{a file in the local filesystem.}
}
\value{
a FlashR object (vector/matrix)
}
\description{
Read a FlashR object (vector/matrix) from a file.
}
\examples{
mat <- fm.read.obj("/tmp/tmp.mat")
}
\author{
Da Zheng <dzheng5@jhu.edu>
}

