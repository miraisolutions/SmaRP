
context("calcAnnuityAcumPath")

test_that("Test calcAnnuityAcumPath",{
  
  res <- calcAnnuityAcumPath(contributions = c(50000, 1000, 1000, 1000, 1000),
                             t = c(0.25, 1, 1, 1, 0),
                             rate = 0.01)
  
  expect_equal(res[length(res)], 55712.40)
})