#library(ggmap)
#library(rgdal)
#url = "https://map.geo.admin.ch/?topic=swisstopo&lang=en&bgLayer=voidLayer&zoom=0&layers=ch.swisstopo.swissboundaries3d-gemeinde-flaeche.fill&E=2492310.13&N=1122508.35&catalogNodes=1476,1482"

# library(ggswissmaps)
# maps2_(data = shp_df[[1]]) # Gemeinde ; 8 lakes; 6 cantons


# library("maptools")
# swissmap <- readShapeLines("C:/Users/yourName/YourPath/PLZO_SHP_LV03/PLZO_PLZ.shp")
# plot(swissmap)
# data <- data.frame(swissmap)

# library(rworldmap)
# newmap <- getMap(resolution = "low")
# plot(newmap)

library(rgeos)
library(rgdal) # needs gdal > 1.11.0
library(dplyr)
library(ggplot2)
library(stats)
library(magrittr)


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

# BVGcontriburionratesPath ----

# https://www.admin.ch/opc/de/classified-compilation/19820152/index.html
BVGcontriburionrates <- data.frame(
  lowerbound = c(18, 25, 35, 45, 55),
  upperbound = c(24, 34, 44, 54, 70),
  BVGcontriburionrates = c(0.00, 0.07, 0.10, 0.15, 0.18)
)
# BVGcontriburionrates path
BVGcontriburionratesPath <- data.frame(
  years = seq(BVGcontriburionrates$lowerbound[1], BVGcontriburionrates$upperbound[nrow(BVGcontriburionrates)]),
  BVGcontriburionrates = rep(BVGcontriburionrates$BVGcontriburionrates,
                             times = BVGcontriburionrates$upperbound - BVGcontriburionrates$lowerbound + 1
  )
)

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
#' getTaxAmountGDENR(Income = 200000, rate_group = "C", Age = 32, NKids = 1, postalcode = 9443, churchtax = "Y")
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
              Kids =  NKids * + Kinder ) %>%
      transmute(AjustSalary = NetSalary - Verheiratet - Versicherung - DO - Beruf - Kids)

    TaxAmountFederal <- max(0, lookupTaxRate(TaxableIncomeFederal, BundessteueTabelle,rate_group) - 251*NKids)
    TaxAmount <- TaxAmountFederal + TaxAmountKGC
  } else {
    TaxAmount <- 0
  }
  return(TaxAmount)

}


# Params ------------------------------------------------------------------

Income = 100000
rate_group = "C"
Age = 40
NKids = 2
churchtax = "Y"

source(system.file("application","global.R", package = "SmaRP"))
source("/home/mirai/Desktop/Rprojects/SmaRP/R/TaxBenefit.R")

# canton.capital.df -------------------------------------------------------
#DF of cantons and capitals
canton.capital.df <- data.frame("canton" = c("AI","AG","AR","BE","BL","BS","FR","GE","GL","GR","JU","LU","NE","NW","OW",
                                             "SG","SH","SO","SZ","TI","TG","UR","VD","VS","ZG","ZH"),
                                "capital" = c("Appenzell","Aarau","Herisau","Bern","Liestal","Basel","Fribourg","Genève","Glarus","Chur","Delémont","Luzern","Neuchâtel","Stans","Sarnen",
                                              "St. Gallen","Schaffhausen","Solothurn","Schwyz","Bellinzona","Frauenfeld","Altdorf (UR)","Lausanne","Sion","Zug","Zürich"))
canton.capital.df <- canton.capital.df %>%
  left_join(PLZGemeinden, by = c("capital" = "GDENAME")) %>%
  select(one_of(c("capital", "Kanton", "GDENR")))
canton.capital.df <- canton.capital.df[!duplicated(canton.capital.df$Kanton),]

# Map 2--------------------------------------------------------------------

path2maps2 <- "/home/mirai/Desktop/Rprojects/SmaRP/presentation/thematic-maps-ggplot2/input/geodata//"

#ogrListLayers(paste0(path2maps,swiss.municipalities.lakes.map.file))
map.gemeinde <- readOGR(paste0(path2maps2,"g1g15.shp"), layer = "g1g15")
map.gemeinde.df <- fortify(map.gemeinde) %>%
  mutate(id = as.numeric(id))

gemeindes <- data.frame(id = 0:(length(map.gemeinde@data$GMDNAME) - 1), gemeinde = map.gemeinde@data$GMDNAME, GMDNR = map.gemeinde@data$GMDNR)
map.gemeinde.df <- inner_join(map.gemeinde.df, gemeindes, by = "id")


# List kantons ------------------------------------------------------------

PLZ <- unique(PLZGemeinden[, c("Kanton", "GDENAME", "GDENR")])
map <- data.frame( "GMDNR" = as.numeric(unique(as.data.frame(map.gemeinde)[, c( "GMDNR")])))
mapPLZ <- map %>% left_join(PLZ, by = c("GMDNR" = "GDENR"))
while (length(which(is.na(mapPLZ$Kanton) > 0))) {
  idx <- which(is.na(mapPLZ$Kanton))
  idx_neigh <- idx - 1
  mapPLZ[idx, "Kanton"] <- mapPLZ[idx_neigh, "Kanton"]
}

# Add Tax Amount ----------------------------------------------------------

GMDNR <- unique(map.gemeinde.df$GMDNR)
GMDNAME <- sapply(1:length(GMDNR), function(i){unique(as.character(map.gemeinde.df$gemeinde[map.gemeinde.df$GMDNR == GMDNR[i]]))[1] } )
Taxamount = data.frame("amount" = rep(0,length(unique(map.gemeinde.df$GMDNR))), GMDNR = GMDNR)
Taxamount$amount = sapply(1:length(GMDNR), function(i) {
  getTaxAmountGDENR(Income, rate_group, Age, NKids, GMDNR[i],  GMDNAME[i], churchtax)
})

# for (i in 1:length(unique(map.gemeinde.df$GMDNR))){
#   Taxamount$amount[i] =  getTaxAmountGDENR(Income, rate_group, Age, NKids, GMDNR[i], GMDNAME[i], churchtax)
# }
# min(Taxamount$amount)
# max(Taxamount$amount)
#

Taxamount$amount_percentage <- Taxamount$amount*100/Income

Taxamount$amount_discrete <- cut(Taxamount$amount_percentage,
                                 breaks = c(0, 0.9, 1.8, 2.7, 3.6, 4.5, 5.4, 6.3, 7.2, 7.8, 10.0),
                                 include.lowest = T)

map.gemeinde.df %<>%  inner_join(Taxamount, by = "GMDNR" )


# Plot --------------------------------------------------------------------

p <- ggplot() +
  # municipality polygons
  geom_polygon(data = map.gemeinde.df, aes(fill = amount_discrete,
                                           x = long,
                                           y = lat,
                                           group = group)) +
  scale_fill_brewer(palette = "RdYlGn", direction = -1, name = "",
                    labels = c("0%"," 0.9%", "1.8%", "2.7%", "3.6%", "4.5%", "5.4%",
                               "6.3%", "7.2%", "7.8%", "10%"),
                    guide = guide_legend(nrow = 1, label.position = "top")) +
  #municipality outline
  geom_path(data = map.gemeinde.df, aes(x = long,
                                        y = lat,
                                        group = group),
            color = "grey", size = 0.1) +
  coord_equal() +
  labs(x = "", y = "", title = "") +
  theme_map() +
  theme(legend.direction = "horizontal",
        legend.justification = c(0.2, 0),
        legend.position = c(0.4, 0))
p

ggsave("/home/mirai/Desktop/Rprojects/SmaRP/presentation/municipality_taxAmount.png", p, width = 9, height = 6)

#In small using scripts in the app:
source("/home/mirai/Desktop/Rprojects/SmaRP/presentation/map-application/core.R")
source("/home/mirai/Desktop/Rprojects/SmaRP/presentation/map-application/map-global.R")
source("/home/mirai/Desktop/Rprojects/SmaRP/inst/application/global.R")

options(shiny.sanitize.errors = TRUE)

map.gemeinde.df <-  makeMap(map.gemeinde, Salary = 100000, rate_group = "C", Age = 40, NKids = 2, churchtax = "Y")
p <- makePlot(map.gemeinde.df)
plot(p)



###############-------------#############
#
#
# # World map ---------------------------------------------------------------
#
# world <- map_data("world")
# world <- world[world$region != "Antarctica",]
# Switzerland <-   world[world$region == "Switzerland",]
#
#
# gg <- ggplot()
# gg <- gg + geom_map(data=world, map=world,
#                     aes(x=long, y=lat, map_id=region),
#                     color="white", fill="#7f7f7f", size=0.05, alpha=0.7) +
#   geom_map(data=Switzerland, map=Switzerland,
#            aes(x=long, y=lat, map_id=region),
#            color="white", fill="red", size=0.05, alpha=1)+
#   theme_map() +
#   theme(plot.background = element_rect(fill = "#bde4f9", color = NA))
# gg
# ggsave("/home/mirai/Desktop/Rprojects/SmaRP/presentation/Switzerland.png", gg, width=9, height=6)
