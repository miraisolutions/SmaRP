# List of unique kantons
PLZGemeinden <- readRDS("inst/application/data/PLZGemeinden.rds")
kantons <- unique(PLZGemeinden$Kanton)

# Federal tabelle -----
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

require(pdftools)
require(magrittr)
require(dplyr)
options(stringsAsFactors = FALSE)


# SG ----

# >> Kanton ----
URL_SG_KantonTaxRates <- "https://www.steuern.sg.ch/home/sachthemen/eservices/steuerfuesse_im_kanton/_jcr_content/Par/downloadlist/DownloadListPar/download.ocFile/Stg%2010-(Splitting-)%20gerundet_f%C3%BCr_Internet%20V2.pdf"

download.file(URL_SG_KantonTaxRates, "inst//application//data//taxdata//SG_KantonTaxRates.pdf", mode="wb")


.tmpstep <- function(x) {
  res <- sapply(strsplit(x, "\\s+")[1:50], "[", c(1, 3, 5)) %>%
    t() %>% 
    as.data.frame() %>%
    magrittr::set_colnames(c("I", "mgRateSingle", "mgRateMarried"))
  return(res)
}

SG_KantonTaxRates <- pdftools::pdf_text("inst//application//data//taxdata//SG_KantonTaxRates.pdf") %>%
  strsplit("\n") %>%
  lapply(function(x) {
    x[!grepl("[a-z]", x)] %>%
      trimws("left") %>%
      .tmpstep()
  }) %>% 
  .[-1] %>%
  dplyr::bind_rows() %>%
  dplyr::mutate(I = gsub("'", "", I) %>% as.numeric(),
                mgRateSingle = gsub("%", "", mgRateSingle) %>% as.numeric(),
                mgRateMarried = gsub("%", "", mgRateMarried) %>% as.numeric())

tailSG <- tail(SG_KantonTaxRates, 1)

SG <- data.frame(I = seq(0, 1E6, 100)) %>%
  dplyr::left_join(SG_KantonTaxRates, by = "I") %>%
  dplyr::mutate(mgRateSingle = ifelse(I > tailSG$I, tailSG$mgRateSingle, mgRateSingle),
                mgRateMarried = ifelse(I > tailSG$I, tailSG$mgRateMarried, mgRateMarried),
                mgRateSingle = ifelse(is.na(mgRateSingle), 0 , mgRateSingle),
                mgRateMarried = ifelse(is.na(mgRateMarried), 0 , mgRateMarried),
                taxAmountSingle = cumsum(mgRateSingle),
                taxAmountMarried = cumsum(mgRateMarried))

tail(SG)

# >> Gemeinde ----

URL_SG_GemeindeTaxRates <- "https://www.steuern.sg.ch/home/sachthemen/eservices/steuerfuesse_im_kanton/_jcr_content/Par/downloadlist_0/DownloadListPar/download_1920277742.ocFile/Steuerf%C3%BCsse%202017.pdf"
download.file(URL_SG_GemeindeTaxRates, "inst//application//data//taxdata//SG_KantonTaxRates.pdf", mode="wb")

SG_GemeindeTaxRates <- pdftools::pdf_text("inst//application//data//taxdata//SG_GemeindeTaxRates.pdf") %>%
  strsplit("\n")


