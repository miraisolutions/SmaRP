#' IB and VM list
#' @description list of variables within Ibfo Box and Validity Message lists
#' @return Ib and VM list
#'
#' @examples
#' \dontrun{
#'   # After edits, update the data e.g. by running:
#'   VM <- SmaRP:::UI_Messages()$VM
#'   save(VM, file = "data/VM.rda")
#'   # load("data/VM.rda")
#' }
UI_Messages <- function() {
  # Info Box
  IB <- list(
    CurrentP3 = "Current retirement assets in your Private Pension Fund.",
    CurrentP2 = "Current retirement assets in your Occupational Pension Fund.",
    P3purchase = "Annual contributions into your Private Pension Fund. Note that SmaRP assumes that the same contributions repeats every year until the retirement.",
    P2purchase = "Voluntary purchases in annual basis.",
    returnP3 = "Annual expected return. Note that SmaRP keeps the return constant.",
    TaxRelief = "Maximum amount you can deduct from your taxable income via voluntary contributions to retirement funds.",
    TaxRateOptional = "Possibility to enter marginal tax rate manually.",
    TaxRate = "Enter here your marginal tax rate.",
    NKids = "Number of children under 18",
    Salary = "Gross salary. In case of married-double income, enter the aggregated amount.",
    SalaryGrowthRate = "Annual expected salary growth rate. Note that this growth rate keeps constant during the full career",
    TypePurchase = "Single: one-off purchase; Annual: constant annual purchase.",
    rate_group = "If Married with Double Income, please enter all inputs as aggregated values",
    P2interestRate = "Interest Rate on the Occupational Pension Fund return. If not provided, the minimum by low is used.",
    git = "Redirect to git repository.",
    RetirementAge = "Enter desired retirement age.",
    RetirementAgeOptional = "Possibility to enter desired retirement age manually."
  )

  # Validity Message
  VM <- list(
    genre = "Gender is a mandatory input when the date of retirement is not provided.",
    Birthdate = "Birthdate is a mandatory input.",
    Birthdate2 = "You should be retired already.",
    RetirementAge = "Provide the desired retirement age.",
    need_not_zero_base = "Provide a non zero value for ",
    CurrentP3_notZero = "Private Pension Fund.",
    CurrentP3_CurrentP2_Salary_Purchases_notZero = "either Salary, Private Pension Fund, Occupational Pension Fund or funds purchases.",
    returnP3_notzero = "Private Pension Fund return.",
    plzgemeinden = "Provide a valid postal code / municipality.",
    rate_group = "Provide a valid civil status.",
    Salary = "Provide a non-zero Income.",
    TypePurchase = "Provide a valid Occupational Pension Fund purchase type.",
    TaxRateSwiss = "Provide a valid Tax Rate."
  )

  list(IB = IB, VM = VM)
}
