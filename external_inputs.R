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

Kids.list <- list("No Kids" = "0kid",
                 "One Kid" = "1kid",
                 "Two Kids" = "2kid",
                  "Three + Kids" = "3Kid")

Purchase.list <- list("Single Purchase" = "SingleP2",
                      "Annual Purchase" = "AnnualP2")