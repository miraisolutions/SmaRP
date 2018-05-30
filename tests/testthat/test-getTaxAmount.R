
source(system.file("application", "global.R", package = "SmaRP"))

context("getTaxAmount")


test_that("Test case Zurich1 (teststhat/resources/testZurich1.pdf)",{
  TaxAmount <- getTaxAmount(Income = 200000,
                            rate_group = "C",
                            postalcode = 8002,
                            Age = 40,
                            NKids = 2,
                            churchtax = "N")

  expect_lt(abs(TaxAmount - 21320) / TaxAmount, 0.05)
})

test_that("Test case Widnau1 (teststhat/resources/testWidnau1.pdf)",{
  TaxAmount <- getTaxAmount(Income = 160000,
                            rate_group = "A",
                            postalcode = 9443,
                            Age = 40,
                            NKids = 0,
                            churchtax = "N")
  
  expect_lt(abs(TaxAmount - 29122) / TaxAmount, 0.05)
})
