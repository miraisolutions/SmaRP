require(pdftools)
require(magrittr)
require(dplyr)
options(stringsAsFactors = FALSE)

# utils ----

.combine_subset_VT_GT <-function(GTtarif, VTtarif) {
  res <- .expandMgTaxTable(GTtarif) %>%
    dplyr::rename(mgRateSingle = mg) %>%
    dplyr::full_join(.expandMgTaxTable(VTtarif) %>%
                       dplyr::rename(mgRateMarried = mg),
                     by = "I") %>%
    dplyr::mutate(taxAmountSingle = cumsum(mgRateSingle),
                  taxAmountMarried = cumsum(mgRateMarried))
  return(res)
}


.helper_cuts_tax <- function(object, colspos){
  res <- object %>% 
    sapply("[", colspos) %>%
    t() %>%
    as.data.frame() %>%
    magrittr::set_colnames(c("cuts", "tax")) %>%
    mutate(cuts = .str2numeric(cuts) ,
           tax = .str2numeric(tax))
}

.str2numeric <- function(x){
  res <- as.numeric(gsub("[^0-9.-]+", "", x))
}

#' @details: colnames(TarifTable) = c("tax", "cuts") 
#' @details: min Income is always 0
.expandMgTaxTable <- function(TarifTable, maxIncome = 1E6, stepsIncome = 100) {
  # create full income's seq to match TarifTable cuts
  I = seq(0, maxIncome, stepsIncome)
  nreps <- match(TarifTable$cuts, I) %>%
    diff()
  # expand tax given cuts
  mg <- lapply(seq_len(length(nreps)), function(i) {
    rep(TarifTable$tax[i], nreps[i])
  }) %>% 
    unlist
  res <- data.frame(I = I[-1],
                    mg = mg)
  return(res)
}



# URLs -----
URLs <- list(
  URL_ZH_KantonTaxRates = "https://www.steueramt.zh.ch/internet/finanzdirektion/ksta/de/steuerberechnung/steuertarife/_jcr_content/contentPar/downloadlist/downloaditems/steuertarife_2017_f_.spooler.download.1519312936206.pdf/Steuertarif_2017_Staatssteuer_Bundessteuer.pdf",
  URL_BE_KantonTaxRates = "http://www.fin.be.ch/fin/de/index/steuern/ratgeber/publikationen/wegleitungen.assetref/dam/documents/FIN/SV/de/Wegleitungen/Aktuelles_Steuerjahr/wl_natuerliche-personen_de.pdf",
  URL_LU_KantonTaxRates =  "http://srl-pdf.lu.ch/620Einkommenstabelle_klein_%C2%A757_01.07.2014_XML.pdf",
  URL_SG_KantonTaxRates = "https://www.steuern.sg.ch/home/sachthemen/eservices/steuerfuesse_im_kanton/_jcr_content/Par/downloadlist/DownloadListPar/download.ocFile/Stg%2010-(Splitting-)%20gerundet_f%C3%BCr_Internet%20V2.pdf",
  URL_TI_KantonTaxRates = "https://www4.ti.ch/fileadmin/DFE/DC/DOC-IPF/2017/Istruzioni_PF__2017.pdf",
  
  URL_UR_GemeindeTaxRates = "http://www.ur.ch/dl.php/de/5a3b5d3790e10/Steuerfuss_EWG_ab2009_18.pdf",
  URL_UR_KirchgemeindenTaxRates = "http://www.ur.ch/dl.php/de/5a3b5d7792502/Steuerfuss_KIG_ab2009_18.pdf",
  URL_SG_GemeindeTaxRates = "https://www.steuern.sg.ch/home/sachthemen/eservices/steuerfuesse_im_kanton/_jcr_content/Par/downloadlist_0/DownloadListPar/download_1920277742.ocFile/Steuerf%C3%BCsse%202017.pdf"
)

lapply(URLs, function(x) {
  download.file(x, paste0("inst//application//data//taxdata//", gsub("URL_", "", x), ".pdf"), mode="wb")
})


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

#saveRDS(BundessteueTabelle, "/Users/fvitalini/Desktop/Mirai/R-scripts/SwissRetirement/SmaRP/inst/application/data/BundessteueTabelle.rds")
saveRDS(BundessteueTabelle, "inst/application/data/BundessteueTabelle.rds")
tax_rates_Kanton_list <- list()
for (k in kantons){
   tax_rates_Kanton_list[[k]]<-  BundessteueTabelle
}
saveRDS(tax_rates_Kanton_list, "inst/application/data/tax_rates_Kanton_list.rds")




#  Kanton ----

# >> ZH ----
.cleanZH <- function(ZH_KantonTaxRates) {
  TarifTable <- ZH_KantonTaxRates %>%
    .[grepl("bis|?ber*", .)] %>%
    strsplit("\\s+") %>%
    .helper_cuts_tax(c(2, 5)) %>%
    rbind(data.frame(cuts = 1E6, tax = 0))
  TarifTable$cuts[1] <- 0
  return(TarifTable)
}

ZH_KantonTaxRates <- pdftools::pdf_text("inst//application//data//taxdata//ZH_KantonTaxRates.pdf") %>%
  strsplit("\n") %>%
  .[[1]] 

GTtarif <- .cleanZH(ZH_KantonTaxRates[1: grep("*Verheiratetentarif (VT)*", ZH_KantonTaxRates)])
VTtarif <- .cleanZH(ZH_KantonTaxRates[grep("*Verheiratetentarif (VT)*", ZH_KantonTaxRates): length(ZH_KantonTaxRates)])

ZH <- .combine_subset_VT_GT(GTtarif, VTtarif) 


# >> BE ----
# All info in page 59
BE_KantonTaxRates <- pdftools::pdf_text("inst//application//data//taxdata//BE_KantonTaxRates.pdf")[59] %>%
  strsplit("\n") %>%
  .[[1]] %>%
  trimws("left") 

# relevant cols in page 59
paircols <- list(c(1, 3), c(4, 6), c(7, 9))

.cleanBE <- function(BE_KantonTaxRates) {
  TarifTable <-  data.frame(cuts = 0, tax = 0) %>%
    rbind( BE_KantonTaxRates %>%
             .[!grepl("[a-z]", .)] %>%
             .[-1] %>%
             strsplit("\\s+") %>%
             lapply(paircols, .helper_cuts_tax, object = .) %>%
             dplyr::bind_rows()) %>%
    rbind(data.frame(cuts = 1E6, tax = 0))
  
  return(TarifTable)
}

GTtarif <- .cleanBE(BE_KantonTaxRates[1:grep("^Verheiratete und Einelternfamilien", BE_KantonTaxRates)]) 
VTtarif <- .cleanBE(BE_KantonTaxRates[grep("^Verheiratete und Einelternfamilien", BE_KantonTaxRates) : grep("^Verm?gen\r", BE_KantonTaxRates)]) 

BE <- .combine_subset_VT_GT(GTtarif, VTtarif) 

# >> LU ----

# >> UR ----

# URI has a flat rate = 0.071
# http://www.ur.ch/de/verwaltung/dienstleistungen/?dienst_id=3196



# >> SZ ----

# >> OW ----

# >> NW ----

# >> GL ----

# >> ZG ----

# >> FR ----

# >> SO ----

# >> BS ----

# >> BL ----

# >> SH ----

# >> AR ----

# >> AI ----

# >> SG ----
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
                mgRateSingle = .str2numeric(mgRateSingle),
                mgRateMarried = .str2numeric(mgRateMarried))

tailSG <- tail(SG_KantonTaxRates, 1)

SG <- data.frame(I = seq(0, 1E6, 100)) %>%
  dplyr::left_join(SG_KantonTaxRates, by = "I") %>%
  dplyr::mutate(mgRateSingle = ifelse(I > tailSG$I, tailSG$mgRateSingle, mgRateSingle),
                mgRateMarried = ifelse(I > tailSG$I, tailSG$mgRateMarried, mgRateMarried),
                mgRateSingle = ifelse(is.na(mgRateSingle), 0 , mgRateSingle),
                mgRateMarried = ifelse(is.na(mgRateMarried), 0 , mgRateMarried),
                taxAmountSingle = cumsum(mgRateSingle),
                taxAmountMarried = cumsum(mgRateMarried))

rm(URL_SG_KantonTaxRates, SG_KantonTaxRates, tailSG)

# >> GR ----

# >> AG ----

# >> TG ----

# >> TI ----

# page 59 ..

# >> VD ----

# >> VS ----

# >> NE ----

# >> GE ----

# >> JU ----

# Gemeinde ----

# >> ZH ----

# TODO: How to dowload csv? See souce code
# CSV from:
# https://statistik.zh.ch/internet/justiz_inneres/statistik/de/daten/daten_oeffentliche_finanzen/gemeindesteuern/gemeindesteuerfuesse.html


# >> BE ----

# >> LU ----

# >> UR ----

# >> SZ ----

# >> OW ----

# >> NW ----

# >> GL ----

# >> ZG ----

# >> FR ----

# >> SO ----

# >> BS ----

# >> BL ----

# >> SH ----

# >> AR ----

# >> AI ----

# >> SG ----
SG_GemeindeTaxRates <- pdftools::pdf_text("inst//application//data//taxdata//SG_GemeindeTaxRates.pdf") %>%
  strsplit("\n")

# >> GR ----

# >> AG ----

# >> TG ----

# >> TI ----

# >> VD ----

# >> VS ----

# >> NE ----

# >> GE ----

# >> JU ----

