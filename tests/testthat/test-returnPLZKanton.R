context("returnPLZKanton")

test_that("return PLZ Kanton", {
  PLZKanton <- returnPLZKanton(plz = 8003)
  
  expect_type(PLZKanton, "character")
  expect_identical(PLZKanton, "ZH")
})
