# # # #
# # # Example
# library(lubridate)
# library(dplyr)
# source(system.file("application", "global.R", package = "SmaRP"))
# birthday = "1981-08-12"
# P3purchase = 0
# CurrentP3 = 0
# returnP3 = 0.05
# CurrentP2 = 50000
# Salary = 95000
# SalaryGrowthRate = 0.01
# P2purchase = 2000
# TypePurchase = "AnnualP2"
# RetirementAge = 65
# ncp = length(getRetirementCalendar(birthday, givenday = today("UTC"), RetirementAge))
# NKids = 5
# postalcode = 8400
# churchtax = "N"
# rate_group = "B"
# TaxRate = NULL
# rate = BVGparams$BVGMindestzinssatz
# 
# 
# Road2Retirement <- buildContributionP2Path(birthday,
#                                            Salary,
#                                            SalaryGrowthRate,
#                                            CurrentP2,
#                                            P2purchase,
#                                            TypePurchase,
#                                            rate = BVGMindestzinssatz,
#                                            RetirementAge= RetirementAge) %>%
#   left_join(buildContributionP3path(birthday,
#                                     P3purchase,
#                                     CurrentP3,
#                                     returnP3,
#                                     RetirementAge= RetirementAge), by = c("calendar", "t")) %>%
#   left_join(buildTaxBenefits(birthday,
#                              TypePurchase,
#                              P2purchase,
#                              P3purchase,
#                              returnP3,
#                              Salary,
#                              SalaryGrowthRate,
#                              postalcode,
#                              NKids,
#                              churchtax,
#                              rate_group,
#                              MaxContrTax,
#                              tax_rates_Kanton_list,
#                              BundessteueTabelle,
#                              givenday = today("UTC"),
#                              RetirementAge,
#                              TaxRate = TaxRate,
#                              PLZGemeinden),
#             by = c("calendar", "t")) %>%
#   mutate(Total = TotalP2 + TotalP3 + TotalTax)
# # 
# # 
# FotoFinish <- Road2Retirement %>%
#           mutate(Tax = DirectTax + ReturnTax) %>%
#           mutate(P2 = DirectP2 + ReturnP2) %>%
#           mutate(P3 = DirectP3 + ReturnP3) %>%
#           select(P2, P3, Tax) %>%
#           tail(1) %>%
#           prop.table() #%>%
#           #select_if(function(x) x != 0)
# 
# BarGraphData <- cbind(FotoFinish, FotoFinish) %>%
#   set_colnames(c(colnames(FotoFinish), paste0(colnames(FotoFinish), ".annotation"))) %>%
#   mutate(contribution = "") %>%
#   .[,order(colnames(.))]
# 
# 
# ## Stacked bar chart
# Bar2 <- gvisBarChart(BarGraphData, xvar = "contribution",
#                      yvar= colnames(BarGraphData)[!grepl("contribution", colnames(BarGraphData))],
#                      options=list(isStacked=TRUE, vAxes="[{minValue:0}]"))
# plot(Bar2)

#
# # order of columns aligned with FotoFinish and BarGraphData
# TserieGraphData <- Road2Retirement[, c("calendar", "DirectP2", "DirectP3",  "DirectTax", "ReturnP2", "ReturnP3", "ReturnTax")] %>%
#   .[, colSums(. != 0, na.rm = TRUE) > 0]
#
# BarGraphData <- data.frame(Funds = colnames(FotoFinish),
#                            percentage = as.vector(t(FotoFinish))) %>%
#   arrange(Funds) %>%
#   mutate(pos = cumsum(percentage) - (0.5 * percentage),
#          percentage = round(percentage * 100, digits = 1),
#          pos = round(pos * 100, digits = 1))
#


#' @name buildt
#' @examples
#' \dontrun{
#' buildt("1981-08-12")
#' }
#' @export
buildt <- function(birthday, givenday = today("UTC"), RetirementAge = 65){
  calendar = getRetirementCalendar(birthday, givenday = today("UTC"), RetirementAge +1 )
  t = c(as.vector(diff(calendar)/365))
  return(t)
}

#' @name calcAge
#' @importFrom lubridate today interval duration
#' @export
calcAge <- function(birthday, givenday = today("UTC")) {
  age <- lubridate:::interval(start = birthday, end = givenday) / duration(num = 1, units = "year")
  age
}

#' @name getRetirementday
#' @importFrom lubridate ymd years
#' @examples
#' \dontrun{
#' getRetirementday("1981-08-12")
#' }
#' @export
getRetirementday <- function(birthday, RetirementAge = 65) {
  retirementday <- ymd(birthday) + years(RetirementAge)
  retirementday
}

#' @name getRetirementCalendar
#' @importFrom lubridate today ymd years year month day
#' @examples
#' \dontrun{
#' getRetirementCalendar("1981-08-12")
#' }
#' @export
getRetirementCalendar <- function(birthday, givenday = today("UTC"), RetirementAge = 65){
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

#' @name buildContributionP2Path
#' @importFrom dplyr mutate left_join
#' @importFrom magrittr '%>%' '%<>%' 
#' @examples
#' \dontrun{
#' buildContributionP2Path(birthday, Salary, SalaryGrowthRate, CurrentP2, P2purchase, TypePurchase, BVGMindestzinssatz, givenday = today("UTC")) %>% print
#' }
#' @export
buildContributionP2Path <- function(birthday,
                                    Salary,
                                    SalaryGrowthRate,
                                    CurrentP2,
                                    P2purchase,
                                    TypePurchase,
                                    rate = BVGparams$BVGMindestzinssatz,
                                    givenday = today("UTC"),
                                    RetirementAge
){
  # build BVG rates from global input
  BVGRatesPath <- data.frame(years = seq(BVGcontriburionrates$lowerbound[1], BVGcontriburionrates$upperbound[nrow(BVGcontriburionrates)]),
                             BVGcontriburionrates = rep(BVGcontriburionrates$BVGcontriburionrates, 
                                                        times = BVGcontriburionrates$upperbound - BVGcontriburionrates$lowerbound + 1)
  )%>% filter(years <= RetirementAge)
  
  # calc contributions P2 Path
  ContributionP2Path <- data.frame(calendar = getRetirementCalendar(birthday, givenday = today("UTC"), RetirementAge = RetirementAge )) %>%
    mutate(AgePath = sapply(calendar, calcAge, birthday = birthday) %>% as.integer) %>%
    left_join(BVGRatesPath, by = c("AgePath" = "years")) %>% 
    mutate(BVGcontriburionrates = if_else(is.na(BVGcontriburionrates), 0, BVGcontriburionrates))
  
  ncp <- nrow(ContributionP2Path)
  
  ContributionP2Path %<>% within({
    ExpectedSalaryPath = calcExpectedSalaryPath(Salary, SalaryGrowthRate, ncp)
    BVGpurchase = calcBVGpurchase(TypePurchase, P2purchase, ncp)
    BVGContributions = if_else(is.na(BVGpurchase + (ExpectedSalaryPath * BVGcontriburionrates)), 0, BVGpurchase + (ExpectedSalaryPath * BVGcontriburionrates))
    BVGDirect = BVGContributions +c(CurrentP2, rep(0, ncp -1))
    t = buildt(birthday, RetirementAge = RetirementAge )
    TotalP2 = calcAnnuityAcumPath(BVGDirect, t, rate)
    ReturnP2 = TotalP2 - cumsum(BVGDirect) - cumsum(BVGpurchase)
    DirectP2 = cumsum(BVGDirect)
  })
  return(ContributionP2Path)
}

#' @name calcExpectedSalaryPath
#' @examples
#' \dontrun{
#' calcExpectedSalaryPath(90000, 0.02, 20)
#' }
#' @export
calcExpectedSalaryPath <- function(Salary, SalaryGrowthRate, ncp) {
  nrise <- ncp - 2 #No rise current and last appraissal  
  res <- cumprod(c(Salary, rep(1 + SalaryGrowthRate, nrise), 1))
}

#' @name calcBVGpurchase
#' @examples
#' \dontrun{
#' calcBVGpurchase(TypePurchase = "AnnualP2", P2purchase = 2000, ncp = 25) %>% print
#' }
#' @export
calcBVGpurchase <- function(TypePurchase, P2purchase, ncp){
  if (TypePurchase == "AnnualP2") {
    BVGpurchase <- c(0, rep(P2purchase, ncp-1))
  } else {
    BVGpurchase <- c(0, P2purchase, rep(0, ncp -2))
  }
}

#' @name buildContributionP3path
#' @importFrom dplyr mutate
#' @importFrom magrittr '%>%' '%<>%' 
#' @examples
#' \dontrun{
#' buildContributionP3path(birthday, P3purchase, CurrentP3, returnP3) %>% print
#' }
#' @export
buildContributionP3path <- function(birthday, 
                                    P3purchase,
                                    CurrentP3,
                                    returnP3,
                                    givenday = today("UTC"),
                                    RetirementAge
){
  
  ContributionP3Path <- data.frame(calendar = getRetirementCalendar(birthday, givenday = today("UTC"), RetirementAge = RetirementAge ))
  ncp <- nrow(ContributionP3Path) 
  ContributionP3Path %<>% within({
    P3purchase = c(0, rep(P3purchase, ncp-1))
    P3ContributionPath = P3purchase + c(CurrentP3, rep(0, ncp -1))
    t = buildt(birthday, RetirementAge = RetirementAge )
    TotalP3 = calcAnnuityAcumPath(P3ContributionPath, t, returnP3)
    ReturnP3 = TotalP3 - cumsum(P3ContributionPath) - cumsum(P3Purchase)
    DirectP3 = cumsum(P3ContributionPath)
  }) 
  return(ContributionP3Path)
}

#' @name calcAnnuityAcumPath
#' @examples
#' \dontrun{
#' calcAnnuityAcumPath(contributions = c(50000, 1000, 1000, 1000, 1000), t = c(0.284931, 1, 1, 1, 0), rate = 0.01)
#' }
#' @export
# calcAnnuityAcumPath <- function(contributions, t, rate){
#   res <- vector()
#   res[1] <- contributions[1] * exp(rate * t[1])
#   for(i in 2:length(contributions)) {
#     res[i] <- (res[i-1] + contributions[i]) * exp(rate * t[i]) 
#   }
#   res1 <- vector()
#   res1[1]<-0
#   res1[2:length(res)]<-res[1:length(res)-1]
#   res1
# }
calcAnnuityAcumPath <- function(contributions, t, rate){
  res <- vector()
  res[1] <- contributions[1]
  for(i in 2:length(contributions)) {
    res[i] <- res[i-1]* exp(rate * t[i-1])  + contributions[i]
  }
  res
}



#' @name downloadPLZ
#' @examples
#' \dontrun{
#' downloadPLZ(refresh=TRUE)
#' }
#' @export
downloadInputs <- function(refresh){
  if(refresh){
    URL_plz <- "https://www.bfs.admin.ch/bfsstatic/dam/assets/4242620/master"
    fileName <- "data/CorrespondancePostleitzahlGemeinde.xlsx"
    currentDateTime <- tryCatch( {download.file(URL_plz,destfile=fileName,mode="wb")},
                                 error = function(e) {message <- "update not possible, try again later"
                                 return(message)},
                                 warning = function(w) {message <- "update not possible, try again later"
                                 return(message)},
                                 finally = {return(Sys.time())}
    )
    URL_taxrate <- "https://www.estv.admin.ch/dam/estv/it/dokumente/bundessteuer/quellensteuer/schweiz/tar2018txt.zip.download.zip/tar2018txt.zip"
    repositoryName <- "data/raw1"
    zipfileName <- paste0(repositoryName, "/raw1.zip")
    currentDateTime <- tryCatch( {download.file(URL_taxrate,destfile=zipfileName)},
                                 error =function(e) {message <- "update not possible, try again later"
                                 return(message)},
                                 warning = function(w) {message <- "update not possible, try again later"
                                 return(message)},
                                 finally = { #unzip(zipfileName, exdir=repositoryName, overwrite=TRUE)
                                   return(Sys.time())}
    )
    return(currentDateTime)
  }
}

#' @name returnPLZKanton 
#' @export
returnPLZKanton <- function(plz){
  
  Kanton <- PLZGemeinden$Kanton[PLZGemeinden$PLZ == as.numeric(plz)]
  return(Kanton)
}

#' @name returnSteuerfuss 
#' @export
returnSteuerfuss <- function(plz){
  Steuerfuss <- PLZGemeinden$FactorKanton[PLZGemeinden$PLZ == as.numeric(plz)]
  return(Steuerfuss)
}



# Convert to Monetary data type  -----------------------------------------------------------------
#' @name printCurrency
#' @examples
#' \dontrun{
#' printCurrency(123123.334)
#' }
#' @export
printCurrency <- function(value,  digits=0, sep=",", decimal=".") { #currency.sym ="",
  paste(
    #currency.sym,
    formatC(value, format = "f", big.mark = sep, digits=digits, decimal.mark=decimal),
    sep=""
  )
}


# Make table -------------------------------------------------------------
#' @name makeTable 
#' @examples
#' \dontrun{
#' makeTable(Road2Retirement)
#' }
#' @export
makeTable <- function(Road2Retirement){ #, currency=""
  moncols <- c( "DirectP2", "ReturnP2", "TotalP2", "DirectP3", "ReturnP3", "TotalP3", "DirectTax", "ReturnTax", "TotalTax", "Total")
  TableMonetary <- Road2Retirement[, c("calendar", moncols)] %>%
    mutate(calendar = paste(year(calendar), month(calendar, label = TRUE), sep = "-"))
  TableMonetary[, moncols] <- sapply(TableMonetary[, moncols], printCurrency) #, currency
  return(TableMonetary)
}


# Utility functions for validity checks -----------------------------------
#' @name isnotAvailable  
#' @export
isnotAvailable <- function(inputValue){
  if(inputValue =="" | is.na(inputValue) |is.null(inputValue) ){
    TRUE
  } else {
    FALSE
  }
}

#' @name isnotAvailableReturnZero  
#' @export
isnotAvailableReturnZero <- function(inputValue){
  if(isnotAvailable(inputValue) ){
    0
  } else {
    inputValue
  }
}

#' @name need_not_zero 
#' @export
need_not_zero <- function(input, inputname) {
  if (input == 0 | input == "" | is.null(input)) {
    paste0(VB$need_not_zero_base,inputname)
  } else {
    NULL
  }
}


# Format Percentage -------------------------------------------------------
#' @name df 
#' @export
changeToPercentage <- function(df){
  colsannotation <- grepl(".annotation", colnames(df))
  df[, colsannotation] <- paste0(format(df[, colsannotation], digits=2, nsmall=2), "%")
  df
}
