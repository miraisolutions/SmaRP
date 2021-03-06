% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/core.R
\name{buildContributionP2Path}
\alias{buildContributionP2Path}
\title{buildContributionP2Path}
\usage{
buildContributionP2Path(birthday, Salary, SalaryGrowthRate, CurrentP2,
  P2purchase, TypePurchase, rate = BVGMindestzinssatz,
  givenday = today("UTC"), RetirementAge)
}
\arguments{
\item{birthday}{Date of birth ("YYYY-MM-DD").}

\item{Salary}{Stipend.}

\item{SalaryGrowthRate}{Rate at which the salary increases/decreases.}

\item{CurrentP2}{Value of the current assets in the Occupational Fund.}

\item{P2purchase}{Annual voluntary contribution to the Occupational Fund.}

\item{TypePurchase}{AnnualP2 if the purchase on the second pillar gets repeated every year until retirement.}

\item{rate}{Interests rate on annual basis. Constant interest rates are assumed.}

\item{givenday}{Date at which the age is computed ("YYYY-MM-DD").}

\item{RetirementAge}{Age of retirement.}
}
\value{
All contributions to the 2nd Pillar on an annual basis.
}
\description{
Gather all the required information to project the annual contributions to the occupational fund.
}
\examples{
\dontrun{
buildContributionP2Path(
  birthday = "1975-10-10",
  Salary = 90000,
  SalaryGrowthRate = 0.01,
  CurrentP2 = 10000,
  P2purchase = 2000,
  TypePurchase = "AnnualP2",
  rate = 0.025,
  givenday = as.Date("2018-07-04"),
  RetirementAge = 67)
}
}
