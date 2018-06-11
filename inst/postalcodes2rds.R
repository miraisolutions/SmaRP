# postalcodes2rds

# Script to create the PLZGemeinden table and make it available in SmaRP
# source:
# https://www.bfs.admin.ch/bfs/de/home/grundlagen/agvch/gwr-korrespondenztabelle.html

# read original
fileName <- "inst/application/data/CorrespondancePostleitzahlGemeinde.xlsx"
PLZGemeindenOri <- XLConnect::readWorksheetFromFile(file = fileName, sheet = "PLZ4") %>%
  magrittr::set_colnames(c("PLZ", "PerGDE" ,"Kanton", "GDENR", "GDENAME"))

# There are postal codes assign to several gemeinden given a percentage (PerGDE)
# Since we want a relation 1-1 postalcode - gemeinde, we have to apply some filtering criteria
# 1. Given a postalcode, select the gemeinde with higher percentage
PLZGemeinden <- dplyr::inner_join(PLZGemeindenOri,
                                  PLZGemeindenOri %>%
                                    dplyr::group_by(PLZ) %>%
                                    dplyr::summarise(maxPerGDE = max(PerGDE)),
                                  by = c("PLZ" = "PLZ", "PerGDE" = "maxPerGDE")) 

# 2. In case equally distributed gemeinden, we take the one with the higher gemeinde number.
# Applies only in 1 case 
# PLZGemeindenOri %>% subset(PLZ == "2933")
PLZGemeinden <- dplyr::inner_join(PLZGemeinden,
                                  PLZGemeinden %>%
                                    group_by(PLZ) %>%
                                    summarise(maxGDENR = max(GDENR)),
                                  by = c("PLZ" = "PLZ", "GDENR" = "maxGDENR"))

# check there are not missing postal codes
assertthat::are_equal(unique(PLZGemeindenOri$PLZ), PLZGemeinden$PLZ)

# check duplicates per postalcode
assertthat::assert_that(!any(duplicated(PLZGemeinden$PLZ)))

# add info with Steuernfuesse per Kanton for Churh tax
# source:
# https://www.estv.admin.ch/dam/estv/de/dokumente/allgemein/Dokumentation/Publikationen/dossier_steuerinformationen/e/Steuersatz-Steuerfuss_2016.pdf.download.pdf/Steuersatz-Steuerfuss_de_2016.pdf

# Assumptions:
# Per Gemeinde add the Kantonsteuer Factor, the Gemeindesteuer Factor and the Kirchesteuerfactor
# For the time being we use one value for all Gemeinden in one Kanton
# For the time being we do not distinguish between Evangelische Kirche and Roeman-katolische Kirche: the highest facto is used when different
# We consider only taxes on the Income (No Assets) - Affects cantosn FR and BL
# When Kirchesteuer depends on the taxrate, we make an approximation (relevant for kantons: VS, BS, BL)

GemeindeFactorTabelle <- data.frame(
  "Kanton" = unique(PLZGemeinden$Kanton),
  "FactorKanton" = rep(1, length(unique(PLZGemeinden$Kanton))),
  "FactorGemeinde" = rep(1, length(unique(PLZGemeinden$Kanton))),
  "FactorKirche" = rep(1, length(unique(PLZGemeinden$Kanton))),
  stringsAsFactors = FALSE
) 

Factorcols<- c("FactorKanton", "FactorGemeinde", "FactorKirche")
GemeindeFactorTabelle[GemeindeFactorTabelle$Kanton=="ZH", Factorcols] <- c(1,1.19, 0.1)
GemeindeFactorTabelle[GemeindeFactorTabelle$Kanton=="BE", Factorcols] <- c(3.06,1.54, 0.207)
GemeindeFactorTabelle[GemeindeFactorTabelle$Kanton=="LU", Factorcols] <- c(1.6,1.85, 0.25)
GemeindeFactorTabelle[GemeindeFactorTabelle$Kanton=="UR", Factorcols] <- c(1,0.97, 1.2)
GemeindeFactorTabelle[GemeindeFactorTabelle$Kanton=="SZ", Factorcols] <- c(1.7,2.25, 0.3)
GemeindeFactorTabelle[GemeindeFactorTabelle$Kanton=="OW", Factorcols] <- c(3.05,4.06, 0.54)
GemeindeFactorTabelle[GemeindeFactorTabelle$Kanton=="NW", Factorcols] <- c(2.66,2.45, 0.35)
GemeindeFactorTabelle[GemeindeFactorTabelle$Kanton=="GL", Factorcols] <- c(0.53,0.63, 0.09)
GemeindeFactorTabelle[GemeindeFactorTabelle$Kanton=="ZG", Factorcols] <- c(0.82,0.6, 0.095)
GemeindeFactorTabelle[GemeindeFactorTabelle$Kanton=="FR", Factorcols] <- c(1,0.81, 0.09)
GemeindeFactorTabelle[GemeindeFactorTabelle$Kanton=="SO", Factorcols] <- c(1.04,1.15, 0.21)
GemeindeFactorTabelle[GemeindeFactorTabelle$Kanton=="BS", Factorcols] <- c(1,0, 0.08)
GemeindeFactorTabelle[GemeindeFactorTabelle$Kanton=="BL", Factorcols] <- c(1,0.65, 0.068)
GemeindeFactorTabelle[GemeindeFactorTabelle$Kanton=="SH", Factorcols] <- c(1.15,0.97, 0.145)
GemeindeFactorTabelle[GemeindeFactorTabelle$Kanton=="AR", Factorcols] <- c(3.2, 4.1, 0.5)
GemeindeFactorTabelle[GemeindeFactorTabelle$Kanton=="AI", Factorcols] <- c(0.96,0.71, 0.1)
GemeindeFactorTabelle[GemeindeFactorTabelle$Kanton=="SG", Factorcols] <- c(1.15,1.44, 0.26)
GemeindeFactorTabelle[GemeindeFactorTabelle$Kanton=="GR", Factorcols] <- c(1,0.9, 0.145)
GemeindeFactorTabelle[GemeindeFactorTabelle$Kanton=="AG", Factorcols] <- c(1.09,0.97, 0.18)
GemeindeFactorTabelle[GemeindeFactorTabelle$Kanton=="TG", Factorcols] <- c(1.17,1.46, 0.16)
GemeindeFactorTabelle[GemeindeFactorTabelle$Kanton=="TI", Factorcols] <- c(1,0.95, 0)
GemeindeFactorTabelle[GemeindeFactorTabelle$Kanton=="VD", Factorcols] <- c(1.545,0.79, 0)
GemeindeFactorTabelle[GemeindeFactorTabelle$Kanton=="VS", Factorcols] <- c(1,1.1, 3.3)
GemeindeFactorTabelle[GemeindeFactorTabelle$Kanton=="NE", Factorcols] <- c(1.23,0.67, 0)
GemeindeFactorTabelle[GemeindeFactorTabelle$Kanton=="GE", Factorcols] <- c(0.485,0.455, 0)
GemeindeFactorTabelle[GemeindeFactorTabelle$Kanton=="JU", Factorcols] <- c(2.85,1.9, 0.081)

# join PLZGemeinden and GemeindeFactorTabelle 
PLZGemeinden <- PLZGemeinden %>% 
  dplyr::left_join(GemeindeFactorTabelle,
                   by = "Kanton") %>% 
  dplyr::select(-PerGDE)

# save PLZGemeinden as RDS  
saveRDS(PLZGemeinden, "inst/application/data/PLZGemeinden.rds")
