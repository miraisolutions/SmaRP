# Steuerbelastung (tax burden) in den Gemeinden
# https://www.estv.admin.ch/estv/de/home/allgemein/steuerstatistiken/fachinformationen/steuerbelastungen/steuerbelastung.html#529360841

# # download and safe
# url2download <- "https://www.estv.admin.ch/dam/estv/de/dokumente/allgemein/Dokumentation/Zahlen_fakten/Steuerstatistiken/steuerbelastung/2017/SB-NP-alle-Gden_2017.xlsx.download.xlsx/SB-NP-alle-Gden_de-fr_2017.xlsx"
# filename <- "data//taxdata//Steuerbelastung_2017.xls"
# download.file(url2download, filename)

wb <- XLConnect::loadWorkbook("inst/application/data//taxdata//Steuerbelastung_2017.xls")


.readTaxBurden <- function(wb, sheet) {
  IncomeLevelHeaders <- XLConnect::readWorksheet(wb, sheet = sheet, startRow = 5, endRow = 5, startCol = 4, endCol = 27, header = FALSE, colTypes = "character") %>%
    as.character()
  Headers <- c("Kanton", "Gemeindenummer", "Gemeinde", IncomeLevelHeaders)

  # build tax burden
  # added upper (999.999.999) and lower bounds (0, 12.000) to cover all taxable income
  taxburden <- XLConnect::readWorksheet(wb, sheet = sheet, startRow = 7, startCol = 1, header = FALSE) %>%
    magrittr::set_colnames(Headers) %>%
    dplyr::filter(Kanton %in% kantons) %>%
    dplyr::mutate(
      "0" = 0,
      "12.000" = 0,
      "999.999.999" = .[, ncol(.)]
    ) %>%
    magrittr::extract(c(Headers[1:3], "0", "12.000", IncomeLevelHeaders, "999.999.999"))

  return(taxburden)
}

TarifsName <- c("Ledig", "VOK", "VMK", "DOPMK")
taxburden <- lapply(TarifsName, function(x) .readTaxBurden(wb, x)) %>%
  setNames(sprintf("taxburden_%s", TarifsName))

saveRDS(taxburden, "inst/application/data/taxburden.list.rds")
