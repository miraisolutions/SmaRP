source(system.file("application", "global.R", package = "SmaRP")) 
context("buildContributionP2Path")

test_that("Test case P2", {
  
  P2 <- buildContributionP2Path(
    birthday = "1975-10-10",
    Salary = 9000000,
    SalaryGrowthRate = 0.01,
    CurrentP2 = 10000,
    P2purchase = 2000,
    TypePurchase = "AnnualP2",
    rate = 0.025,
    givenday = as.Date("2018-07-04"),
    RetirementAge = 67) 
  
  expect_type(P2$AgePath, "integer")
  expect_equal(tail(P2$TotalP2, 1), 61900781, tolerance = 1E-2)
})


