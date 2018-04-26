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

fix_nas <- function (x, value = 0) {
  x[is.na(x) | is.infinite(x) | is.nan(x)] = value
  return(x)
}


# URLs -----
URLs <- list(
  URL_AG_GemeindeTaxRates = "https://www.ag.ch/media/kanton_aargau/dfr/dokumente_3/steuern/natuerliche_personen/berechnung_tarife_np/2018_Steuerfuesse1.pdf",
  URL_AG_KantonTaxRates = "https://www.ag.ch/media/kanton_aargau/dfr/dokumente_3/steuern/natuerliche_personen/berechnung_tarife_np/2015_tarif_einkommenssteuer.pdf",
  URL_BE_KantonTaxRates = "http://www.fin.be.ch/fin/de/index/steuern/ratgeber/publikationen/wegleitungen.assetref/dam/documents/FIN/SV/de/Wegleitungen/Aktuelles_Steuerjahr/wl_natuerliche-personen_de.pdf",
  # URL_BS_GemeindeTaxRates = 3 Gemeinde (Basel Stadt, Bettingen, Riehen)
  URL_BS_KantonTaxRates = "http://www.steuerverwaltung.bs.ch/dam/jcr:ac657f62-6da2-41d4-b045-6d486d5b5648/17000_mb_np_tar_ab2014.pdf",
  URL_GE_KantonTaxRates = "https://www.ge.ch/document/7102/telecharger",
  URL_LU_KantonTaxRates =  "http://srl-pdf.lu.ch/620Einkommenstabelle_klein_%C2%A757_01.07.2014_XML.pdf",
  URL_NE_GemeindeTaxRates = "https://www.ne.ch/autorites/DEAS/STAT/domaines/Documents/18_2_5.xlsx",
  URL_NE_KantonTaxRates = "https://www.ne.ch/autorites/DFS/SCCO/Documents/PP/bareme_reference_revenu_coeff100_2017.pdf",
  URL_SG_GemeindeTaxRates = "https://www.steuern.sg.ch/home/sachthemen/eservices/steuerfuesse_im_kanton/_jcr_content/Par/downloadlist_0/DownloadListPar/download_1920277742.ocFile/Steuerf%C3%BCsse%202017.pdf",
  URL_SG_KantonTaxRates = "https://www.steuern.sg.ch/home/sachthemen/eservices/steuerfuesse_im_kanton/_jcr_content/Par/downloadlist/DownloadListPar/download.ocFile/Stg%2010-(Splitting-)%20gerundet_f%C3%BCr_Internet%20V2.pdf",
  URL_SH_GemeindeTaxRates = "https://www.sh.ch/Steuerfuesse-2018.5073.0.html",
  URL_SH_KantonTaxRates = "https://www.sh.ch/fileadmin/Redaktoren/Dokumente/Steuerverwaltung/2010_Einkommenssteuer.pdf",
  URL_SZ_GemeindeTaxRates = "https://www.sz.ch/public/upload/assets/32701/Steuerfusstabelle_2018_Internet.pdf",
  URL_SZ_KantonTaxRates = "https://www.sz.ch/public/upload/assets/18207/stb_90.10_tarif_2015.pdf",
  URL_TI_KantonTaxRates = "https://www4.ti.ch/fileadmin/DFE/DC/DOC-IPF/2017/Istruzioni_PF__2017.pdf",
  URL_UR_GemeindeTaxRates = "http://www.ur.ch/dl.php/de/5a3b5d3790e10/Steuerfuss_EWG_ab2009_18.pdf",
  URL_UR_KirchgemeindenTaxRates = "http://www.ur.ch/dl.php/de/5a3b5d7792502/Steuerfuss_KIG_ab2009_18.pdf",
  URL_VD_GemeindeTaxRates = "https://www.vd.ch/fileadmin/user_upload/organisation/dfin/aci/fichiers_pdf/Impots_communaux_2018.pdf",
  URL_VD_KantonTaxRates = "https://www.vd.ch/fileadmin/user_upload/organisation/dfin/aci/fichiers_pdf/Bareme_revenu_2012_14.pdf",
  URL_VS_GemeindeTaxRates = "https://www.vs.ch/documents/508074/628286/Coefficients_Indexations_Communes_2012-2017.pdf/271f3629-9dff-4b49-b828-0e70fd932549",
  URL_VS_KantonTaxRates = "https://lex.vs.ch/frontend/versions/2125/download_pdf_file",
  URL_ZG_GemeindeTaxRates = "https://www.zg.ch/behoerden/finanzdirektion/steuerverwaltung/steuerfuss/download/steuerfuesse-2018.pdf/download",
  URL_ZG_KantonTaxRates_Married = "https://www.zg.ch/behoerden/finanzdirektion/steuerverwaltung/steuertarif/download/steuertarife-verheiratete-ab-2001/download",
  URL_ZG_KantonTaxRates_Singles = "https://www.zg.ch/behoerden/finanzdirektion/steuerverwaltung/steuertarif/download/steuertarife-alleinstehende-ab-2001/download",
  URL_ZH_KantonTaxRates = "https://www.steueramt.zh.ch/internet/finanzdirektion/ksta/de/steuerberechnung/steuertarife/_jcr_content/contentPar/downloadlist/downloaditems/steuertarife_2017_f_.spooler.download.1519312936206.pdf/Steuertarif_2017_Staatssteuer_Bundessteuer.pdf"
)

# lapply(URLs, function(x) {
#   download.file(x, paste0("data//taxdata//", gsub("URL_", "", names(x)), ".pdf"))
# })
for (u in 1:length(URLs)){#u=1
  url2download <- URLs[[u]]
  filename<- paste0("data//taxdata//",gsub("URL_", "",names(URLs[u])), ".pdf")
  download.file(url2download, filename)
}


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
    .[grepl("bis|über*", .)] %>%
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
VTtarif <- .cleanBE(BE_KantonTaxRates[grep("^Verheiratete und Einelternfamilien", BE_KantonTaxRates) : grep("^Vermögen\r", BE_KantonTaxRates)]) 

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
BaseDFSingle <- data.frame(I = seq(0, 1E6, 100), mgRateSingle=rep(0,1E4+1), taxAmountSingle = rep(0,1E4+1))
BaseDFMarried <- data.frame(I = seq(0, 1E6, 100), mgRateSingle=rep(0,1E4+1), taxAmountSingle = rep(0,1E4+1))
  
  
ZG_KantonTaxRates_Single <- pdftools::pdf_text("data//taxdata/ZG_KantonTaxRates_Singles.pdf") %>%
  strsplit("\n") %>% .[[1]]
x<- ZG_KantonTaxRates_Single[9:23]
res <- sapply(strsplit(x, "\\s+")[1:length(x)], "[", c(1:9)) %>%
  t() %>% 
  as.data.frame(stringsAsFactors = FALSE)
res[15,6] <- res[15,4]
res <- res %>%
  select(c(V2, V6, V9)) %>% #res <- res %>%
  lapply(fix_nas) %>%
  as.data.frame(stringsAsFactors = FALSE) %>%
  magrittr::set_colnames(c("Satz","I", "mgRateSingle")) %>% #res <- res %>%
  mutate(I = gsub("'", "", I) %>% as.numeric(),
         Satz = gsub("[:%:]", "", Satz) %>% as.numeric(),
         mgRateSingle = gsub("'", "", mgRateSingle) %>% as.numeric())

BaseDFSingle %>% left_join(res, by = c("I", "mgRateSingle")) %>%
  


# >> FR ----

# >> SO ----

# >> BS ----

.tmpstep <- function(x, taxAmount="taxAmountSingle", mgRate="mgRateSingle") {
  res <- sapply(strsplit(x, "\\s+")[1:length(x)], "[", c(1:15)) %>%
    t() %>% 
    as.data.frame()
  res <- mapply(c, res[,1:3], res[,4:6], res[,7:9], res[,10:12], res[,13:15] )  %>%
    magrittr::set_colnames(c("I", mgRate,  taxAmount))%>%
    as.data.frame()
  return(res)
}

BS_KantonTaxRates_all <- pdftools::pdf_text("data//taxdata//BS_KantonTaxRates.pdf") %>%
  strsplit("\n")

BS_KantonTaxRates_Single <- BS_KantonTaxRates_all[3:13]%>%
  lapply(function(x) {
  x[!grepl("[a-z]", x) & !grepl("[:%:]", x)] %>%
    trimws("left")})
BS_KantonTaxRates_Single[[1]][1] <- paste0( "0 0 0 ", BS_KantonTaxRates_Single[[1]][1]) 
BS_KantonTaxRates_Single <- BS_KantonTaxRates_Single %>%
  lapply(function(x) {.tmpstep(x, taxAmount="taxAmountSingle", mgRate="mgRateSingle")}) %>% 
  dplyr::bind_rows()
  


BS_KantonTaxRates_Married <- BS_KantonTaxRates_all[14:28] %>%
  lapply(function(x) {
    x[!grepl("[a-z]", x) & !grepl("[:%:]", x)] %>%
      trimws("left") })
BS_KantonTaxRates_Married[[1]][1] <- paste0( "0 0 0 ", BS_KantonTaxRates_Married[[1]][1]) 
BS_KantonTaxRates_Married <- BS_KantonTaxRates_Married %>%
  lapply(function(x) {.tmpstep(x, taxAmount="taxAmountMarried", mgRate="mgRateMarried")}) %>% 
  dplyr::bind_rows() 

BS_KantonTaxRates <- BS_KantonTaxRates_Single %>%
  left_join(BS_KantonTaxRates_Married, by="I") %>%
  dplyr::mutate(I = gsub("'", "", I) %>% as.numeric(),
                mgRateSingle = .str2numeric(mgRateSingle),
                mgRateMarried = .str2numeric(mgRateMarried),
                taxAmountSingle = gsub("'", "", taxAmountSingle) %>% as.numeric(),
                taxAmountMarried = gsub("'", "", taxAmountMarried) %>% as.numeric()) %>%
  lapply(fix_nas) %>%
  as.data.frame()


tailBS <- tail(BS_KantonTaxRates, 1)

BS <- data.frame(I = seq(0, 1E6, 100)) %>%
  dplyr::left_join(BS_KantonTaxRates, by = "I") %>%
  dplyr::mutate(mgRateSingle = ifelse(I > tailBS$I, tailBS$mgRateSingle, mgRateSingle),
                mgRateMarried = ifelse(I > tailBS$I, tailBS$mgRateMarried, mgRateMarried),
                mgRateSingle = ifelse(is.na(mgRateSingle), 0 , mgRateSingle),
                mgRateMarried = ifelse(is.na(mgRateMarried), 0 , mgRateMarried))


rm(URL_BS_KantonTaxRates, BS_KantonTaxRates, tailBS, BS_KantonTaxRates_Married, BS_KantonTaxRates_Single, BS_KantonTaxRates_all)


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

