prepare()

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
    NChildren = 1,
    churchtax = "N",
    rate_group = "A", 
    givenday = as.Date("2018-05-25"), 
    RetirementAge = 65)

  expect_equal(head(TaxB$TotalTax, 1), 0)
  expect_lt(tail(TaxB$TotalTax, 1) - 103263.9, 1E-6)
  expect_equal(nrow(TaxB), 30)
  
  
})

