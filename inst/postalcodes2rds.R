# postalcodes2rds

# List of PLZ and corresponding Gemeinden; 
# source https://www.bfs.admin.ch/bfs/it/home/basi-statistiche/elenco-ufficiale-comuni-svizzera/tabella-corrispondenza-rea.html

fileName <- "data/CorrespondancePostleitzahlGemeinde.xlsx"
PLZGemeinden <- XLConnect::readWorksheetFromFile(file = fileName, sheet = "PLZ6") %>%
  dplyr::select(c(PLZ4, KTKZ, GDENR, GDENAMK)) %>%
  dplyr::rename("PLZ" = "PLZ4", "GDENAME" = "GDENAMK", "Kanton" = "KTKZ")

saveRDS(PLZGemeinden, "data/PLZGemeinden.rds")


# TODO: Add Steuerfuss
PLZGemeinden <- PLZGemeinden %>%
  mutate(Steuerfuss = runif(n = nrow(.), 0.6, 1.4))

saveRDS(PLZGemeinden, "data/PLZGemeinden.rds")
