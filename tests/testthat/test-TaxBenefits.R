library(lubridate)
source(system.file("application", "global.R", package = "SmaRP")) 
#test functions for TaxBenefits

Salary=100000 
birthday = "1981-08-12"
P3purchase = 10000
CurrentP3 = 10000
returnP3 = 0.05
CurrentP2 = 50000
SalaryGrowthRate = 0.01
P2purchase = 2000
TypePurchase = "AnnualP2"
RetirementAge = 65
ncp = length(getRetirementCalendar(birthday, givenday = today("UTC"), RetirementAge))
NKids = 5
postalcode = 8400
kanton <- returnPLZKanton(postalcode)
Tabelle=tax_rates_Kanton_list[[kanton]]
churchtax = "N"
rate_group = "A"
TaxRate = NULL
rate = BVGparams$BVGMindestzinssatz


test_that(paste0("test lookup on kanton taxrate table for Income", Salary, " Kanton ", kanton, " and Civil Status ", rate_group), {
  TaxRate <- lookupTaxRate(Income=Salary, Tabelle, CivilSatus=rate_group)
  expect_equal(TaxRate, 2848.67, tolerance=1e-3)
})

test_that(paste0("test tax amount for Income", Salary, " postalcode ", postalcode, " NKids ", NKids, " churchtax ", churchtax, " rate_group ", rate_group),{
  TaxAmount <- getTaxAmount(Income=Salary, postalcode, NKids, churchtax, rate_group, tax_rates_Kanton_list, BundessteueTabelle, PLZGemeinden)
  expect_equal(TaxAmount, 7832.257, tolerance=1e-3)
})

test_that(paste0("test the TaxBenefit"), {
  TaxBenefitsPath <- data.frame(calendar = getRetirementCalendar(birthday, givenday = today("UTC"), RetirementAge = RetirementAge ))
  ncp <- nrow(TaxBenefitsPath) 
  TaxBenefitsPath %<>% within({
    BVGpurchase = calcBVGpurchase(TypePurchase, P2purchase, ncp)
    P3purchase = rep(P3purchase, ncp)
    TotalContr = BVGpurchase + P3purchase
    ExpectedSalaryPath = calcExpectedSalaryPath(Salary, SalaryGrowthRate, ncp)
    TaxableIncome = pmax(ExpectedSalaryPath - pmin(TotalContr, MaxContrTax),0)
  })
  TaxBenefit <- calcTaxBenefitSwiss(TaxBenefitsPath$ExpectedSalaryPath, TaxBenefitsPath$TaxableIncome, postalcode, NKids, churchtax, rate_group, tax_rates_Kanton_list, BundessteueTabelle, PLZGemeinden)
  TaxBenefit_ref <- readRDS("../../tests/testthat/resources/TaxBenefit.rds")
  expect_equal(TaxBenefit, TaxBenefit_ref, tolerance=1e-3)
})
