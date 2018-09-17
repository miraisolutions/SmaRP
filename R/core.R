#' Buildt
#' @description Build a annual path from a today (or given day) until the retirement day. 
#' @template given_bday
#' @param RetirementAge age of retirement
#' @return vector of dates until retirement. 
#' @examples
#' \dontrun{
#' buildt("1981-08-12")
#' }
#' @importFrom lubridate today duration interval
#' @export
buildt <- function(birthday, givenday = today("UTC"), RetirementAge = 65) {
  calendar <- getRetirementCalendar(birthday, givenday, RetirementAge + 1)
  t <- c(as.vector(diff(calendar) / 365))
  return(t)
}


#' Calculate Age
#' @description Function to calculate person's age at a specific point in time.
#' @inheritParams buildt 
#' @return calculated age in years
#' @details Calculated as the difference between current date and birthday.
#' @importFrom lubridate today duration interval
#' @export
#' @examples
#'  calcAge("1981-08-12")
calcAge <- function(birthday, givenday = today("UTC")) {
  age <- interval(start = birthday, end = givenday) / duration(num = 1, units = "year")
  age
}

#' Get Retirement Day
#' @description Calculate day of retirement assuming the person can retire at the age of 65
#' @inheritParams buildt 
#' @importFrom lubridate ymd years
#' @return day at which retirement begins
#' @examples
#'  getRetirementday("1981-08-12")
#' @importFrom lubridate ymd years
#' @export
getRetirementday <- function(birthday, RetirementAge = 65) {
  retirementday <- ymd(birthday) + years(RetirementAge)
  retirementday
}

#' Obtain Retirement Calendar
#' @description Calculate the annual retirement path.
#' SmarP assumes that the user will get retired the day that turns 65 or its desired retirement age.
#' For the current year, if birthday is later than the calculation day, there will be 2 dates.  
#' @inheritParams buildt 
#' @importFrom lubridate today ymd years year month day
#' @return retirement calendar
#' @examples
#' \dontrun{
#' getRetirementCalendar("1981-08-12")
#' }
#' @importFrom lubridate today year ymd month day 
#' @export
getRetirementCalendar <- function(birthday, givenday = today("UTC"), RetirementAge = 65) {
  retirementday <- getRetirementday(birthday, RetirementAge)
  age <- calcAge(birthday, givenday)
  refyeardiff <- year(givenday) - year(birthday)
  if (refyeardiff <= age) {
    nextbirthday <- ymd(paste(year(givenday) + 1, month(birthday), day(birthday), sep = "-"))
  } else {
    nextbirthday <- ymd(paste(year(givenday), month(birthday), day(birthday), sep = "-"))
  }
  calendar <- c(givenday, seq.Date(from = as.Date(nextbirthday), to = as.Date(retirementday), by = "year"))
  calendar
}

#' Build Contribution Pillar II Path
#' @description Gather all the required information to project the annual contributions to the occupational pension fund.
#' @inheritParams buildt 
#' @template salary
#' @template P2
#' @template TypePurchase
#' @param rate male or female
#' @import dplyr
#' @importFrom magrittr '%<>%'
#' @return data frame with annual different contributions to the Pillar II.  
#' @examples
#' \dontrun{
#' buildContributionP2Path(
#'   birthday = "1975-10-10",
#'   Salary = 90000,
#'   SalaryGrowthRate = 0.01,
#'   CurrentP2 = 10000,
#'   P2purchase = 2000,
#'   TypePurchase = "AnnualP2",
#'   rate = 0.025,
#'   givenday = as.Date("2018-07-04"),
#'   RetirementAge = 67)
#' }
#' @export
buildContributionP2Path <- function(birthday,
                                    Salary,
                                    SalaryGrowthRate,
                                    CurrentP2,
                                    P2purchase,
                                    TypePurchase,
                                    rate = BVGMindestzinssatz,
                                    givenday = today("UTC"),
                                    RetirementAge) {

  # build BVG rates from global input
  BVGRatesPath <- BVGcontriburionratesPath %>%
    filter(years <= RetirementAge)

  # calc contributions P2 Path
  ContributionP2Path <- data.frame(calendar = getRetirementCalendar(birthday, givenday, RetirementAge = RetirementAge)) %>%
    mutate(AgePath = sapply(calendar, calcAge, birthday = birthday) %>%
      as.integer()) %>%
    left_join(BVGRatesPath, by = c("AgePath" = "years")) %>%
    mutate(BVGcontriburionrates = if_else(is.na(BVGcontriburionrates), 0, BVGcontriburionrates))

  ncp <- nrow(ContributionP2Path)
  isPurchase <- c(0, rep(1, ncp - 1))

  ContributionP2Path %<>% within({
    ExpectedSalaryPath <- calcExpectedSalaryPath(Salary, SalaryGrowthRate, ncp)
    BVGpurchase <- calcBVGpurchase(TypePurchase, P2purchase, ncp)
    BVGContributions <- if_else(is.na(BVGpurchase + (max(0, ExpectedSalaryPath - MinBVG) * BVGcontriburionrates)), 0, BVGpurchase + (max(0, ExpectedSalaryPath - MinBVG) * BVGcontriburionrates * isPurchase))
    BVGDirect <- BVGContributions + c(CurrentP2, rep(0, ncp - 1))
    t <- buildt(birthday, givenday, RetirementAge = RetirementAge)
    TotalP2 <- calcAnnuityAcumPath(BVGDirect, t, rate)
    DirectP2 <- cumsum(BVGDirect)
    ReturnP2 <- TotalP2 - DirectP2
  })

  return(ContributionP2Path)
}

#' Calculate Expected Salary Path
#' @description calculate whether the salary will increase/decrease and by how much.
#' @template salary
#' @template ncp 
#' @return expected salary path
#' @examples
#' \dontrun{
#' calcExpectedSalaryPath(90000, 0.02, 20)
#' }
#' @export
calcExpectedSalaryPath <- function(Salary, SalaryGrowthRate, ncp) {
  nrise <- ncp - 2
  # Not rise now neither last appraissal
  res <- cumprod(c(Salary, rep(1 + SalaryGrowthRate, nrise), 1))
}

#' Calculate Purchase Pilar II
#' @description Calculate the path of purchases to the Pilar II (Occupational pension fund, BVG) 
#' @template  TypePurchase
#' @template P2purchase
#' @template ncp
#' @return BVG purchase
#' @examples
#' \dontrun{
#' calcBVGpurchase(TypePurchase = "AnnualP2", P2purchase = 2000, ncp = 25) %>% print
#' }
#' @export
calcBVGpurchase <- function(TypePurchase, P2purchase, ncp) {
  if (TypePurchase == "AnnualP2") {
    BVGpurchase <- c(0, rep(P2purchase, ncp - 1))
  } else {
    BVGpurchase <- c(0, P2purchase, rep(0, ncp - 2))
  }
}

#' Build Contribution Pillar III Path
#' @description Build the contribution path for a standard pension fund, called Pillar III in Switzerland.
# Based on 'calcAnnuityAcumPath()'
#' @inheritParams buildt 
#' @template P3
#' @return data frame with annual different contributions to the Pillar III.
#' @examples
#' \dontrun{
#' buildContributionP3path(
#'   birthday = "1980-12-01",
#'   P3purchase = 5000,
#'   CurrentP3 = 100000,
#'   returnP3 = 0.03,
#'   givenday = as.Date("2015-11-30"),
#'   RetirementAge = 62)
#' }
#' @importFrom dplyr mutate '%>%'
#' @export
buildContributionP3path <- function(birthday,
                                    P3purchase,
                                    CurrentP3,
                                    returnP3,
                                    givenday = today("UTC"),
                                    RetirementAge) {
  ContributionP3Path <- data.frame(calendar = getRetirementCalendar(birthday, givenday, RetirementAge = RetirementAge))

  ncp <- nrow(ContributionP3Path)

  ContributionP3Path <- ContributionP3Path %>%
    mutate(
      P3purchase = c(0, rep(P3purchase, ncp - 2), 0),
      P3ContributionPath = P3purchase + c(CurrentP3, rep(0, ncp - 1)),
      t = buildt(birthday, givenday, RetirementAge = RetirementAge),
      TotalP3 = calcAnnuityAcumPath(P3ContributionPath, t, returnP3),
      DirectP3 = cumsum(P3ContributionPath),
      ReturnP3 = TotalP3 - DirectP3
    )

  return(ContributionP3Path)
}

#' Calculate annuity accumative path
#' @description  Calculate the future value of a certain annuity (contributions) at a give periodicity (t). 
#' @param contributions vector of contributions (annuities)
#' @param t vector of time intervals corresponding to the constributions
#' @param rate interest rate
#' @return vector of accumulated annuitites
#' @examples
#' \dontrun{
#' calcAnnuityAcumPath(contributions = c(50000, 1000, 1000, 1000, 1000), 
#'                                 t = c(0.284931, 1, 1, 1, 0), rate = 0.01)
#' }
#' @export
calcAnnuityAcumPath <- function(contributions, t, rate) {
  # set a default TODO-Gabriel
  res <- contributions
  for (i in 2:length(contributions)) {
    res[i] <- res[i - 1] * exp(rate * t[i - 1]) + contributions[i]
  }
  res
}

#' Return Postal Code Kanton
#' @description Return in which canton the person is retiring
#' @param plz canton's zip code
#' @return canton's zip code
#' @export
returnPLZKanton <- function(plz) {
  Kanton <- PLZGemeinden$Kanton[PLZGemeinden$PLZ == as.numeric(plz)]
  return(Kanton)
}

#' Print Currency
#' @description print values as monetary on a given currency.  
#' @template print_currency
#' @return currency
#' @examples
#' \dontrun{
#' printCurrency(123123.334)
#' }
#' @export
printCurrency <- function(value, digits = 0, sep = ",", decimal = ".") { # currency.sym ="",
  paste(
    # currency.sym,
    formatC(value, format = "f", big.mark = sep, digits = digits, decimal.mark = decimal),
    sep = ""
  )
}

#' Make Table
#' @description Utility function to display main results on the table tab.
#' @param Road2Retirement Main data frame where main results are displayed.
#' @param moncols Columns to prit out on the table
#' @return Table to print out
#' @examples
#' \dontrun{
#' makeTable(Road2Retirement)
#' }
#' @importFrom dplyr mutate '%>%'
#' @importFrom lubridate year month
#' @export
makeTable <- function(Road2Retirement, moncols = c("DirectP2", "ReturnP2", "TotalP2", "DirectP3", "ReturnP3", "TotalP3", "DirectTax", "ReturnTax", "TotalTax", "Total")) { # , currency=""
  # TODO-Gabriel: Rename headers 
  TableMonetary <- Road2Retirement[, c("calendar", moncols)] %>%
    mutate(calendar = paste(year(calendar), month(calendar, label = TRUE), sep = "-"))
  TableMonetary[, moncols] <- sapply(TableMonetary[, moncols], printCurrency) # , currency
  return(TableMonetary)
}


# Utility functions for validity checks ----

#' Is not Available
#' @description if input value is not available, then return logical TRUE else FALSE
#' @param inputValue input value
#' @return TRUE or FALSE 
#' @export
isnotAvailable <- function(inputValue) {
  if (inputValue == "" | is.na(inputValue) | is.null(inputValue)) {
    TRUE
  } else {
    FALSE
  }
}

#' Is Not Available Return Zero
#' @description if input value is not available, then return zero else input value
#' @param inputValue input value
#' @param fallback zero
#' @return zero or input value
#' @export
isnotAvailableReturnZero <- function(inputValue, fallback = 0) {
  if (isnotAvailable(inputValue)) {
    fallback
  } else {
    inputValue
  }
}

#' Need Not Zero
#' @description Utility function to display a message in case a non zero value is needed.
#' @param  input zero, nothing or null
#' @param inputname name of input
#' @return warning message or nothing
#' @export
need_not_zero <- function(input, inputname) {
  if (input == 0 | input == "" | is.null(input)) {
    paste0(VM$need_not_zero_base, inputname)
  } else {
    NULL
  }
}


# Format Percentage ----
#' Change to Percentage
#' @description from decimal to percentage value
#' @param df given data frame
#' @return percentage value
#' @export
changeToPercentage <- function(df) {
  colsannotation <- grepl(".annotation", colnames(df))
  df[, colsannotation] <- df[, colsannotation] * 100
  df[, colsannotation] <- paste0(format(df[, colsannotation], digits = 2, nsmall = 2), "%")
  df
}
