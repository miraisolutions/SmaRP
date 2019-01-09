library(SmaRP)
`%>%` <- magrittr::`%>%`

# Global variables
# Gender-based retirement age
MRetirementAge <- 65
FRetirementAge <- 64

# https://www.admin.ch/opc/de/classified-compilation/19820152/index.html
# https://www.admin.ch/gov/de/start/dokumentation/medienmitteilungen.msg-id-62487.html
MaxAHV <- 2350 * 12
MinBVG <- MaxAHV * (7 / 8)
MaxBVG <- MaxAHV * 3
MaxBVGfund <- 10 * MaxBVG

# https://www.admin.ch/opc/de/classified-compilation/19840067/index.html#a12
# https://www.admin.ch/gov/de/start/dokumentation/medienmitteilungen.msg-id-64228.html
BVGMindestzinssatz <- 0.01


# https://www.ch.ch/en/3rd-pillar/
MaxContrTax <- 6768

# https://www.admin.ch/opc/de/classified-compilation/19820152/index.html
BVGcontributionrates <- data.frame(
  lowerbound = c(18, 25, 35, 45, 55),
  upperbound = c(24, 34, 44, 54, 70),
  BVGcontributionrates = c(0.00, 0.07, 0.10, 0.15, 0.18)
)
# BVGcontributionrates path
BVGcontributionratesPath <- data.frame(
  years = seq(BVGcontributionrates$lowerbound[1], BVGcontributionrates$upperbound[nrow(BVGcontributionrates)]),
  BVGcontributionrates = rep(BVGcontributionrates$BVGcontributionrates,
    times = BVGcontributionrates$upperbound - BVGcontributionrates$lowerbound + 1
  )
)

Rate_group.list <- list(
  "Single" = "A",
  "Married" = "B",
  "Married 2x Income" = "C"
)

church_tax.list <- list(
  "Yes" = "A",
  "None" = "B"
)

Purchase.list <- list(
  "Single" = "SingleP2",
  "Annual" = "AnnualP2"
)

# PLZGemeinden <- readRDS("inst/application/data/PLZGemeinden.rds")
PLZGemeinden <- readRDS(system.file("application", "data", "PLZGemeinden.rds", package = "SmaRP"))
PLZGemeinden$PLZGDENAME <- with(PLZGemeinden, paste(PLZ, GDENAME))
kantons <- unique(PLZGemeinden$Kanton)

# BundessteueTabelle <- readRDS("inst/application/data/BundessteueTabelle.rds")
# taxburden_2016.list <- readRDS("inst/application/data/taxburden.list.rds")
BundessteueTabelle <- readRDS(system.file("application", "data", "BundessteueTabelle.rds", package = "SmaRP"))
taxburden.list <- readRDS(system.file("application", "data", "taxburden_2017.list.rds", package = "SmaRP"))

# Kinderabzuge table
# https://www.estv.admin.ch/dam/estv/de/dokumente/allgemein/Dokumentation/Publikationen/steuermaeppchen/KinderabzugE_de-fr.pdf.download.pdf/KinderabzugE_de-fr.pdf
# - It's assumed that all kids live on their household, attend a public school on their village  and are always 6 years old.
# - BL, VD and VS work differenly and therefore are not accurate.
KinderabzugKG <- matrix(data = 6500, nrow = length(kantons), ncol = 10) %>%
  as.data.frame() %>%
  magrittr::set_rownames(kantons) %>%
  magrittr::set_colnames(seq(1:10))

KinderabzugKG[rownames(KinderabzugKG) == "NW", ] <- 5400
KinderabzugKG[rownames(KinderabzugKG) %in% c("SO", "AR", "GR"), ] <- 6000
KinderabzugKG[rownames(KinderabzugKG) %in% c("TG", "AG", "GL"), ] <- 7000
KinderabzugKG[rownames(KinderabzugKG) %in% c("LU", "SG"), ] <- 7200
KinderabzugKG[rownames(KinderabzugKG) == "VS", ] <- 7510
KinderabzugKG[rownames(KinderabzugKG) == "BS", ] <- 7800
KinderabzugKG[rownames(KinderabzugKG) %in% c("BE", "UR"), ] <- 8000
KinderabzugKG[rownames(KinderabzugKG) %in% c("ZH", "SZ"), ] <- 9000
KinderabzugKG[rownames(KinderabzugKG) == "GE", ] <- 9980
KinderabzugKG[rownames(KinderabzugKG) == "TI", ] <- 11000
KinderabzugKG[rownames(KinderabzugKG) == "ZG", ] <- 12000
KinderabzugKG[rownames(KinderabzugKG) == "FR", ] <- c(8500, 8500, rep(9500, 8))
KinderabzugKG[rownames(KinderabzugKG) == "AI", ] <- c(6000, 6000, rep(8000, 8))
KinderabzugKG[rownames(KinderabzugKG) == "JU", ] <- c(5300, 5300, rep(5900, 8))


# TODO: Build a table like this with accurate data (by now, taken Steuerfusse in den Kantonhauptorten)
Kirchensteuer <- unique(PLZGemeinden[, c("Kanton", "FactorKanton", "FactorGemeinde", "FactorKirche")]) %>%
  dplyr::mutate(Kirchensteuer = (FactorKanton + FactorGemeinde) / (FactorKanton + FactorGemeinde + FactorKirche))
Kirchensteuer[Kirchensteuer$Kanton == "VS", "Kirchensteuer"] <- 0.97

# Abzuge
AHL <- 0.0515
ALV <- 0.011
maxALV <- 1630.2
VersicherungsL <- 1700 # übrige mit Vorsorge
VersicherungsV <- 3500 # Verheitatete mit Vorsorge
VersicherungsK <- 700
DOV <- 13400 # assumption: always max
Kinder <- 6500 #federal Abzug
Verheiratet <- 2600
BerufsauslagenTarif <- 0.03
BerufsauslagenMax <- 4000
BerufsauslagenMin <- 2000
NBU <- 0.0084
maxNBU <- 1065
