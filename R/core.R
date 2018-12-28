#' @title buildt
#' 
#' @rdname buildt
#' 
#' @description Build annual path from today (or given day) until the retirement day. 
#' 
#' @template given_bday
#' @param RetirementAge Age of retirement.
#' 
#' @return Vector of dates until retirement. 
#' 
#' @examples
#' \dontrun{
#' buildt("1981-08-12")
#' }
#' @importFrom lubridate today 
#' @importFrom lubridate duration
#' @importFrom lubridate interval
#' @export
buildt <- function(birthday, givenday = today("UTC"), RetirementAge = 65) {
  calendar <- getRetirementCalendar(birthday, givenday, RetirementAge + 1)
  t <- c(as.vector(diff(calendar) / 365))
  return(t)
}


#' @title calcAge
#' 
#' @rdname calcAge
#' 
#' @description Function to calculate person's age at a specific point in time.
#' @details Calculated as the difference between current date and birthday.
#' 
#' @inheritParams buildt 
#' 
#' @return Calculated age in years.
#' 
#' @examples
#'  calcAge("1981-08-12")
#' @importFrom lubridate today 
#' @importFrom lubridate duration
#' @importFrom lubridate interval
#' @export
calcAge <- function(birthday, givenday = today("UTC")) {
  age <- interval(start = birthday, end = givenday) / duration(num = 1, units = "year")
  age
}

#' @title getRetirementday
#' 
#' @rdname getRetirementday 
#' 
#' @description Calculate day of retirement assuming the person can retire at the age of 65.
#' 
#' @inheritParams buildt 
#' 
#' @importFrom lubridate ymd 
#' @importFrom lubridate years
#' 
#' @return Day at which retirement begins.
#' 
#' @examples
#'  getRetirementday("1981-08-12")
#'  getRetirementday("1981-08-12", RetirementAge = 60)
#' @importFrom lubridate ymd years
#' @export
getRetirementday <- function(birthday, RetirementAge = 65) {
  retirementday <- ymd(birthday) + years(RetirementAge)
  retirementday
}

#' @title getRetirementCalendar
#' 
#' @rdname getRetirementCalendar 
#' 
#' @description Calculate the annual retirement path.
#' SmarP assumes that the user will get retired the day that turns 65 or its desired retirement age.
#' For the current year, if birthday is later than the calculation day, there will be 2 dates.  
#' 
#' @inheritParams buildt 
#' 
#' @return Retirement calendar.
#' @examples
#' \dontrun{
#' getRetirementCalendar("1981-08-12")
#' getRetirementCalendar("1981-08-12", as.Date("2018-12-02"), RetirementAge = 62)
#' }
#' @importFrom lubridate today 
#' @importFrom lubridate year 
#' @importFrom lubridate ymd 
#' @importFrom lubridate month 
#' @importFrom lubridate day 
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

#' @title buildContributionP2Path
#' 
#' @rdname buildContributionP2Path 
#' 
#' @description Gather all the required information to project the annual contributions to the occupational pension fund.
#' 
#' @inheritParams buildt 
#' @template salary
#' @template P2
#' @param CurrentP2 Value of the current assets in the Occupational Pension Fund.
#' @param rate Interests rate on annual basis. Constant interest rates are assumed.
#' 
#' @return All contributions to the Pillar II in annual basis.  
#' 
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
#' @import dplyr
#' @importFrom magrittr '%<>%'
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
  BVGRatesPath <- BVGcontributionratesPath %>%
    filter(years <= RetirementAge)
  
  # calc contributions P2 Path
  ContributionP2Path <- data.frame(calendar = getRetirementCalendar(birthday, givenday, RetirementAge = RetirementAge)) %>%
    mutate(AgePath = sapply(calendar, calcAge, birthday = birthday) %>%
             as.integer()) %>%
    left_join(BVGRatesPath, by = c("AgePath" = "years")) %>%
    mutate(BVGcontributionrates = if_else(is.na(BVGcontributionrates), 0, BVGcontributionrates))
  
  ncp <- nrow(ContributionP2Path)
  isPurchase <- c(0, rep(1, ncp - 1))
  
  ContributionP2Path %<>% within({
    ExpectedSalaryPath <- calcExpectedSalaryPath(Salary, SalaryGrowthRate, ncp)
    BVGpurchase <- calcBVGpurchase(TypePurchase, P2purchase, ncp)
    BVGContributions <- if_else(is.na(BVGpurchase + (max(0, ExpectedSalaryPath - MinBVG) * BVGcontributionrates)), 0, BVGpurchase + (max(0, ExpectedSalaryPath - MinBVG) * BVGcontributionrates * isPurchase))
    BVGDirect <- BVGContributions + c(CurrentP2, rep(0, ncp - 1))
    t <- buildt(birthday, givenday, RetirementAge = RetirementAge)
    TotalP2 <- calcAnnuityAcumPath(BVGDirect, t, rate)
    DirectP2 <- cumsum(BVGDirect)
    ReturnP2 <- TotalP2 - DirectP2
  })
  
  return(ContributionP2Path)
}

#' @title calcExpectedSalaryPath
#' 
#' @rdname calcExpectedSalaryPath 
#' 
#' @description Calculate whether the salary will increase/decrease and by how much.
#' 
#' @template salary
#' @param ncp Length contribution path to retirement.
#' 
#' @return Expected salary path.
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

#' @title calcBVGpurchase
#' 
#' @rdname calcBVGpurchase 
#' 
#' @description Calculate the path of purchases to the Pilar II (Occupational pension fund, BVG).
#'  
#' @inheritParams calcExpectedSalaryPath
#' @inheritParams buildContributionP2Path
#' 
#' @return BVG purchase.
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

#' @title buildContributionP3path
#' 
#' @rdname buildContributionP3path 
#' 
#' @description Build the contribution path for a standard pension fund, called Pillar III in Switzerland.
#' Based on 'calcAnnuityAcumPath()'.
#' 
#' @inheritParams buildt 
#' @inheritParams calcExpectedSalaryPath
#' @template P3
#' @param CurrentP3 Value of the current assets in the Private Pension Fund (Pillar 3).
#' 
#' @return All contributions to the Pillar III in annual basis.
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
#' 
#' @importFrom dplyr mutate 
#' @importFrom dplyr '%>%'
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

#' @title calcAnnuityAcumPath
#' 
#' @rdname calcAnnuityAcumPath
#' 
#' @description Calculate future value of an annuity with periodic contributions. 
#' * Based on continuous compounding interest in annual basis.
#' * Payments occur at the beginning of each period.
#' 
#' @param contributions Vector of contributions (annuities).
#' @param t Vector of time intervals between contributions. 
#' * Irregular time intervals are allowed. 
#' * For frequency bellow annual, enter t as proportion of a year.
#' @param rate Interests rate on annual basis. Constant interest rates are assumed.
#' 
#' @return Vector of accumulated benefits given a set of contributions.
#' @examples
#' \dontrun{
#' calcAnnuityAcumPath(contributions = c(50000, 1000, 1000, 1000, 1000),
#'                                 t = c(0.284931, 1, 1, 1, 0), rate = 0.01)
#'}
#' @export
calcAnnuityAcumPath <- function(contributions, t, rate) {
  
  assertthat::are_equal(length(contributions), length(t))
  assertthat::is.scalar(rate)
  
  # Set the first period
  res <- vector()
  res[1] <- contributions[1]
  
  if(length(contributions) == 1) {
    message("Single contribution. Since payments happen at the beginning of the period, there is no accumulation.")
    return(res)
  }
  
  # Accumulated compound interest 
  for(i in 2:length(contributions)) {
    res[i] <- res[i-1]* exp(rate * t[i-1])  + contributions[i]
  }
  return(res)
}

#' @title returnPLZKanton
#' 
#' @rdname returnPLZKanton 
#' 
#' @description Return in which canton the person is retiring.
#' 
#' @param plz Canton's postal code.
#' 
#' @return Canton.
#' @export
returnPLZKanton <- function(plz) {
  Kanton <- PLZGemeinden$Kanton[PLZGemeinden$PLZ == as.numeric(plz)]
  return(Kanton)
}

#' @title printCurrency
#' 
#' @rdname printCurrency 
#' 
#' @description Print values as monetary on a given currency.  
#' 
#' @template print_currency
#' 
#' @return Currency.
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

#' @title makeTable
#' 
#' @rdname makeTable
#' 
#' @description Utility function to display main results on the table tab.
#' 
#' @param Road2Retirement Main data frame where main results are displayed.
#' @param moncols Columns to prit out on the table.
#' 
#' @return Table to print out.
#' @examples
#' \dontrun{
#' makeTable(Road2Retirement)
#' }
#' 
#' @importFrom dplyr mutate 
#' @importFrom dplyr '%>%'
#' @importFrom lubridate year 
#' @importFrom lubridate month
#' @export
makeTable <- function(Road2Retirement, moncols = c("DirectP2", "ReturnP2", "TotalP2", "DirectP3", "ReturnP3", "TotalP3", "DirectTax", "ReturnTax", "TotalTax", "Total")) { # , currency=""
  
  TableMonetary <- Road2Retirement[, c("calendar", moncols)] %>%
    mutate(calendar = paste(year(calendar), month(calendar, label = TRUE), sep = "-"))
  TableMonetary[, moncols] <- sapply(TableMonetary[, moncols], printCurrency) 
  
  return(TableMonetary)
}


# Utility functions for validity checks ----

#' @title isnotAvailable
#' 
#' @rdname isnotAvailable 
#' 
#' @description If input value is not available, then return logical TRUE else FALSE.
#' 
#' @param inputValue Input value.
#' 
#' @return TRUE or FALSE. 
#' @export
isnotAvailable <- function(inputValue) {
  if (inputValue == "" | is.na(inputValue) | is.null(inputValue)) {
    TRUE
  } else {
    FALSE
  }
}

#' @title isnotAvailableReturnZero
#' 
#' @rdname isnotAvailableReturnZero 
#' 
#' @description If input value is not available, then return zero else input value.
#' 
#' @param inputValue Input value.
#' @param fallback Zero.
#' 
#' @return Zero or input value.
#' @export
isnotAvailableReturnZero <- function(inputValue, fallback = 0) {
  if (isnotAvailable(inputValue)) {
    fallback
  } else {
    inputValue
  }
}

#' @title need_not_zero
#' 
#' @rdname need_not_zero
#' 
#' @description Utility function to display a message in case a non zero value is needed.
#' 
#' @param  input zero, nothing or null.
#' @param inputname Name of input.
#' 
#' @return Warning message or nothing.
#' @export
need_not_zero <- function(input, inputname) {
  if (input == 0 | input == "" | is.null(input)) {
    paste0(VM$need_not_zero_base, inputname)
  } else {
    NULL
  }
}


# Format Percentage ----

#' @title changeToPercentage
#' 
#' @rdname changeToPercentage
#' 
#' @description From decimal to percentage value.
#' 
#' @param df Given data frame.
#' 
#' @return Percentage value.
#' @export
changeToPercentage <- function(df) {
  colsannotation <- grepl(".annotation", colnames(df))
  df[, colsannotation] <- df[, colsannotation] * 100
  df[, colsannotation] <- paste0(format(df[, colsannotation], digits = 2, nsmall = 2), "%")
  df
}
