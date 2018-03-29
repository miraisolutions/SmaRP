# List of unique kantons
PLZGemeinden <- readRDS("inst/application/data/PLZGemeinden.rds")
kantons <- unique(PLZGemeinden$Kanton)

#Federal tabelle
BundessteueTabelle <- data.frame(I = seq(0, 1000000, 100)) %>%
  mutate(mgRateSingle = ifelse(I <= 17800, 0,
                               ifelse(I > 17800 & I <= 31600, 0.77, 
                                      ifelse(I > 31600 & I <= 41400, 0.88,
                                             ifelse(I > 41400 & I <= 55200, 2.64, 
                                                    ifelse(I > 55200 & I <= 72500, 2.97, 
                                                           ifelse(I > 72500 & I <= 78100, 5.94, 
                                                                  ifelse(I > 78100 & I <= 103600, 6.6, 
                                                                         ifelse(I > 103600 & I <= 134600, 8.8, 
                                                                                ifelse(I > 134600 & I <= 176000, 11, 
                                                                                       ifelse(I > 176000 & I <= 755200, 13.20, 11.5)))))))))),
         taxAmountSingle = cumsum(mgRateSingle),
         mgRateMarried = ifelse(I <= 29000, 0,
                                ifelse(I > 29000 & I <= 50900, 1, 
                                       ifelse(I > 50900 & I <= 58400, 2,
                                              ifelse(I > 58400 & I <= 75300, 3, 
                                                     ifelse(I > 75300 & I <= 90300, 4, 
                                                            ifelse(I > 90300 & I <= 103400, 5, 
                                                                   ifelse(I > 103400 & I <= 114700, 6, 
                                                                          ifelse(I > 114700 & I <= 124200, 7, 
                                                                                 ifelse(I > 124200 & I <= 131700, 8, 
                                                                                        ifelse(I > 131700 & I <= 137300, 9, 
                                                                                               ifelse(I > 137300 & I<= 141200, 10, 
                                                                                                      ifelse(I > 141200 & I <= 143100, 11, 
                                                                                                             ifelse(I > 143100 & I <= 145000, 12, 
                                                                                                                    ifelse(I > 145000 & I <= 895800, 13, 11.5)))))))))))))),
         taxAmountMarried = cumsum(mgRateMarried))

saveRDS(tax_rates_Kanton_list, "inst/application/data/BundessteueTabelle.rds")
tax_rates_Kanton_list <- list()
for (k in kantons){
   tax_rates_Kanton_list[[k]]<-  BundessteueTabelle
}
saveRDS(tax_rates_Kanton_list, "inst/application/data/tax_rates_Kanton_list.rds")


