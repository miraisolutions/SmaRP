
#' @importFrom lubridate today interval duration
calcAge <- function(birthday, givenday = today()) {
  age <- interval(start = birthday, end = givenday) / duration(num = 1, units = "year")
  age
}

#' @importFrom lubridate ymd years
#' getRetirementday("1981-08-12")
getRetirementday <- function(birthday) {
  retirementday <- ymd(birthday) + years(65)
  retirementday
}

#' @importFrom lubridate today ymd years year month day
#' @examples
#' getRetirementPath("1981-08-12")
getRetirementCalendar <- function(birthday, givenday = today()){
  retirementday <- getRetirementday(birthday)
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


#' @importFrom lubridate today
#' @importFrom magritrr '%>%' '%<>%' 
#' @examples
#' buildRoad2Retirement("1981-08-12", 0.02, 50000, 100000, 0.01, 2000, "AnnualP2") %>% print
buildRoad2Retirement <- function(birthday,
                                 rate = BVGMindestzinssatz,
                                 CurrentP2,
                                 Salary,
                                 SalaryGrowthRate,
                                 P2purchase,
                                 TypePurchase,
                                 givenday = today()){
  RetirementPath.df <- data.frame(calendar = getRetirementCalendar(birthday, givenday = today()))
  years2retirement <- calcAge(min(RetirementPath.df$calendar), max(RetirementPath.df$calendar))
  RetirementPath.df %<>% 
    within({
      # TODO: diff year 1
      BVGcontributions = buildContributionP2Path(birthday,
                                                 Salary,
                                                 SalaryGrowthRate,
                                                 P2purchase,
                                                 TypePurchase)$BVGContributionPath
      BVGDirect = BVGcontributions +c(CurrentP2, rep(0, nrow(RetirementPath.df)-1))
      t = c(as.vector(diff(calendar)/365), 0)
      TotalP2 = calcAnnuityAcumPath(BVGDirect, t, rate)
      # cumt = years2retirement - cumsum(t)
      # aletTotalP2 = cumsum(BVGDirect * exp(rate * cumt))
      ReturnP2 = TotalP2 - cumsum(BVGDirect)
      DirectP2 = cumsum(BVGDirect)
    }) 
}
  # # TODO: use magrittr and single funtion
  # RetirementPath.df$savings <- vector(length = nrow(RetirementPath.df))
  # RetirementPath.df$savings[1] <- RetirementPath.df$BVGcontributions[1] * exp(rate * RetirementPath.df$t[1])
  # for (i in 2:nrow(RetirementPath.df)){
  #   RetirementPath.df$savings[i] <- RetirementPath.df$savings[i-1] * exp(rate * RetirementPath.df$t[i]) + RetirementPath.df$BVGcontributions[i]
  # }
  # return(RetirementPath.df[, c("calendar", "BVGcontributions", "savings")])
  # TODO: unit test using closed formula
#   
# }


#' @importFrom plyr mutate
#' @importFrom magritrr '%>%' '%<>%' 
#' @examples
#' buildContributionP2Path("1981-08-12", 100000, 0.01, 2000, "AnnualP2") %>% print
buildContributionP2Path <- function(birthday,
                                    Salary,
                                    SalaryGrowthRate,
                                    P2purchase,
                                    TypePurchase,
                                    givenday = today()){
  # TODO: add initial amount and purchases
  # build BVG rates from global input
  BVGRatesPath <- data.frame(years = seq(BVGcontriburionrates$lowerbound[1], BVGcontriburionrates$upperbound[nrow(BVGcontriburionrates)]),
                             BVGcontriburionrates = rep(BVGcontriburionrates$BVGcontriburionrates, 
                                                        times = BVGcontriburionrates$upperbound - BVGcontriburionrates$lowerbound + 1)
  )
  # calc contributions P2 Path
  ContributionP2Path <- data.frame(calendar = getRetirementCalendar(birthday, givenday = today()))
  ncp <- nrow(ContributionP2Path)
  nrise <- ncp - 2 #No rise current and last appraissal

  ContributionP2Path %<>% within({
    ExpectedSalaryPath = cumprod(c(Salary, rep(1 + SalaryGrowthRate, nrise), 1))
    AgePath = sapply(calendar, calcAge, birthday = birthday) %>% as.integer
  }) %>%
    merge(BVGRatesPath, by.x = "AgePath", by.y = "years") %>%
    mutate(BVGpurchase = ifelse(TypePurchase == "AnnualP2", rep(P2purchase, ncp), c(P2purchase, rep(0, ncp -1)))) %>%
    mutate(BVGContributionPath = BVGpurchase + (ExpectedSalaryPath * BVGcontriburionrates))
  return(ContributionP2Path)
}


#' @examples
# calcAnnuityAcumPath(contributions = c(50000, 1000, 1000, 1000, 1000),
#                     t = c(0.284931, 1, 1, 1, 0),
#                     rate = 0.01)
calcAnnuityAcumPath <- function(contributions, t, rate){
  res <- vector()
  res[1] <- contributions[1] * exp(rate * t[1])
  for(i in 2:length(contributions)) {
    res[i] <- (res[i-1] + contributions[i]) * exp(rate * t[i]) 
  }
  res
}

# fv(0.02, 30, pv = -50000, pmt = -4800, type = 0)

# t = c(0.56, 1, 1, 1, 1)
# 
# cumt = (sum(t) + 1) - cumsum(t)
# aletTotalP2 = cumsum(contributions * exp(rate * cumt))



  # savings <- vector()
  # savings[1] <- RetirementPath.df$contributions[1] * exp(rate * RetirementPath.df$t[1])
  # lapply(2:nrow(RetirementPath.df), function(i) {
  #     savings[i] <- savings[i-1] * exp(rate * RetirementPath.df$t[i]) + RetirementPath.df$contributions[i]
  #   return(savings)
  # })
  

  
  

# # Solution using base
# diff_in_days = difftime(calendar[5], calendar[4], units = "days") 
# diff_in_years = as.double(diff_in_days)/365

# # Solution using zoo
# as.yearmon(calendar[2]) - as.yearmon(calendar[1])

# # Testing
# 
# Af = CurrentAmount * exp(rate * (sum(tyear) + 1)) + AnnualContributionP2 * ((1 + rate)^ncontri - 1) / rate
# 
# AnnualContributionP2 * (exp(rate * ncontri) - 1) / rate
# CurrentAmount * exp(rate * (sum(tyear) + 1))
# 
# 
# fv(0.02, 30, pv = -50000, pmt = -4800, type = 0)



