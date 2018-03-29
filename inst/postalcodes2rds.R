# postalcodes2rds

# Download Mapping PLZ Gemainde -------------------------------------------


# List of PLZ and corresponding Gemeinden; 
# source https://www.bfs.admin.ch/bfs/it/home/basi-statistiche/elenco-ufficiale-comuni-svizzera/tabella-corrispondenza-rea.html

fileName <- "data/CorrespondancePostleitzahlGemeinde.xlsx"
PLZGemeinden <- XLConnect::readWorksheetFromFile(file = fileName, sheet = "PLZ6") %>%
  dplyr::select(c(PLZ4, KTKZ, GDENR, GDENAMK)) %>%
  dplyr::rename("PLZ" = "PLZ4", "GDENAME" = "GDENAMK", "Kanton" = "KTKZ")

# Define dummy table with Steuernfuesse per Kanton ------------------------------

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
        "FactorKirche" = rep(1, length(unique(PLZGemeinden$Kanton)))
) 

GemeindeFactorTabelle %<>% arrange(Kanton)
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

# Join Steuerfuesse per Kanton and PLZ ------------------------------------

# Old Approach
# PLZGemeinden <- PLZGemeinden %>%
#   mutate(Steuerfuss = runif(n = nrow(.), 0.6, 1.4))

PLZGemeinden %<>% left_join(GemeindeFactorTabelle)

saveRDS(PLZGemeinden, "inst/application/data/PLZGemeinden.rds")
