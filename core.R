

birthday = "1981-08-12"
P3purchase = 4800
CurrentP3 = 10000
returnP3 = 0.05
CurrentP2 = 50000
Salary = 95000
SalaryGrowthRate = 0.01
P2purchase = 2000
TypePurchase = "AnnualP2"
ncp = length(getRetirementCalendar(birthday, givenday = today()))
Kanton = "BE"
Tariff = "TB" 
NKids = "0Kids"



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
#' buildRoad2Retirement("1981-08-12", rate = 0.02, CurrentP2 = 50000, 100000, 0.01, 2000, "AnnualP2", P3purchase = 2400, CurrentP3 = 5000, returnP3 = 0.03) %>% print
buildRoad2Retirement <- function(birthday,
                                 rate = BVGMindestzinssatz,                            
                                 CurrentP2,
                                 Salary,
                                 SalaryGrowthRate,
                                 P2purchase,
                                 TypePurchase,
                                 givenday = today(),
                                 P3purchase,
                                 CurrentP3,
                                 returnP3) {
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
      ReturnP2 = TotalP2 - cumsum(BVGDirect)
      DirectP2 = cumsum(BVGDirect)
      P3direct = buildContributionP3path(birthday,
                                         P3purchase,
                                         CurrentP3,
                                         returnP3)$P3ContributionPath
      TotalP3 = calcAnnuityAcumPath(P3direct, t, rate)
      ReturnP3 = TotalP3 - cumsum(P3direct)
      DirectP3 = cumsum(P3direct)
      Total = TotalP2 + TotalP3
      TaxBenefits = 0
    }) 
}



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
  
  ContributionP2Path %<>% within({
    ExpectedSalaryPath = calcExpectedSalaryPath(Salary, SalaryGrowthRate, ncp)
    AgePath = sapply(calendar, calcAge, birthday = birthday) %>% as.integer
  }) %>%
    merge(BVGRatesPath, by.x = "AgePath", by.y = "years") %>%
    mutate(BVGpurchase = calcBVGpurchase(TypePurchase, P2purchase, ncp)) %>%
    mutate(BVGContributionPath = BVGpurchase + (ExpectedSalaryPath * BVGcontriburionrates))
  return(ContributionP2Path)
}

#' @examples
#' calcExpectedSalaryPath(90000, 0.02, 20) %>% print
calcExpectedSalaryPath <- function(Salary, SalaryGrowthRate, ncp) {
 nrise <- ncp - 2 #No rise current and last appraissal  
 res <- cumprod(c(Salary, rep(1 + SalaryGrowthRate, nrise), 1))
}

#' @examples
#' calcBVGpurchase(TypePurchase = "AnnualP", P2purchase = 2000, ncp = 25) %>% print
calcBVGpurchase <- function(TypePurchase, P2purchase, ncp){
  if (TypePurchase == "AnnualP2") {
    BVGpurchase <- rep(P2purchase, ncp)
  } else {
    BVGpurchase <- c(P2purchase, rep(0, ncp -1))
  }
}


#' @importFrom plyr mutate
#' @importFrom magritrr '%>%' '%<>%' 
#' @examples
#' buildContributionP3path(birthday, P3purchase, CurrentP3, returnP3) %>% print
buildContributionP3path <- function(birthday, P3purchase, CurrentP3, returnP3){
  ContributionP3Path <- data.frame(calendar = getRetirementCalendar(birthday, givenday = today()))
  ncp <- nrow(ContributionP3Path) 
   ContributionP3Path %<>% within({
    P3purchase = rep(P3purchase, ncp)
    P3ContributionPath = P3purchase + c(CurrentP3, rep(0, ncp -1))
  }) 
  return(ContributionP3Path)
}

#' @examples
# buildTaxBenefits(birthday, TypePurchase, P2purchase, P3purchase, returnP3, Salary, SalaryGrowthRate, Kanton, Tariff, NKids, MaxContrTax)
buildTaxBenefits <- function(birthday, TypePurchase, P2purchase, P3purchase, returnP3, Salary, SalaryGrowthRate, Kanton, Tariff, NKids, MaxContrTax){
  TaxBenefitsPath <- data.frame(calendar = getRetirementCalendar(birthday, givenday = today()))
  ncp <- nrow(TaxBenefitsPath) 
  
  TaxBenefitsPath %<>% within({
    BVGpurchase = calcBVGpurchase(TypePurchase, P2purchase, ncp)
    P3purchase = rep(P3purchase, ncp)
    TotalContr = BVGpurchase + P3purchase
    ExpectedSalaryPath = calcExpectedSalaryPath(Salary, SalaryGrowthRate, ncp)
    TaxRatePath = sapply(ExpectedSalaryPath, getTaxRate, Kanton, Tariff, NKids)
    TaxBenefits = calcTaxBenefit(TotalContr, TaxRatePath, MaxContrTax)
        
  }) 
  return(TaxBenefitsPath)
}



#' @examples
#' calcTaxBenefit(rep(6500,10), rep(0.1, 10), 6000)
calcTaxBenefit <- function(TotalContr, TaxRatePath, MaxContrTax) {
  TaxBenefits <- vector()
  TaxBenefits[1] <- TotalContr[1] * TaxRatePath[1]
  for (i in 2:length(TaxRatePath)) {
    TaxBenefits[i] <- min((TotalContr[i] + TaxBenefits[i-1]), MaxContrTax) * TaxRatePath[i]
  }
  return(TaxBenefits)
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


#' @examples
# getTaxRate(150000, "BE","TB","1kid")
# sapply(seq(from = 90000, to = 125000, 5000), getTaxRate, Kanton = "ZH", Tariff = "TA", NKids = "1kid")
getTaxRate <- function(Salary, Kanton, Tariff, NKids){  
  # TODO: Implement function given tables available in global env
  TaxRate = 0.05
  if (Kanton == "ZH") {
    TaxRate = 0.1
  } else {
    TaxRate = 0.2
  }
  
  if (Tariff == "TA") {
    TaxRate = TaxRate + 0.1
  } 
  
  if (Salary < 100000) {
    TaxRate = TaxRate * 0.7
  } 
  
  if (Salary > 120000) {
    TaxRate = TaxRate * 1.5
  } 
  
  if (NKids == "1kid") {
    TaxRate = TaxRate * 0.95
  } 
  
  if (NKids == "2kid") {
    TaxRate = TaxRate * 0.90
  } 
  
  if (NKids == "3kid") {
    TaxRate = TaxRate * 0.85
  } 
  
  return(TaxRate)
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



