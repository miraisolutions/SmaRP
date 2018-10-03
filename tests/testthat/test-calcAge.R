context("calcAge")

test_that("Calcualte Age", {
  Age <- calcAge(birthday = "2000-01-01",
                givenday =  "2010-01-01")
  
  expect_type(Age, "double")
  expect_equal(round(Age), 10)
})
