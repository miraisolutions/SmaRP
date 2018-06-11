
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
  expect_lt(abs(TaxAmount - 21320) / 200000, 0.005)
})

test_that("Test case St.Gallen1 (teststhat/resources/testStGallen1.pdf)",{
  TaxAmount <- getTaxAmount(Income = 150000,
                            rate_group = "A",
                            postalcode = 9000,
                            Age = 40,
                            NKids = 0,
                            churchtax = "N")
  
  expect_lt(abs(TaxAmount - 30779) / TaxAmount, 0.05)
  expect_lt(abs(TaxAmount - 30779) / 150000, 0.005)
})

test_that("Test case Bern1 (teststhat/resources/testStBern1.pdf)",{
  TaxAmount <- getTaxAmount(Income = 124000,
                            rate_group = "C",
                            postalcode = 3010,
                            Age = 32,
                            NKids = 3,
                            churchtax = "Y")
  
  expect_lt(abs(TaxAmount - 10308) / TaxAmount, 0.05)
  expect_lt(abs(TaxAmount - 10308) / 124000, 0.005)
})

test_that("Test case Luzern1 (teststhat/resources/testLuzern1.pdf)",{
  TaxAmount <- getTaxAmount(Income = 65000,
                            rate_group = "B",
                            postalcode = 6003,
                            Age = 27,
                            NKids = 0,
                            churchtax = "N")
  
  expect_lt(abs(TaxAmount - 4188) / TaxAmount, 0.05)
  expect_lt(abs(TaxAmount - 4188) / 65000, 0.005)
})

test_that("Test case Geneve1 (teststhat/resources/testGeneve1.pdf)",{
  TaxAmount <- getTaxAmount(Income = 110000,
                            rate_group = "B",
                            postalcode = 1208,
                            Age = 40,
                            NKids = 2,
                            churchtax = "Y")
  
  expect_lt(abs(TaxAmount - 4116) / TaxAmount, 0.05)
  expect_lt(abs(TaxAmount - 4116) / 110000, 0.005)
})

test_that("Test case Zug1 (teststhat/resources/testZug1.pdf)",{
  TaxAmount <- getTaxAmount(Income = 280000,
                            rate_group = "C",
                            postalcode = 6340,
                            Age = 50,
                            NKids = 1,
                            churchtax = "Y")
  
  expect_lt(abs(TaxAmount - 4116) / TaxAmount, 0.05)
  expect_lt(abs(TaxAmount - 4116) / 110000, 0.005)
})


