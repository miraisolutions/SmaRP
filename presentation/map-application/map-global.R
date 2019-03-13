library(dplyr)
library(magrittr)
library(rgeos)
library(rgdal) # needs gdal > 1.11.0

# links

# https://timogrossenbacher.ch/2016/12/beautiful-thematic-maps-with-ggplot2-only/
# https://blog.derbund.ch/datenblog/index.php/4117/wo-liegt-ihr-steuerparadies

# global variables

# PLZGemeinden -----
PLZGemeinden <- readRDS(system.file("application", "data", "PLZGemeinden.rds", package = "SmaRP"))

# BVGcontriburionratesPath ----

# https://www.admin.ch/opc/de/classified-compilation/19820152/index.html
BVGcontriburionrates <- data.frame(
  lowerbound = c(18, 25, 35, 45, 55),
  upperbound = c(24, 34, 44, 54, 70),
  BVGcontriburionrates = c(0.00, 0.07, 0.10, 0.15, 0.18)
)
# BVGcontriburionrates path
BVGcontriburionratesPath <- data.frame(
  years = seq(BVGcontriburionrates$lowerbound[1], BVGcontriburionrates$upperbound[nrow(BVGcontriburionrates)]),
  BVGcontriburionrates = rep(BVGcontriburionrates$BVGcontriburionrates,
                             times = BVGcontriburionrates$upperbound - BVGcontriburionrates$lowerbound + 1
  )
)

# canton.capital.df -------------------------------------------------------
#DF of cantons and capitals
canton.capital.df <- data.frame("canton" = c("AI","AG","AR","BE","BL","BS","FR","GE","GL","GR","JU","LU","NE","NW","OW",
                                             "SG","SH","SO","SZ","TI","TG","UR","VD","VS","ZG","ZH"),
                                "capital" = c("Appenzell","Aarau","Herisau","Bern","Liestal","Basel","Fribourg","Genève","Glarus","Chur","Delémont","Luzern","Neuchâtel","Stans","Sarnen",
                                              "St. Gallen","Schaffhausen","Solothurn","Schwyz","Bellinzona","Frauenfeld","Altdorf (UR)","Lausanne","Sion","Zug","Zürich"))
canton.capital.df <- canton.capital.df %>%
  left_join(PLZGemeinden, by = c("capital" = "GDENAME")) %>%
  select(one_of(c("capital", "Kanton", "GDENR")))
canton.capital.df <- canton.capital.df[!duplicated(canton.capital.df$Kanton),]


# map --------------------------------------------------------------------

map.file <- "/home/mirai/Desktop/Rprojects/SmaRP/presentation/map-application/data/input/geodata/g1g15.shp"
#map.gemeinde.fullsize <- readOGR(map.file, layer = "g1g15")
#map.gemeinde <- rmapshaper::ms_simplify(map.gemeinde.fullsize)
map.gemeinde <- readOGR(map.file, layer = "g1g15")

# List kantons ------------------------------------------------------------

PLZ <- unique(PLZGemeinden[, c("Kanton", "GDENAME", "GDENR")])
map <- data.frame( "GMDNR" = as.numeric(unique(as.data.frame(map.gemeinde)[, c( "GMDNR")])))
mapPLZ <- map %>% left_join(PLZ, by = c("GMDNR" = "GDENR"))
while (length(which(is.na(mapPLZ$Kanton) > 0))) {
  idx <- which(is.na(mapPLZ$Kanton))
  idx_neigh <- idx - 1
  mapPLZ[idx, "Kanton"] <- mapPLZ[idx_neigh, "Kanton"]
}
