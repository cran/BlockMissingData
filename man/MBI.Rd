% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/MBI.R
\name{MBI}
\alias{MBI}
\title{Variable selection method with multiple block-wise imputation (MBI)}
\usage{
MBI(
  X,
  y,
  cov_index,
  sub_index,
  miss_source,
  complete,
  lambda = NULL,
  eps1 = 0.001,
  eps2 = 1e-07,
  eps3 = 1e-08,
  max.iter = 1000,
  lambda.min = ifelse(n > p, 0.001, 0.05),
  nlam = 100,
  beta0 = NULL,
  a = 3.7,
  gamma.ebic = 0.5,
  alpha1 = 0.5^(0:12),
  h1 = 2^(-(8:30)),
  ratio = 1
)
}
\arguments{
\item{X}{Design matrix for block-wise missing covariates.}

\item{y}{Response vector.}

\item{cov_index}{Starting indexes of covariates in data sources.}

\item{sub_index}{Starting indexes of subjects in missing groups.}

\item{miss_source}{Indexes of missing data sources in missing groups, respectively ('NULL' represents no missing).}

\item{complete}{Logical indicator of whether there is a group of complete cases. If there is a group of complete cases,
it should be the first group. 'TRUE' represents that there is a group of complete cases.}

\item{lambda}{A user supplied sequence of tuning parameter in penalty. If NULL, a sequence is automatically generated.}

\item{eps1}{Convergence threshold at certain stage of the algorithm. Default is 1e-3.}

\item{eps2}{Convergence threshold at certain stage of the algorithm. Default is 1e-7.}

\item{eps3}{Convergence threshold at certain stage of the algorithm. Default is 1e-8.}

\item{max.iter}{The maximum number of iterations allowed. Default is 1000.}

\item{lambda.min}{Smallest value for \code{lambda}, as a fraction of the maximum value in \code{lambda}. Default depends on the size of input.}

\item{nlam}{The number of \code{lambda} values. Default is 100.}

\item{beta0}{Initial value for regression coefficients. If NULL, they are initialized automatically.}

\item{a}{Tuning parameter in the SCAD penalty. Default is 3.7.}

\item{gamma.ebic}{Parameter in the EBIC criterion. Default is 0.5.}

\item{alpha1}{A sequence of candidate values for the step size in the conjugate gradient algorithm. Default is 0.5^(0:12).}

\item{h1}{A sequence of candidate values for the parameter in the numerical calculation of the first derivative of the objective function. Default is 2^(-(8:30)).}

\item{ratio}{Parameter in the numerical calculation of the first derivative. Default is 1.}
}
\value{
\item{beta}{Estimated coefficients matrix with \code{length(lambda)} rows and \code{dim(X)[2]} columns.}
\item{lambda}{The actual sequence of \code{lambda} values used.}
\item{bic1}{BIC criterion values. '0' should be ignored.}
\item{notcon}{Value indicating whether the algorithm is converged or not. '0' represents convergence; otherwise non-convergence.}
\item{intercept}{Intercept sequence of length \code{length(lambda)}.}
\item{beta0}{Estimated coefficients matrix for standardized \code{X}}
}
\description{
Fit a variable selection method with multiple block-wise imputation (MBI).
}
\details{
The function uses the penalized generalized method of moments with multiple block-wise imputation to handle block-wise missing data, commonly found in multi-source datasets.
}
\examples{

library(MASS)

# Number of subjects
n <- 30

# Number of total covariates
p <- 4

# Number of missing groups of subjects
ngroup <- 2

# Number of data sources
nsource <- 2

# Starting indexes of covariates in data sources
cov_index=c(1, 3)

# Starting indexes of subjects in missing groups
sub_index=c(1, 16)

# Indexes of missing data sources in missing groups, respectively ('NULL' represents no missing)
miss_source=list(NULL, 1)

# Indicator of whether there is a group of complete cases. If there is a group of complete cases,
# it should be the first group.
complete=TRUE

# Create a block-wise missing design matrix X and response vector y
set.seed(1)
sigma=diag(1-0.4,p,p)+matrix(0.4,p,p)
X <- mvrnorm(n,rep(0,p),sigma)
beta_true <- c(2.5, 0, 3, 0)
y <- rnorm(n) + X\%*\%beta_true

for (i in 1:ngroup) {
  if (!is.null(miss_source[[i]])) {
    if (i==ngroup) {
      if (miss_source[[i]]==nsource) {
        X[sub_index[i]:n, cov_index[miss_source[[i]]]:p] = NA
      } else {
        X[sub_index[i]:n, cov_index[miss_source[[i]]]:(cov_index[miss_source[[i]]+1]-1)] = NA
      }
    } else {
      if (miss_source[[i]]==nsource) {
        X[sub_index[i]:(sub_index[i+1]-1), cov_index[miss_source[[i]]]:p] = NA
      } else {
        X[sub_index[i]:(sub_index[i+1]-1), cov_index[miss_source[[i]]]:
        (cov_index[miss_source[[i]]+1]-1)] = NA
      }
    }
  }
}

# Now we can use the function with this simulated data
#start.time = proc.time()
result <- MBI(X=X, y=y, cov_index=cov_index, sub_index=sub_index, miss_source=miss_source,
complete=complete, nlam = 15, eps2 = 1e-3, h1=2^(-(8:20)))
#time = proc.time() - start.time

theta=result$beta
bic1=result$bic1
best=which.min(bic1[bic1!=0])
beta_est=theta[best,]


}
\references{
Xue, F., and Qu, A. (2021)
\emph{Integrating Multisource Block-Wise Missing Data in Model Selection (2021), Journal of the American Statistical Association, Vol. 116(536), 1914-1927}.
}
\author{
Fei Xue and Annie Qu
}
