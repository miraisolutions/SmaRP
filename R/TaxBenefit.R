
# Functions to calculate tax Amount ---------------------------------------


#' @name lookupTaxRate
#' @example lookupTaxRate(Income=100000, Tabelle=tax_rates_Kanton_list[["ZH"]], CivilSatus="A")
#' @export
lookupTaxRate <- function(Income, Tabelle, CivilSatus){
  #Define column to pick
  if(CivilSatus =="A"){
    CivilStatusColumn <-"taxAmountSingle"
  } else{
    CivilStatusColumn <-"taxAmountMarried"
  }
  #Get closest bin
  salary_bins <- Tabelle$I
  nearest_salary <- salary_bins[findInterval(Income, salary_bins)]
  TaxAmount<- Tabelle[Tabelle$I==nearest_salary, CivilStatusColumn]
  return(TaxAmount)
}




# build Tax Benefit -------------------------------------------------------

#' @name buildTaxBenefits
#' @importFrom dplyr select
#' @example buildTaxBenefits(birthday, TypePurchase, P2purchase, P3purchase, returnP3, Salary, SalaryGrowthRate, postalcode, NKids, churchtax, rate_group, MaxContrTax, tax_rates_Kanton_list, BundessteueTabelle, givenday = today("UTC", RetirementAge =65, PLZGemeinden))
#' @export
buildTaxBenefits <- function(birthday,
                             TypePurchase,
                             P2purchase,
                             P3purchase,
                             returnP3,
                             Salary,
                             SalaryGrowthRate,
                             postalcode,
                             NKids,
                             churchtax,
                             rate_group,
                             MaxContrTax,
                             tax_rates_Kanton_list, 
                             BundessteueTabelle,
                             givenday = today("UTC"),
                             RetirementAge,
                             TaxRate = NULL,
                             PLZGemeinden
) {
  TaxBenefitsPath <- data.frame(calendar = getRetirementCalendar(birthday, givenday = today("UTC"), RetirementAge = RetirementAge ))
  ncp <- nrow(TaxBenefitsPath) 
  TaxBenefitsPath %<>% within({
    BVGpurchase = calcBVGpurchase(TypePurchase, P2purchase, ncp)
    P3purchase = rep(P3purchase, ncp)
    TotalContr = BVGpurchase + P3purchase
    ExpectedSalaryPath = calcExpectedSalaryPath(Salary, SalaryGrowthRate, ncp)
    TaxableIncome = pmax(ExpectedSalaryPath - pmin(TotalContr, MaxContrTax),0)
    if(!is.null(TaxRate)){
      TaxBenefits = calcTaxBenefitGeneral(TotalContr =TotalContr, TaxRatePath = rep(TaxRate, length(ExpectedSalaryPath)), MaxContrTax=MaxContrTax)
    } else {
      TaxBenefits =  calcTaxBenefitSwiss(ExpectedSalaryPath, TaxableIncome, postalcode, NKids, churchtax, rate_group, tax_rates_Kanton_list, BundessteueTabelle, PLZGemeinden)
    }
    t = buildt(birthday, RetirementAge = RetirementAge )
    TotalTax = calcAnnuityAcumPath(TaxBenefits, t, returnP3)
    ReturnTax = TotalTax - cumsum(TaxBenefits)
    DirectTax = cumsum(TaxBenefits)
  }) %>%
    select(-c(ExpectedSalaryPath, P3purchase, BVGpurchase, TaxableIncome))
  return(TaxBenefitsPath)
}

#' @name calcTaxBenefitGeneral
#' @example calcTaxBenefit(rep(6500,10), rep(0.1, 10), 6000)
#' @export
calcTaxBenefitGeneral <- function(TotalContr, TaxRatePath, MaxContrTax) {
  TaxBenefits <- vector()
  TaxBenefits[1] <- TotalContr[1] * TaxRatePath[1]
  for (i in 2:length(TaxRatePath)) {
    TaxBenefits[i] <- min((TotalContr[i] + TaxBenefits[i-1]), MaxContrTax) * TaxRatePath[i]
  }
  return(TaxBenefits)
}


#' @name calcTaxBenefitSwiss
#' @example calcTaxBenefit(rep(6500,10), rep(0.1, 10), 6000)
#' @export
calcTaxBenefitSwiss <- function(ExpectedSalaryPath, TaxableIncome, postalcode, NKids, churchtax, rate_group, tax_rates_Kanton_list, BundessteueTabelle, PLZGemeinden){
  TaxAmountGrossIncome <- sapply(ExpectedSalaryPath, getTaxAmount,postalcode, NKids, churchtax, rate_group, tax_rates_Kanton_list, BundessteueTabelle, PLZGemeinden)
  TaxAmountTaxableIncome <- sapply(TaxableIncome, getTaxAmount, postalcode, NKids, churchtax, rate_group, tax_rates_Kanton_list, BundessteueTabelle, PLZGemeinden)
  TaxBenefits <- TaxAmountGrossIncome - TaxAmountTaxableIncome
  return(TaxBenefits)
}

#' @name getTaxAmount
#' @example 
#' @export
getTaxAmount <- function(Income, postalcode, NKids, churchtax, rate_group, tax_rates_Kanton_list, BundessteueTabelle, PLZGemeinden){  
  TaxAmountFederal<- lookupTaxRate(Income, BundessteueTabelle, rate_group) - 251*NKids
  kanton<- returnPLZKanton(postalcode)
  FactorKanton <- PLZGemeinden[PLZGemeinden$PLZ==postalcode, "FactorKanton"]
  FactorGemeinde <- PLZGemeinden[PLZGemeinden$PLZ==postalcode, "FactorGemeinde"]
  FactorKirche <- ifelse(churchtax=="N", 0, PLZGemeinden[PLZGemeinden$PLZ==postalcode, "FactorKirche"])
  EinfacherSteuer <- lookupTaxRate(Income, tax_rates_Kanton_list[[kanton]], rate_group)
  TaxAmountKanton <- EinfacherSteuer* FactorKanton
  TaxAmountGemeinde <- EinfacherSteuer * FactorGemeinde
  TaxAmountChurch <- EinfacherSteuer* FactorKirche
  TaxAmount<- TaxAmountFederal + TaxAmountKanton + TaxAmountGemeinde + TaxAmountChurch
  return(TaxAmount)
}
