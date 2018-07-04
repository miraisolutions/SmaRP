source(system.file("application", "global.R", package = "SmaRP"))

context("buildContributionP3path")

test_that("Test case P3 (teststhat/resources/tesstP3path.xls)", {
  
  birthday = "1980-08-31"
  P3purchase = 1000
  CurrentP3 = 50000
  returnP3 = 0.01
  RetirementAge = 65
                   
  P3 <- buildContributionP3path(birthday, P3purchase, CurrentP3, returnP3, givenday = as.Date("2018-04-11"), RetirementAge) 

  expect_equal(tail(P3$TotalP3, 1), 96921.06, tolerance = 1E-2)
  expect_equal(tail(P3$DirectP3, 1), 77000, tolerance = 1E-2)
  expect_equal(tail(P3$ReturnP3, 1), 19921.06, tolerance = 1E-2)
})