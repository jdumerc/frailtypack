% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/summary.jointSurroPenalSimul.R
\name{summary.jointSurroPenalSimul}
\alias{summary.jointSurroPenalSimul}
\alias{print.summary.jointSurroPenalSimul}
\title{Short summary of the simulation studies based on a joint surrogate model}
\usage{
\method{summary}{jointSurroPenalSimul}(object, d = 3, R2boot = 0,  ...)
}
\arguments{
\item{object}{an object inheriting from \code{jointSurroPenalSimul} class.}

\item{d}{The desired number of digits after the decimal point f. Default of 3}

\item{R2boot}{A binary that specifies whether the confidence interval of \eqn{R^2_{trial}} 
should be computed using parametric bootstrap (\code{1}) or Delta-method (\code{0}). 
The default is \code{0}}

\item{\dots}{other unused arguments.}
}
\value{
For each parameter of the joint surrogate model , we print the true simulation value,  
the empirical standard error (empirical SE), the mean of the estimated standard errors 
(Mean SE), and the coverate probability (CP) for each model parameters. 
For the Kendall's \eqn{\tau}, the 95\% Confidence interval is obtained by the 
parametric bootstrap. For \eqn{R^2_{trial}}(R2trial), the standard error is obtained
by Delta-method and the 95\% Confidence interval could be obtained directly or by 
parametric bootstrap. We also display the total number of non convergence case with 
the associated percentage (R : n(\%)), the mean number of iterations to reach convergence,
and other estimation and simulation parameters
.
}
\description{
This function returns the true value, the mean of the estimates, 
the empirical standard error, the mean of the estimated standard errors 
(Mean SE), and the coverage probability for model parameters
}
\examples{

# Studies simulation
\dontrun{
# (Computation takes around 45 minutes using a processor including 40
# cores and a read only memory of 378 Go)
joint.simul <- jointSurroPenalSimul(nb.dataset = 10, nbSubSimul=600, 
                   ntrialSimul=30, LIMparam = 0.001, LIMlogl = 0.001, 
                   LIMderiv = 0.001, nb.mc = 200, nb.gh = 20, 
                   nb.gh2 = 32, true.init.val = 1, print.iter=F)

# results
summary(joint.simul, d = 3, R2boot = 1) # bootstrap
summary(joint.simul, d = 3, R2boot = 0) # Delta-method

}


}
\seealso{
\code{\link{jointSurroPenalSimul}}
}
\author{
Casimir Ledoux Sofeu \email{casimir.sofeu@u-bordeaux.fr}, \email{scl.ledoux@gmail.com} and 
Virginie Rondeau \email{virginie.rondeau@inserm.fr}
}
\keyword{methods}
