\name{get.likelihood.exodepth}
\alias{get.likelihood.exodepth}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
  Auxilliary function for CNV calling in the ExoDepth package to compute
  the likelihood of the read depth data
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
get.likelihood.exodepth(ndata, formula = "cbind(test, reference) ~ 1")
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{ndata}{
%%     ~~Describe \code{ndata} here~~
}
  \item{formula}{
%%     ~~Describe \code{formula} here~~
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
function(ndata, formula = 'cbind(test, reference) ~ 1') {
  require(aod)
  
  for (my.na in c('test', 'reference')) {
    if (! my.na \%in\% names(ndata)) stop("Missing column ", my.na, " in the ndata data.frame")
  }
  
  mod <- betabin( data = ndata, formula = as.formula(formula), random = ~ 1, link = 'logit', hessian = FALSE)
  ndata$expected <- aod::fitted(mod)
  phi <-  mod@param[[ 'phi.(Intercept)']]
  
################################# Now get the matrix of likelihood
  my.likelihood <- .Call("get_loglike_matrix", phi = phi, expected = ndata$expected, total = as.integer(ndata$test + ndata$reference), observed = as.integer(ndata$test), PACKAGE = 'ExoDepth')
  ndata$loglike.del <- my.likelihood[,1]
  ndata$loglike <- my.likelihood[,2]
  ndata$loglike.dup <- my.likelihood[,3]
  ndata$call <- ifelse ( ndata$loglike.del >  ndata$loglike + 3, 'del',  ifelse ( ndata$loglike.dup >  ndata$loglike + 3, 'dup', NA))
  
  return(ndata)
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
