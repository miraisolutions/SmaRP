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


test_that(paste0("test lookup on kanton taxrate table for Income", Salary, " Kanton ", kanton, " and Civil Status ", rate_group)){
  TaxRate <- lookupTaxRate(Income=Salary, Tabelle, CivilSatus=rate_group)
  expect_equal(TaxRate, 2848.67)
}
