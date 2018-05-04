library(dplyr)
library(magrittr)

# Global variables

#Gender Bases Retirement age
MRetirementAge <- 65
FRetirementAge <- 64

# https://www.admin.ch/opc/de/classified-compilation/19820152/index.html
# https://www.admin.ch/gov/de/start/dokumentation/medienmitteilungen.msg-id-62487.html
MaxAHV <- 2350 * 12
MinBVG <- MaxAHV * (7/8)
MaxBVG <- MaxAHV * 3
MaxBVGfund <- 10 * MaxBVG

# https://www.admin.ch/opc/de/classified-compilation/19840067/index.html#a12
# https://www.admin.ch/gov/de/start/dokumentation/medienmitteilungen.msg-id-64228.html
BVGMindestzinssatz <<- 0.01


# https://www.ch.ch/en/3rd-pillar/
MaxContrTax <<- 6768  

# https://www.admin.ch/opc/de/classified-compilation/19820152/index.html
BVGcontriburionrates <<- data.frame(lowerbound = c(18, 25, 35, 45, 55),
                                    upperbound = c(24, 34, 44, 54, 70),
                                    BVGcontriburionrates = c(0.00, 0.07, 0.10, 0.15, 0.18))
# BVGcontriburionrates path
BVGcontriburionratesPath <<- data.frame(years = seq(BVGcontriburionrates$lowerbound[1], BVGcontriburionrates$upperbound[nrow(BVGcontriburionrates)]),
                                        BVGcontriburionrates = rep(BVGcontriburionrates$BVGcontriburionrates, 
                                                                   times = BVGcontriburionrates$upperbound - BVGcontriburionrates$lowerbound + 1)) 

Rate_group.list <<- list("Single" = "A",
                        "Married" = "B",
                        "Married Double Income" = "C")

Purchase.list <- list("Single Purchase" = "SingleP2",
                      "Annual Purchase" = "AnnualP2")

#PLZGemeinden <- readRDS("data/PLZGemeinden.rds")
PLZGemeinden <<- readRDS(system.file("application", "data", "PLZGemeinden.rds", package = "SmaRP"))
PLZ.list <<- setNames(PLZGemeinden$PLZ, PLZGemeinden$PLZ)
kantons <<- unique(PLZGemeinden$Kanton)


#tax_rates_Kanton_list <- readRDS("data/tax_rates_Kanton_list_old.rds")
# tax_rates_Kanton_list <- readRDS(system.file("application", "data", "tax_rates_Kanton_list.rds", package = "SmaRP"))

#BundessteueTabelle <- readRDS("inst/application/data/BundessteueTabelle.rds")
# taxburden.list <- readRDS("inst/application/data/taxburden.list.rds") 
BundessteueTabelle <<-  readRDS(system.file("application", "data", "BundessteueTabelle.rds", package = "SmaRP"))
taxburden.list <<- readRDS(system.file("application", "data", "taxburden.list.rds", package = "SmaRP"))

# TODO: Build a table like this with accurate data
KinderabzugKG <<- matrix(data = 9000, nrow = length(kantons), ncol = 10) %>%
  as.data.frame %>%
  set_rownames(kantons) %>%
  set_colnames(seq(1:10))
KinderabzugKG[rownames(KinderabzugKG) == "ZG", ] <- 12000
KinderabzugKG[rownames(KinderabzugKG) == "BS", ] <- 7800
KinderabzugKG[rownames(KinderabzugKG) == "TG", ] <- 7000
KinderabzugKG[rownames(KinderabzugKG) == "LU", ] <- 7200


# TODO: Build a table like this with accurate data (from Steuerfusse in den Kantonhauptorten)
Kirchensteuer <<- unique(PLZGemeinden[, c("Kanton", "FactorKanton", "FactorGemeinde", "FactorKirche")]) %>%
  mutate(Kirchensteuer = (FactorKanton + FactorGemeinde)/ (FactorKanton + FactorGemeinde + FactorKirche))
Kirchensteuer[Kirchensteuer$Kanton == "VS", "Kirchensteuer"] <- 0.97

# Abzuge
AHL <<- 0.0515
ALV <<- 0.011
maxALV <<- 1630.2
VersicherungsL <<- 1700 # übrige mit Vorsorge
VersicherungsV <<- 3500 # Verheitatete mit Vorsorge
VersicherungsK <<- 700
DOV <<- 13400 # assumption: always max
Kinder <<- 6500
Verheiratet <<- 2600
BerufsauslagenTarif <<- 0.03
BerufsauslagenMax <<- 4000
BerufsauslagenMin <<- 2000
NBU <<- 0.0084
maxNBU <<- 1065


#DF of cantons and capitals
canton.capital.df <- data.frame("canton" = c("AI","AG","AR","BE","BL","BS","FR","GE","GL","GR","JU","LU","NE","NW","OW",
                                             "SG","SH","SO","SZ","TI","TG","UR","VD","VS","ZG","ZH"), 
                                "capital" = c("Appenzell","Aarau","Herisau","Bern","Liestal","Basel","Fribourg","Genève","Glarus","Chur","Delémont","Luzern","Neuchâtel","Stans","Sarnen",
                                              "St. Gallen","Schaffhausen","Solothurn","Schwyz","Bellinzona","Frauenfeld","Altdorf (UR)","Lausanne","Sion","Zug","Zürich"))
canton.capital.df <- canton.capital.df %>%
  left_join(PLZGemeinden, by=c("capital"="GDENAME")) %>%
  select(one_of(c("capital", "Kanton", "GDENR")))

canton.capital.df <- canton.capital.df[!duplicated(canton.capital.df$Kanton),]
