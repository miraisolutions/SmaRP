

# Global variables

# https://www.admin.ch/opc/de/classified-compilation/19820152/index.html
# https://www.admin.ch/gov/de/start/dokumentation/medienmitteilungen.msg-id-62487.html
MaxAHV <- 2350 * 12
MinBVG <- MaxAHV * (7/8)
MaxBVG <- MaxAHV * 3
MaxBVGfund <- 10 * MaxBVG

# https://www.admin.ch/opc/de/classified-compilation/19840067/index.html#a12
# https://www.admin.ch/gov/de/start/dokumentation/medienmitteilungen.msg-id-64228.html
BVGMindestzinssatz <<- 0.01

BVGparams <- list(BVGMindestzinssatz = BVGMindestzinssatz,
                   MaxAHV = MaxAHV,
                   MinBVG = MinBVG,
                   MaxBVG = MaxBVG,
                   MaxBVGfund = MaxBVGfund)

# https://www.ch.ch/en/3rd-pillar/
MaxContrTax <<- 6768  

# CHF yield curves
# https://www.six-swiss-exchange.com/services/yield_curves_en.html


# https://www.swissstaffing-bvg.ch/en/employers/contribution_rates.php
# https://www.admin.ch/gov/de/start/dokumentation/medienmitteilungen.msg-id-62487.html
BVGcontriburionrates <<- data.frame(lowerbound = c(18, 25, 35, 45, 55),
                                    upperbound = c(24, 34, 44, 54, 65),
                                    BVGcontriburionrates = c(0.00, 0.07, 0.010, 0.011, 0.13))


# https://www.estv.admin.ch/estv/de/home/direkte-bundessteuer/quellensteuer/dienstleistungen/tarife-herunterladen.html
tariffs.list <- list(
  "A Tarif f?r alleinstehende Personen" = "TA",
  "B Tarif f?r verheiratete Alleinverdiener" = "TB",
  "C Tarif f?r verheiratete Doppelverdiener" = "TC")

Kanton.list <- list("Zurich" = "ZH", "St.Gallen" = "SG", "Bern" = "BE")

Kids.list <- list("No Kids" = "0",
                 "One Kid" = "1",
                 "Two Kids" = "2",
                  "Three or More Kids" = "3")

Rate_group.list <- list("A" = "A",
                        "B" = "B",
                        "C" = "C",
                        "D" = "D",
                        "E" = "E",
                        "H" = "H")

Purchase.list <- list("Single Purchase" = "SingleP2",
                      "Annual Purchase" = "AnnualP2")

#List of PLZ and corresponding Gemeinden; source https://www.bfs.admin.ch/bfs/it/home/basi-statistiche/elenco-ufficiale-comuni-svizzera/tabella-corrispondenza-rea.html

# fileName <- "data/CorrespondancePostleitzahlGemeinde.xlsx"
# PLZGemeinden <- XLConnect::readWorksheetFromFile(file = fileName, sheet = "PLZ6") %>%
#                 select(c(PLZ4, KTKZ, GDENR, GDENAMK)) %>%
#                 rename(PLZ = PLZ4) %>%
#                 rename(GDENAME =GDENAMK) %>%
#                 rename(Kanton =KTKZ)  
#PLZ.list <- setNames(PLZGemeinden$PLZ, PLZGemeinden$PLZ)
  
PLZGemeinden <- readRDS("data/PLZGemeinden.rds")
PLZ.list <- setNames(PLZGemeinden$PLZ, PLZGemeinden$PLZ)

tax_rates_Kanton <- readRDS("data/df_tax_rates_used.rds")

BundessteuerSingle <- data.frame(I = seq(17800, 895900, 100)) %>%
  mutate(mgRate = ifelse(I <= 31600, 0.77, 
                         ifelse(I > 31600 & I <= 41400, 0.88,
                                ifelse(I > 41400 & I <= 55200, 2.64, 
                                       ifelse(I > 55200 & I <= 72500, 2.97, 
                                              ifelse(I > 72500 & I <= 78100, 5.94, 
                                                     ifelse(I > 78100 & I <= 103600, 6.6, 
                                                            ifelse(I > 103600 & I <= 134600, 8.8, 
                                                                   ifelse(I > 134600 & I <= 176000, 11, 
                                                                          ifelse(I > 176000 & I <= 755200, 13.20, 11.5))))))))),
         taxAmount = cumsum(mgRate),
         avgRate = taxAmount / I)


