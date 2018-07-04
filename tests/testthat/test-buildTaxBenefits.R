
source(system.file("application", "global.R", package = "SmaRP")) 

context("buildTaxBenefits")

test_that("Test Tax Benefits Zurich",{

  TaxB <- buildTaxBenefits(
    birthday = "1981-08-12",
    TypePurchase = "AnnualP2", 
    P2purchase = 2000, 
    P3purchase = 4000, 
    returnP3 = 0.03, 
    Salary = 800000,
    SalaryGrowthRate = 0.01, 
    postalcode = 8001, 
    NKids = 1,
    churchtax = "N",
    rate_group = "A", 
    givenday = as.Date("2018-05-25"), 
    RetirementAge = 65)


  
})


# Salary=100000 
# birthday = "1981-08-12"
# P3purchase = 10000
# CurrentP3 = 10000
# returnP3 = 0.05
# CurrentP2 = 50000
# SalaryGrowthRate = 0.01
# P2purchase = 2000
# TypePurchase = "AnnualP2"
# RetirementAge = 65
# ncp = length(getRetirementCalendar(birthday, givenday = today("UTC"), RetirementAge))
# NKids = 5
# postalcode = 8400
# kanton <- returnPLZKanton(postalcode)
# Tabelle=tax_rates_Kanton_list[[kanton]]
# churchtax = "N"
# rate_group = "A"
# TaxRate = NULL
# rate = BVGMindestzinssatz
# 
# 
# test_that(paste0("test lookup on kanton taxrate table for Income", Salary, " Kanton ", kanton, " and Civil Status ", rate_group), {
#   TaxRate <- lookupTaxRate(Income=Salary, Tabelle, CivilStatus=rate_group)
#   expect_equal(TaxRate, 2848.67, tolerance=1e-3)
# })
# 
# 
# test_that(paste0("test the TaxBenefit"), {
#   TaxBenefitsPath <- data.frame(calendar = getRetirementCalendar(birthday, givenday = today("UTC"), RetirementAge = RetirementAge ))
#   ncp <- nrow(TaxBenefitsPath) 
#   TaxBenefitsPath %<>% within({
#     BVGpurchase = calcBVGpurchase(TypePurchase, P2purchase, ncp)
#     P3purchase = rep(P3purchase, ncp)
#     TotalContr = BVGpurchase + P3purchase
#     ExpectedSalaryPath = calcExpectedSalaryPath(Salary, SalaryGrowthRate, ncp)
#     TaxableIncome = pmax(ExpectedSalaryPath - pmin(TotalContr, MaxContrTax),0)
#   })
#   TaxBenefit <- calcTaxBenefitSwiss(TaxBenefitsPath$ExpectedSalaryPath, TaxBenefitsPath$TaxableIncome, postalcode, NKids, churchtax, rate_group, tax_rates_Kanton_list, BundessteueTabelle, PLZGemeinden)
#   TaxBenefit_ref <- readRDS("../../tests/testthat/resources/TaxBenefit.rds")
#   expect_equal(TaxBenefit, TaxBenefit_ref, tolerance=1e-3)
# })
