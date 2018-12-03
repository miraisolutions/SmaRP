prepare()

context("calcTaxBenefitSwiss")

test_that("Test high income calcTaxBenefitSwiss",{
  
  TaxB <- calcTaxBenefitSwiss(ExpectedSalaryPath = seq(950000, 1100000, 10000),
                              TaxableIncome = seq(930000, 1080000, 10000),
                              rate_group = "A",
                              Age = seq(50, 65),
                              NChildren = 0,
                              postalcode = 8400,
                              churchtax = "Y")
  
  expect_false(any(is.na(TaxB)))
  
})


test_that("Test low income calcTaxBenefitSwiss",{
  
  TaxB <- calcTaxBenefitSwiss(ExpectedSalaryPath = seq(9500, 15000, 500),
                              TaxableIncome = seq(8500, 14000, 500),
                              rate_group = "A",
                              Age = seq(50, 61),
                              NChildren = 0,
                              postalcode = 9000,
                              churchtax = "Y")
  
  expect_false(any(is.na(TaxB)))
  
})