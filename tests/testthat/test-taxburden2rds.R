library(testthat)

context("tax data quality assurance")

taxburden_new.list <- readRDS(system.file("application", "data", "taxburden_2017.list.rds", package = "SmaRP"))
taxburden_old.list <- readRDS(system.file("application", "data", "taxburden.list.rds", package = "SmaRP"))

test_that("list components are equal", {
  expect_equal(names(taxburden_new.list), names(taxburden_old.list))
})

test_that("colnames are equal", {
  expect_equal(lapply(taxburden_new.list, colnames), lapply(taxburden_old.list, colnames))
})

test_that("taxburden does not contain NAs", {
  expect_true(all(sapply(taxburden_new.list, function(x) {all(!is.na(x))})))
})

# For comparison
# all.equal(lapply(taxburden_new.list, head), lapply(taxburden_old.list, head))
# sapply(taxburden_old.list, NROW)
# sapply(taxburden_new.list, NROW)
# sapply(taxburden_old.list, NCOL)
# sapply(taxburden_new.list, NCOL)
# length(taxburden_old.list)
# length(taxburden_new.list)
# lapply(taxburden_old.list, head)
# lapply(taxburden_new.list, head)
# lapply(taxburden_old.list, tail)
# lapply(taxburden_new.list, tail)
# file.info("/home/mirai_user/RStudioProjects/SmaRP/inst/application/data/taxburden_2016.list.rds")
# file.info("/home/mirai_user/RStudioProjects/SmaRP/inst/application/data/taxburden_2017.list.rds")
