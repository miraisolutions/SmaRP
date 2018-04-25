
# Functions to calculate tax Amount ---------------------------------------


#' @name getTaxAmount
#' @examples
#' \dontrun{
#' getTaxAmount(Income = 200000, Rate_group = "C", Age = 32, NKids = 1, postalcode = 9443, churchtax = TRUE)
#' }
#' @export
getTaxAmount <- function(Income, Rate_group, Age, NKids, postalcode, churchtax){
  
  # Find Kanton and Gemeinde
  Kanton = PLZGemeinden[PLZGemeinden$PLZ == postalcode, "Kanton"]
  GDENR = PLZGemeinden[PLZGemeinden$PLZ == postalcode, "GDENR"]
  
  # Get Tarif
  Tarif = ifelse(Rate_group == "C", "DOPMK",
                 ifelse(Rate_group == "A" & NKids == 0, "Ledig", 
                        ifelse(Rate_group == "B" & NKids == 0, "VOK", "VMK")))
  
  # Select Tarif, Gemeinde and build Income Cuts 
  taxburden <- filter(taxburden.list[[grep(Tarif, names(taxburden.list))]], Gemeindenummer == GDENR)
  idxNumCols <- !grepl("[a-z]", colnames(taxburden))
  
  IncomeCuts <- gsub("([0-9])\\.([0-9])", "\\1\\2",colnames(taxburden)[idxNumCols]) %>%
    as.numeric()
  taxrate <- taxburden[1, idxNumCols] %>% as.vector
  
  # Calc adjustIncomeKG
  # 1. Age adjustment because of BVG contributions
  # Tax burden based on 10% contribution. Therefore, an adjustment factor is applied accordingly.
  AjustBVGContri <- BVGcontriburionratesPath %>%
    filter(years == Age) %>%
    transmute(AjustBVGContri = (BVGcontriburionrates - 0.1) * (min(Income, MaxBVG) - MinBVG))
  
  # 2. NKids ajustment (only for VMK and DOPMK)
  # Tax burden based on 2 kids. Therefore, an adjustment factor is applied accordingly.
  if(Tarif %in% c("DOPMK", "VMK")){
    OriKinderabzugKG <- sum(KinderabzugKG[row.names(KinderabzugKG) == Kanton, 1:2])
    AjustKinderabzug <- sum(KinderabzugKG[row.names(KinderabzugKG) == Kanton, 1:NKids]) - OriKinderabzugKG
  } else {
    AjustKinderabzug <- 0
  }
  
  IncomeKG <- Income + AjustBVGContri + AjustKinderabzug
  
  TaxAmountKGC <- Income * (approx(x = IncomeCuts, y = taxrate, IncomeKG)$y) / 100
  
  # Church affiliation 
  # By default, assumed church affiliation. If not, there's a discount
  if (!churchtax) {
    TaxAmountKGC <- TaxAmountKGC * Kirchensteuer[Kirchensteuer$Kanton == Kanton, "Kirchensteuer"] 
  }
  
  # Get Taxable Federal Income
  TaxableIncomeFederal <- BVGcontriburionratesPath %>%
    filter(years == Age) %>%
    transmute(AjustSalary = Income - (BVGcontriburionrates * (min(Income, MaxBVG) - MinBVG)) -
                (Income * AHL) -
                (Income * ALV) - 
                ifelse(Tarif == "Ledig", VersicherungsL, VersicherungsV + Verheiratet) - 
                ifelse(Tarif == "DOPMK", DOV, 0) - 
                NKids * (VersicherungsK + Kinder))
  
 
  TaxAmountFederal<- lookupTaxRate(TaxableIncomeFederal, BundessteueTabelle,Rate_group) - 251*NKids
  TaxAmount <- TaxAmountFederal + TaxAmountKGC
  
  return(TaxAmount)
  
}


#' @name lookupTaxRate
#' @examples
#' \dontrun{
#' lookupTaxRate(Income = 100000, Tabelle = tax_rates_Kanton_list[["ZH"]], CivilStatus = "A")
#' }
#' @export
lookupTaxRate <- function(Income, Tabelle, CivilStatus){
  #Define column to pick
  if(CivilStatus =="A"){
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
#' @examples
#' \dontrun{buildTaxBenefits(birthday, TypePurchase, P2purchase, P3purchase, returnP3, Salary, SalaryGrowthRate, postalcode, NKids, churchtax, rate_group, MaxContrTax, tax_rates_Kanton_list, BundessteueTabelle, givenday = today("UTC", RetirementAge =65, PLZGemeinden))
#' }
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
                             givenday = today("UTC"),
                             RetirementAge,
                             TaxRate = NULL
) {
  TaxBenefitsPath <- data.frame(calendar = getRetirementCalendar(birthday, givenday = today("UTC"), RetirementAge = RetirementAge ))
  ncp <- nrow(TaxBenefitsPath) 
  TaxBenefitsPath %<>% within({
    BVGpurchase = calcBVGpurchase(TypePurchase, P2purchase, ncp)
    P3purchase = c(0, rep(P3purchase, ncp-1))
    TotalContr = BVGpurchase + P3purchase
    ExpectedSalaryPath = calcExpectedSalaryPath(Salary, SalaryGrowthRate, ncp)
    TaxableIncome = pmax(ExpectedSalaryPath - pmin(TotalContr, MaxContrTax),0)
    AgePath = sapply(calendar, calcAge, birthday = birthday) %>% as.integer 
    if(!is.null(TaxRate)){
      TaxBenefits = calcTaxBenefitGeneral(TotalContr =TotalContr, TaxRatePath = rep(TaxRate, length(ExpectedSalaryPath)), MaxContrTax=MaxContrTax)
    } else {
      TaxBenefits =  calcTaxBenefitSwiss(ExpectedSalaryPath, TaxableIncome, Rate_group, AgePath, NKids, postalcode, churchtax)
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
#' @examples
#' \dontrun{
#' calcTaxBenefit(rep(6500,10), rep(0.1, 10), 6000)
#' }
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
#' @examples
#' \dontrun{
#' calcTaxBenefit(rep(6500,10), rep(0.1, 10), 6000)
#' }
#' @export
calcTaxBenefitSwiss <- function(ExpectedSalaryPath, TaxableIncome, Rate_group, Age, NKids, postalcode, churchtax){
  TaxAmountGrossIncome <- sapply(ExpectedSalaryPath, getTaxAmount, Rate_group, Age, NKids, postalcode, churchtax)
  TaxAmountTaxableIncome <- sapply(TaxableIncome, getTaxAmount, Rate_group, Age, NKids, postalcode, churchtax)
  TaxBenefits <- TaxAmountGrossIncome - TaxAmountTaxableIncome
  return(TaxBenefits)
}

#' #' @name getTaxAmount
#' #' @export
#' getTaxAmount_old <- function(Income, postalcode, NKids, churchtax, rate_group, tax_rates_Kanton_list, BundessteueTabelle, PLZGemeinden){  
#'   TaxAmountFederal<- lookupTaxRate(Income, BundessteueTabelle, rate_group) - 251*NKids
#'   kanton<- returnPLZKanton(postalcode)
#'   FactorKanton <- PLZGemeinden[PLZGemeinden$PLZ==postalcode, "FactorKanton"]
#'   FactorGemeinde <- PLZGemeinden[PLZGemeinden$PLZ==postalcode, "FactorGemeinde"]
#'   FactorKirche <- ifelse(churchtax=="N", 0, PLZGemeinden[PLZGemeinden$PLZ==postalcode, "FactorKirche"])
#'   EinfacherSteuer <- lookupTaxRate(Income, tax_rates_Kanton_list[[kanton]], rate_group)
#'   TaxAmountKanton <- EinfacherSteuer* FactorKanton
#'   TaxAmountGemeinde <- EinfacherSteuer * FactorGemeinde
#'   TaxAmountChurch <- EinfacherSteuer* FactorKirche
#'   TaxAmount<- TaxAmountFederal + TaxAmountKanton + TaxAmountGemeinde + TaxAmountChurch
#'   return(TaxAmount)
#' }
