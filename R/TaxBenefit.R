
#' Calculates the tax amount (federal, kantonal and local)
#' 
#' @description This function uses 2 main sources for tax data.
#' At Kanton and Gemeinde level, the source is taxburden.list.
#' At federal level, we use the official taxrate table (BundessteueTabelle) and we try to aproximate the taxable income.

#' @details 
#' This function assumes the following objects on the global enviornment
#'  * PLZGemeinden (includes Kirchensteuer)
#'  * taxburden.list
#'  * BundessteueTabelle 
#'  * BVGcontriburionratesPath, BVGcontriburionrates
#'  * MaxBVG, MinBVG
#'  * KinderabzugKG
#'  * NBU, maxNBU
#'  * AHL
#'  * ALV, maxALV
#'  * VersicherungsL, VersicherungsV, VersicherungsK
#'  * BerufsauslagenTarif, BerufsauslagenMax, BerufsauslagenMin
#'  
#' @family swisstax

#' @param Income scalar numeric 
#' @param rate_group character
#' @param Age scalar numeric
#' @param NKids scalar numeric
#' @param postalcode character
#' @param churchtax character Y/N
#' @import dplyr
#'
#' @examples
#' \dontrun{
#' getTaxAmount(Income = 200000, rate_group = "C", Age = 32, NKids = 5, postalcode = 8400, churchtax = "Y")
#' }
#' @export
getTaxAmount <- function(Income, 
                         rate_group, 
                         Age, 
                         NKids, 
                         postalcode, 
                         churchtax) {
  
  # Find Kanton and Gemeinde
  Kanton <- subset(PLZGemeinden, PLZ == postalcode, select = "Kanton")[1,1]
  GDENR <- subset(PLZGemeinden, PLZ == postalcode, "GDENR")[1,1]
  GDENAME <- subset(PLZGemeinden, PLZ == postalcode, "GDENAME")[1,1]
  
  # Get Tarif
  Tarif <- ifelse(rate_group == "C", "DOPMK",
                  ifelse(rate_group == "A" & NKids == 0, "Ledig", 
                         ifelse(rate_group == "B" & NKids == 0, "VOK", "VMK")))
  
  DOfactor <- ifelse(Tarif == "DOPMK", 2, 1)
  
  # Select Tarif, Gemeinde and build Income Cuts 
  taxburden <- filter(taxburden.list[[grep(Tarif, names(taxburden.list))]], Gemeindenummer == GDENR)
  
  # Get taxrate vector associated to one Gemeinde
  idxNumCols <- !grepl("[a-z]", colnames(taxburden))
  IncomeCuts <- gsub("([0-9])\\.([0-9])", "\\1\\2",colnames(taxburden)[idxNumCols]) %>%
    as.numeric()
  taxrate <- taxburden[1, idxNumCols] %>% as.vector
  
  # Calc adjustIncomeKG
  # 1. Age adjustment because of BVG contributions
  # Tax burden based on the Pensionkassebeitrage from the examples (5%). Therefore, an adjustment factor is applied accordingly.
  AjustBVGContri <- BVGcontriburionratesPath %>%
    filter(years == Age) %>%
    transmute(AjustBVGContri = (0.05 - BVGcontriburionrates) * (min(Income, MaxBVG) - MinBVG))
  
  # 2. NKids ajustment (only for VMK and DOPMK)
  # Tax burden based on 2 kids. Therefore, an adjustment factor is applied accordingly.
  if(Tarif %in% c("DOPMK", "VMK")){
    OriKinderabzugKG <- sum(KinderabzugKG[row.names(KinderabzugKG) == Kanton, 1:2])
    AjustKinderabzug <- OriKinderabzugKG - sum(KinderabzugKG[row.names(KinderabzugKG) == Kanton, 1:NKids])
  } else {
    AjustKinderabzug <- 0
  }
  
  # 3. NBU (not applied on taxburden source)
  NBUanzug <- min(DOfactor * maxNBU, Income * NBU)
  
  IncomeKG <- Income + AjustKinderabzug + (DOfactor * AjustBVGContri[1,1]) - NBUanzug
  
  TaxAmountKGC <- max(0, IncomeKG * (approx(x = IncomeCuts, y = taxrate, IncomeKG)$y) / 100)
  
  # Church affiliation 
  # By default, assumed church affiliation. If not, there's a discount
  if (churchtax != "Y") {
    TaxAmountKGC <- TaxAmountKGC * Kirchensteuer[Kirchensteuer$Kanton == Kanton, "Kirchensteuer"] 
  }
  
  # Get Taxable Federal Income
  TaxableIncomeFederal <- BVGcontriburionratesPath %>%
    filter(years == Age) %>%
    mutate( DO =  ifelse(Tarif == "DOPMK", DOV, 0),
            BVG = DOfactor * (BVGcontriburionrates * (min(Income, MaxBVG) - MinBVG)),
            AHL = Income * AHL,
            ALV = min(DOfactor * maxALV, Income * ALV), 
            NBU = min(DOfactor * maxNBU, Income * NBU),
            NetSalary = Income - BVG -AHL - ALV - NBU,
            Verheiratet = ifelse(Tarif == "Ledig", 0, Verheiratet),
            Versicherung = ifelse(Tarif == "Ledig", VersicherungsL, VersicherungsV + NKids * VersicherungsK),
            Beruf = max(DOfactor * BerufsauslagenMin, min(DOfactor * BerufsauslagenMax, NetSalary * BerufsauslagenTarif)),
            Kids =  NKids *  + Kinder ) %>%
    transmute(AjustSalary = NetSalary - Verheiratet - Versicherung - DO - Beruf - Kids)
  
  TaxAmountFederal <- max(0, lookupTaxAmount(TaxableIncomeFederal, BundessteueTabelle, rate_group) - 251 * NKids)
  TaxAmount <- TaxAmountFederal + TaxAmountKGC
  
  return(TaxAmount)
  
}


#' Returns the tax amount to be paid given one income.
#' 
#' @family swisstax
#' 
#' @param Income 
#' @param Tabelle 
#' @param CivilStatus 
#' @examples
#' \dontrun{
#' lookupTaxAmount(Income = 100000, Tabelle = BundessteueTabelle, CivilStatus = "A")
#' }
#' @export
lookupTaxAmount <- function(Income, Tabelle, CivilStatus) {
  
  # Define column to pick
  if(CivilStatus == "A") {
    CivilStatusColumn <- "taxAmountSingle"
  } else {
    CivilStatusColumn <- "taxAmountMarried"
  }
  
  # Get closest bin
  salary_bins <- Tabelle$I
  nearest_salary <- salary_bins[findInterval(Income, salary_bins)]
  TaxAmount <- Tabelle[Tabelle$I == nearest_salary, CivilStatusColumn]
  
  return(TaxAmount)
}

#' Builds a data frame with the tax benefits path
#' 
#' @details 
#' All inputs are scalars. Builds a data frame as long as the years to retirement. 
#' Calls 'getTaxAmount()' through 'calcTaxBenefitSwiss()', therefore, it assumes objects on the global enviornment.
#' 
#' @seealso [calcTaxBenefitSwiss()]
#' @seealso [getTaxAmount()]
#' @family swisstax
#' 
#' @param birthday 
#' @param TypePurchase 
#' @param P2purchase 
#' @param P3purchase 
#' @param returnP3 
#' @param Salary 
#' @param SalaryGrowthRate 
#' @param postalcode 
#' @param NKids 
#' @param churchtax 
#' @param rate_group 
#' @param MaxContrTax 
#' @param givenday 
#' @param RetirementAge 
#' @param TaxRate 
#' @import dplyr
#'
#' @examples
#' \dontrun{buildTaxBenefits(birthday, TypePurchase, P2purchase, P3purchase, returnP3, Salary, SalaryGrowthRate, postalcode, NKids, churchtax, rate_group, MaxContrTax, givenday = today("UTC"), RetirementAge = 65)
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
                             TaxRate = NULL) {
  
  TaxBenefitsPath <- data.frame(calendar = getRetirementCalendar(birthday, givenday = today("UTC"),
                                                                 RetirementAge = RetirementAge ))
  ncp <- nrow(TaxBenefitsPath) 
  
  TaxBenefitsPath <- TaxBenefitsPath %>%
    mutate(BVGpurchase = calcBVGpurchase(TypePurchase, P2purchase, ncp),
           P3purchase = c(0, rep(P3purchase, ncp - 1)),
           TotalContr = BVGpurchase + P3purchase,
           ExpectedSalaryPath = calcExpectedSalaryPath(Salary, SalaryGrowthRate, ncp),
           TaxableIncome = pmax(ExpectedSalaryPath - pmin(TotalContr, MaxContrTax), 0),
           AgePath = as.integer(sapply(calendar, calcAge, birthday = birthday)),
           TaxBenefits = calcTaxBenefitSwiss(ExpectedSalaryPath, TaxableIncome, rate_group, AgePath, NKids, postalcode, churchtax),
           t = buildt(birthday, RetirementAge = RetirementAge),
           TotalTax = calcAnnuityAcumPath(TaxBenefits, t, returnP3),
           ReturnTax = TotalTax - cumsum(TaxBenefits) ,
           DirectTax = cumsum(TaxBenefits)) %>%
    select(-c(ExpectedSalaryPath, P3purchase, BVGpurchase, TaxableIncome))
  
  return(TaxBenefitsPath)
}


#' Calculates the tax benefit as a difference of the taxes paid with and without retirement contributions.
#' 
#' Calls 'getTaxAmount()', therefore, it assumes objects on the global enviornment.
#' @seealso [getTaxAmount()]
#' @family swisstax
#'
#' @param ExpectedSalaryPath vector length equals year to retirement
#' @param TaxableIncome vector length equals year to retirement
#' @param rate_group 
#' @param Age vector length equals year to retirement
#' @param NKids 
#' @param postalcode 
#' @param churchtax 
#' 
#' @examples
#' \dontrun{
# calcTaxBenefitSwiss(ExpectedSalaryPath = seq(90000, 100000, 1000),
#                     TaxableIncome = seq(88000, 98000, 1000),
#                     rate_group = "A",
#                     Age = seq(55, 65),
#                     NKids = 0,
#                     postalcode = 8400,
#                     churchtax = "Y")
#' }
#' @export
calcTaxBenefitSwiss <- function(ExpectedSalaryPath,
                                TaxableIncome,
                                rate_group,
                                Age,
                                NKids,
                                postalcode,
                                churchtax) {
  
  assertthat::are_equal(length(ExpectedSalaryPath), length(TaxableIncome))
  
  TaxAmountGrossIncome <-  sapply(seq_along(ExpectedSalaryPath), function(i) {
    getTaxAmount(ExpectedSalaryPath[i], rate_group, Age[i], NKids, postalcode, churchtax)
  })
  
  TaxAmountTaxableIncome <-  sapply(seq_along(ExpectedSalaryPath), function(i) {
    getTaxAmount(TaxableIncome[i], rate_group, Age[i], NKids, postalcode, churchtax)
  })
  
  TaxBenefits <- TaxAmountGrossIncome - TaxAmountTaxableIncome
  
  return(TaxBenefits)
}

