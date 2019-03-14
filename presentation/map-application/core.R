# theme map ---------------------------------------------------------------

theme_map <- function(...) {
  theme_minimal() +
    theme(
      #text = element_text(family = "Arial", color = "#22211d"),
      axis.line = element_blank(),
      axis.text.x = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks = element_blank(),
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
      # panel.grid.minor = element_line(color = "#ebebe5", size = 0.2),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      plot.background = element_blank(),
      panel.background = element_blank(),
      legend.position = "none",
      panel.border = element_blank(),
      ...
    )
}

# lookup taxrate -----------------------------------
#' @name lookupTaxRate
#' @examples
#' \dontrun{
#' lookupTaxRate(Income = 100000, Tabelle = tax_rates_Kanton_list[["ZH"]], CivilStatus = "A")
#' }
#' @export
lookupTaxRate <- function(Income, Tabelle, CivilStatus){
  #Define column to pick
  if (CivilStatus == "A") {
    CivilStatusColumn <- "taxAmountSingle"
  } else{
    CivilStatusColumn <- "taxAmountMarried"
  }
  #Get closest bin
  salary_bins <- Tabelle$I
  nearest_salary <- salary_bins[findInterval(Income, salary_bins)]
  TaxAmount <- Tabelle[Tabelle$I == nearest_salary, CivilStatusColumn]
  return(TaxAmount)
}

# tax Amount ---------------------------------------

#' @name getTaxAmountGDENR
#' @examples
#' \dontrun{
#' getTaxAmountGDENR(Income = 200000, rate_group = "C", Age = 32, NKids = 1,  GDENR, GDENAME, churchtax = "Y")
#' }
#' @export
getTaxAmountGDENR <- function(Income, rate_group, Age, NKids, GDENR, GDENAME, churchtax){

  # Get Tarif
  Tarif = ifelse(rate_group == "C", "DOPMK",
                 ifelse(rate_group == "A" & NKids == 0, "Ledig",
                        ifelse(rate_group == "B" & NKids == 0, "VOK", "VMK")))

  DOfactor <- ifelse(Tarif == "DOPMK", 2, 1)

  # # Find Kanton and Gemeinde
  # Kanton <- filter(taxburden.list[[grep(Tarif, names(taxburden.list))]], Gemeindenummer == GDENR)$Kanton
  # if(length(Kanton)==0){
  #   Kanton <- filter(taxburden.list[[grep(Tarif, names(taxburden.list))]], Gemeinde == GDENAME)$Kanton
  # }
  # if(length(Kanton)==0){
  #   Kanton = PLZGemeinden[PLZGemeinden$GDENR == GDENR, "Kanton"] %>% unique()
  # }
  # if(length(Kanton)==0){
  #   Kanton = PLZGemeinden[PLZGemeinden$GDENAME == GDENAME, "Kanton"] %>% unique()
  # }

  Kanton <- mapPLZ[mapPLZ$GMDNR == GDENR, "Kanton"] %>% unique()

  if (length(Kanton) != 0) {
    # Select Tarif, Gemeinde and build Income Cuts
    taxburden <- filter(taxburden.list[[grep(Tarif, names(taxburden.list))]], Gemeindenummer == GDENR)

    # In case there is no match by GDENR Merge by GDENAME
    if (nrow(taxburden) == 0) {
      taxburden <- filter(taxburden.list[[grep(Tarif, names(taxburden.list))]], Gemeinde == GDENAME)
      # In case there is no match by GDENR and by GDENAME, Fall back to Kanton (Main City)
      if (nrow(taxburden) == 0) {
        GDENR =  PLZGemeinden[PLZGemeinden$GDENAME == canton.capital.df[canton.capital.df$Kanton == Kanton,"capital"], "GDENR"]
        taxburden <- filter(taxburden.list[[grep(Tarif, names(taxburden.list))]], Gemeindenummer == GDENR)
      }
    }
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
    if (Tarif %in% c("DOPMK", "VMK")) {
      OriKinderabzugKG <- sum(KinderabzugKG[row.names(KinderabzugKG) == Kanton, 1:2])
      AjustKinderabzug <- OriKinderabzugKG - sum(KinderabzugKG[row.names(KinderabzugKG) == Kanton, 1:NKids])
    } else {
      AjustKinderabzug <- 0
    }

    # 3. NBU (not applied on taxburden source)
    # To match http://www.estv2.admin.ch/d/dienstleistungen/steuerrechner/steuerrechner.htm
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
              Kids =  NKids * Kinder) %>%
      transmute(AjustSalary = NetSalary - Verheiratet - Versicherung - DO - Beruf - Kids)

    TaxAmountFederal <- max(0, lookupTaxRate(TaxableIncomeFederal, BundessteueTabelle,rate_group) - 251*NKids)
    TaxAmount <- TaxAmountFederal + TaxAmountKGC
  } else {
    TaxAmount <- 0
  }
  return(TaxAmount)

}

# make map ----------------------------------------------------------------

#' @name makeMap
#' @examples
#' \dontrun{
#' makeMap(map.gemeinde, Salary= 200000, rate_group = "C", Age = 32, NKids = 1, churchtax = "Y")
#' }
#' @export
makeMap <- function(map.gemeinde, Salary, rate_group, Age, NKids, churchtax){

  # Load map
  map.gemeinde.df <- fortify(map.gemeinde) %>%
      mutate(id = as.numeric(id))
  gemeindes <- data.frame(id = 0:(length(map.gemeinde@data$GMDNAME) - 1), gemeinde = map.gemeinde@data$GMDNAME, GMDNR = map.gemeinde@data$GMDNR)
  map.gemeinde.df <- inner_join(map.gemeinde.df, gemeindes, by = "id")

  # Add Tax amount
  GMDNR <- unique(map.gemeinde.df$GMDNR)
  GMDNAME <- sapply(1:length(GMDNR), function(i){unique(as.character(map.gemeinde.df$gemeinde[map.gemeinde.df$GMDNR == GMDNR[i]]))[1] } )
  Taxamount <- data.frame("amount" = rep(0,length(unique(map.gemeinde.df$GMDNR))), GMDNR = GMDNR)
  Taxamount$amount <- sapply(1:length(GMDNR), function(i) {
    getTaxAmountGDENR(Salary, rate_group, Age, NKids, GMDNR[i],  GMDNAME[i], churchtax)
  })


  Taxamount$amount_percentage <- Taxamount$amount*100/Salary
  minTaxAmount <- min(Taxamount$amount_percentage)
  maxTaxAmount <- max(Taxamount$amount_percentage)
  binwidthTaxAmount <- (maxTaxAmount - minTaxAmount)/10
  Taxamount$amount_discrete <- cut(Taxamount$amount_percentage,
                                             #breaks = cut_number(Taxamount$amount_percentage, 9),
                                             #breaks = seq(from = minTaxAmount, to = maxTaxAmount, by = binwidthTaxAmount),
                                             breaks = c(0, 0.9, 1.8, 2.7, 3.6, 4.5, 5.4, 6.3, 7.2, 7.8, maxTaxAmount),
                                             include.lowest = T)
  map.gemeinde.df %<>%  left_join(Taxamount, by = "GMDNR" )

  return(map.gemeinde.df)
}


# make plot --------------------------------------------------------------


#' @name makePlot
#' @examples
#' \dontrun{
#' makePlot(map.gemeinde.df)
#' }
#' @export
makePlot <- function(d){
  p <- ggplot() +
    # municipality polygons
    geom_polygon(data = d, aes(fill = amount_discrete,
                               x = long,
                               y = lat,
                               group = group)) +
    scale_fill_brewer(palette ="RdYlGn", direction = -1,
                      labels = c("0%"," 0.9%", "1.8%", "2.7%", "3.6%", "4.5%", "5.4%", "6.3%", "7.2%", "7.8%", "10%"),
                      guide = guide_legend(nrow = 1, label.position = "top")) +
    #municipality outline
    geom_path(data = d, aes(x = long,
                            y = lat,
                            group = group),
              color = "grey", size = 0.1) +
    coord_equal() +
    labs(x = "", y = "", title = "") +
    theme_map() +
    theme(legend.position = "bottom") +
    theme(legend.direction =  "horizontal")
  return(p)
}


