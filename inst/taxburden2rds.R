# Steuerbelastung (tax burden) in den Gemeinden
# https://www.estv.admin.ch/estv/de/home/allgemein/steuerstatistiken/fachinformationen/steuerbelastungen/steuerbelastung.html#529360841

# TODO: Improve download
url2download <- "https://www.estv.admin.ch/dam/estv/de/dokumente/allgemein/Dokumentation/Zahlen_fakten/Steuerstatistiken/steuerbelastung/2016/SB-NP-alle-Gden_2016.xlsx.download.xlsx/SB-NP-alle-Gden_de-fr_2016.xlsx"
filename <- "data//taxdata//Steuerbelastung.xls"
download.file(url2download, filename)

wb <- XLConnect::loadWorkbook("inst/application/data//taxdata//Steuerbelastung.xls")
XLConnect::getSheets(wb)

.readTaxBurden <- function(wb, sheet) {
  Headers <- XLConnect::readWorksheet(wb, sheet = sheet, startRow = 5, endRow = 5, startCol = 4, endCol = 27, header = FALSE, colTypes = "character")
  Headers <- c("Kanton", "Gemeindenummer", "Gemeinde", as.character(as.vector(Headers[1,])))
  
  taxburden <- XLConnect::readWorksheet(wb, sheet = sheet, startRow = 7, startCol = 1, header = FALSE) %>%
    magrittr::set_colnames(Headers) %>%
    dplyr::filter(Kanton %in% kantons)
  return(taxburden)
}

rm(wb)

TarifsName = c("Ledig", "VOK", "VMK", "DOPMK")
taxburden <- lapply(TarifsName, function(x) .readTaxBurden(wb, x)) %>%
  setNames(sprintf("taxburden_%s", TarifsName))

saveRDS(taxburden, "inst/application/data/taxburden.list.rds")

