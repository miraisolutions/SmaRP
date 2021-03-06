% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/core.R
\name{buildContributionP3path}
\alias{buildContributionP3path}
\title{buildContributionP3path}
\usage{
buildContributionP3path(birthday, P3purchase, CurrentP3, returnP3,
  givenday = today("UTC"), RetirementAge)
}
\arguments{
\item{birthday}{Date of birth ("YYYY-MM-DD").}

\item{P3purchase}{Annual voluntary contribution to the Private Fund (3rd Pillar).}

\item{CurrentP3}{Value of the current assets in the Private Fund (3rd Pillar).}

\item{returnP3}{Annual expected return on the Private Fund.}

\item{givenday}{Date at which the age is computed ("YYYY-MM-DD").}

\item{RetirementAge}{Age of retirement.}
}
\value{
All contributions to the 3rd Pillar on an annual basis.
}
\description{
Build the contribution path for a standard pension fund, called 3rd Pillar in Switzerland.
Based on 'calcAnnuityAcumPath()'.
}
\examples{
\dontrun{
buildContributionP3path(
  birthday = "1980-12-01",
  P3purchase = 5000,
  CurrentP3 = 100000,
  returnP3 = 0.03,
  givenday = as.Date("2015-11-30"),
  RetirementAge = 62)
}

}
