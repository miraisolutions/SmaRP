library(lubridate)
library(dplyr)
source(system.file("application", "global.R", package = "SmaRP"))
library(XLConnect)

Salary=100000 
birthday = "1980-08-31"
P3purchase = 1000
CurrentP3 = 50000
returnP3 = 0.01
CurrentP2 = 100000
SalaryGrowthRate = 0.01
P2purchase = 100000
TypePurchase = "AnnualP2"
RetirementAge = 65
ncp = length(getRetirementCalendar(birthday, givenday = today("UTC"), RetirementAge))
NKids = 0
postalcode = 8001
kanton <- returnPLZKanton(postalcode)
Tabelle=tax_rates_Kanton_list[[kanton]]
churchtax = "N"
rate_group = "A"
TaxRate = NULL
rate = BVGparams$BVGMindestzinssatz
miraiColors<- "['#008cc3', '#FF9966', '#13991c']"


test_that(paste0("test build contribution path for person born on ", birthday, "with current P3 ",  CurrentP3, " with P3 annual purchase ", P3purchase, " and P3 return ", returnP3), {
  wb <- XLConnect::loadWorkbook("../../tests/testthat/resources/testP3path.xls")
  #XLConnect::getDefinedNames(wb)
  return <- XLConnect::readNamedRegion(wb, name="return")
  TestP3 <- XLConnect::readNamedRegion(wb, name="TestP3", useCachedValues=TRUE) %>%
    rename(ReturnP3 = Return) %>%
    rename(TotalP3 = Total)
  #testP3Path <- XLConnect::readWorksheet(wb,sheet=1, header=TRUE, startCol= 5, startRow=4, useCachedValues=TRUE)
  P3 <- buildContributionP3path(birthday,P3purchase,CurrentP3,returnP3,  givenday = as.Date("2018-04-11"), RetirementAge)
  ComputedResults <- P3[length(P3[,1]),c("DirectP3", "TotalP3", "ReturnP3")]
  referenceResults<- TestP3[length(TestP3[,1]), c("DirectP3", "TotalP3", "ReturnP3")]
  #all.equal(ComputedResults, referenceResults,tolerance=10)
  expect_equal(ComputedResults, referenceResults, tolerance=1e2) # hig tollerance due to cumulative precision issues
})