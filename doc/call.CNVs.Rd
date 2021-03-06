\name{call.CNVs}
\alias{call.CNVs}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
  Main CNV calling function of the ExoDepth package 
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
call.CNVs(test, reference, prior = 10^(-4), GC, chromosome, start, end, single.exon.output.file)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{test}{
    Count data for the test sample.
}
\item{reference}{
  Count data for the aggregate reference set.
}
  \item{prior}{
%%     ~~Describe \code{prior} here~~
}
  \item{GC}{
%%     ~~Describe \code{GC} here~~
}
  \item{chromosome}{
%%     ~~Describe \code{chromosome} here~~
}
  \item{start}{
%%     ~~Describe \code{start} here~~
}
  \item{end}{
%%     ~~Describe \code{end} here~~
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
}
\references{
%% ~put references to the literature/web site here ~
}
\author{
%%  ~~who you are~~
}
\note{
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or do  help(data=index)  for the standard data sets.

## The function is currently defined as
function (test, reference, prior = 10^(-4), GC, chromosome, start, end) {
  require(aod)
  
  if (length(test) != length(reference)) stop("Length of test and reference do not match")

  data <- data.frame (test = test, reference = reference, total = test + reference)
  
  if (!missing(GC)) {
    message("GC not missing")
    if ( sum(is.na(GC)) > 0 || (max(GC) > 1) || min(GC) < 0 ) stop("If provided, GC must be between 0 and 1 and have no missing data")
    if (length(GC) != length(test)) stop("Length of GC content do not match")
    data$GC <- GC
    my.formula <- 'cbind(test, reference) ~ GC'
  } else {
    my.formula <- 'cbind(test, reference) ~ 1'
  }

  if (!missing(chromosome)) {
    if (length(chromosome) != length(test))  stop("Length of chromosome vector does not match")
    data$chromosome <- chromosome
  }
  
  if (!missing(start)) {
    if (length(start) != length(test))  stop("Length of chromosome vector does not match")
    data$start <- start
  }
  if (!missing(end)) {
    data$end <- end
    if (length(end) != length(test))  stop("Length of chromosome vector does not match")
  }


  data <- get.likelihood.exodepth (data, formula = my.formula)   ######## estimate the key parameters

  if (!missing(chromosome)) {
    my.breaks <- which(diff(as.numeric(data$chromosome)) != 0) + 1
    data$loglike.del[ my.breaks ] <- - Inf
    data$loglike.dup[ my.breaks ] <- - Inf
  }
  


  proba <- as.matrix(data[, c('loglike', 'loglike.del', 'loglike.dup')])
  transitions <- matrix(nrow = 3, ncol = 3,
                        c( 1. - prior, prior/2., prior/2.,
                          0.5, 0.5, 0.,
                          0.5, 0, 0.5),
                        byrow = TRUE)
  positions <- (data$start + data$end)/2
  my.calls <- viterbi.hmm (transitions, loglikelihood = proba, positions = positions)
  
################ outputs the data
  if (!missing(start)) my.calls$calls$start <- data$start[ my.calls$calls$start.p ] else my.calls$calls$start <- my.calls$calls$start.p
  if (!missing(end)) my.calls$calls$end <- data$end[ my.calls$calls$end.p ] else my.calls$calls$end <-  my.calls$calls$end.p 
  if (!missing(chromosome)) my.calls$calls$chromosome <- data$chromosome[ my.calls$calls$start.p ] else  my.calls$calls$chromosome <- ''
  
  my.calls$calls$id <- paste('chr', my.calls$calls$chromosome, ':',  my.calls$calls$start, '-',  my.calls$calls$end, sep = '')
  my.calls$calls$type <- c('deletion', 'duplication')[ my.calls$calls$type ]
  
########## make things pretty
  my.calls$calls$BF <- NA
  my.calls$calls$reads.expected <- NA
  my.calls$calls$reads.observed <- NA
  
  for (ir in 1:nrow(my.calls$calls)) {
    
    if (my.calls$calls$type[ir] == 'duplication') my.calls$calls$BF[ir] <-  sum(data$loglike.dup [ my.calls$calls$start.p[ir] : my.calls$calls$end.p[ir] ] - data$loglike [ my.calls$calls$start.p[ir] : my.calls$calls$end.p[ir] ])
    
  
    if (my.calls$calls$type[ir] == 'deletion') my.calls$calls$BF[ir] <-  sum(data$loglike.del [ my.calls$calls$start.p[ir] : my.calls$calls$end.p[ir] ] - data$loglike [ my.calls$calls$start.p[ir] : my.calls$calls$end.p[ir] ])
    
    my.calls$calls$reads.expected[ ir ] <-  sum( data$total [my.calls$calls$start.p[ir] : my.calls$calls$end.p[ir] ] * data$expected [my.calls$calls$start.p[ir] : my.calls$calls$end.p[ ir ] ])
    my.calls$calls$reads.observed[ ir ] <-  sum( data$test [my.calls$calls$start.p[ir] : my.calls$calls$end.p[ir] ] )
    
  }

  my.calls$calls$reads.expected <- as.integer( my.calls$calls$reads.expected)
  my.calls$calls$reads.ratio <-  signif(my.calls$calls$reads.observed / my.calls$calls$reads.expected, 3)
  my.calls$calls$BF <- signif( log10(exp(1))*my.calls$calls$BF, 3)
    
  return(my.calls)
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
