# Global variables

# https://www.admin.ch/opc/de/classified-compilation/19840067/index.html#a12
# https://www.admin.ch/gov/de/start/dokumentation/medienmitteilungen.msg-id-64228.html
BVGMindestzinssatz <<- 0.01

# CHF yield curves
# https://www.six-swiss-exchange.com/services/yield_curves_en.html


# https://www.swissstaffing-bvg.ch/en/employers/contribution_rates.php
BVGcontriburionrates <<- data.frame(lowerbound = c(18, 25, 35, 45, 55),
                                    upperbound = c(24, 34, 44, 54, 65),
                                    BVGcontriburionrates = c(0.012, 0.047, 0.062, 0.087, 0.102))


# https://www.estv.admin.ch/estv/de/home/direkte-bundessteuer/quellensteuer/dienstleistungen/tarife-herunterladen.html
tariffs.list <- list(
  "A Tarif für alleinstehende Personen" = "TA",
  "B Tarif für verheiratete Alleinverdiener" = "TB",
  "C Tarif für verheiratete Doppelverdiener" = "TC")

Kanton.list <- list("Zurich" = "ZH", "St.Gallen" = "SG", "Bern" = "BE")