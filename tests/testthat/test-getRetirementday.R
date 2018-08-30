context("getRetirementday")

test_that("get date of Retirement", {
  Retirementday <- getRetirementday(birthday = "2000-01-01",
                                    RetirementAge = 65)
  
  expect_equal(Retirementday, as.Date("2065-01-01", format = "%Y-%m-%d"))
})
