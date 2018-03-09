
require(magrittr)
require(dplyr)

path2rawData <-"data/raw1"
rawData <- "/raw1.zip"

unzip(paste0(path2rawData, rawData), exdir = path2rawData)

collectedData <- data.frame()

taxRecordTxtFiles <- file.path(path2rawData, list.files(path2rawData)) %>%
  grep(pattern = "\\.txt$", value = TRUE)
for (taxFile in taxRecordTxtFiles) {
  rawData <- read.fwf(
    taxFile,
    widths = c(2, 2, 2, 1, 1, 1, 7, 8, 9, 9, 1, 2, 9, 5, 3),
    col.names = c("record_type", "trans_type", "canton",
                  "rate_group", "n_kids", "churchtax",
                  "dummy1", "valid_from", "income",
                  "tax_step", "gender", "n_kids2",
                  "tax", "tax_rate", "dummy2"),
    # data is not consistent enough to read colums
    # in their correct data type
    colClasses = "character" 
  ) %>%
    # we're only interested in recort types for natural people
    filter(record_type == "06") %>%
    # only people actually living in switzerland
    filter(rate_group %in% c(LETTERS[1:5], "H")) %>%
    mutate(
      n_kids = as.integer(n_kids),
      valid_from = as.integer(valid_from),
      income = as.integer(income),
      tax_step = as.integer(tax_step),
      n_kids2 = as.integer(n_kids2),
      tax = as.integer(tax),
      tax_rate = as.integer(tax_rate)
    )
  
  # dq checks
  with(rawData, {
    stopifnot(all(trans_type %in% c("01", "02", "03")))
    stopifnot(length(unique(canton)) == 1L)
    stopifnot(all(n_kids %in% 0:9))
    stopifnot(all(n_kids == n_kids2))
    stopifnot(all(churchtax %in% c("Y", "N")))
    stopifnot(all(dummy1 == "       "))
    stopifnot(all(!is.na(valid_from)))
    stopifnot(all(!is.na(income)))
    stopifnot(all(!is.na(tax_step)))
    stopifnot(all(gender == " "))
    stopifnot(all(!is.na(tax)))
    stopifnot(all(!is.na(tax_rate)))
    stopifnot(all(dummy2 == "   "))
  })
  
  if (unique(rawData$trans_type) != "01") browser()
  
  # monetary values are entered in Rappen
  relevantData <- rawData %>%
    select(canton, rate_group, n_kids, churchtax, income, tax_step, tax, tax_rate)
  
  stopifnot(!any(duplicated.data.frame(relevantData)))
  
  collectedData <- rbind(collectedData, relevantData)
}

# drop Rappen granularity (note that Glarus seems to still use Rappen in its tax column)
collectedData <- collectedData %>% 
  mutate(
    income = income / 100,
    tax_step = tax_step / 100,
    tax = tax / 100
  )


# full data
# saveRDS(collectedData, "data/df_tax_rates_full.rds")


# data exploration (they don't always provide both tax and tax_rate and
# cantons differ in their approaches, this is to figure out the most common formula)
test <- collectedData %>%
  filter(tax != 0 & tax_rate != 0) %>%
  mutate(
    # Glarus has granularity on Rappen, but calculates using CHF level...
    tax_median_rate = 1e4 * round(tax + 0.01) / (income - 1 + tax_step / 2),
    tax_median_round_rate = round(tax_median_rate),
    tax_high_rate = 1e4 * round(tax + 0.01) / income,
    tax_high_round_rate = round(tax_high_rate),
    tax_low_rate = 1e4 * round(tax + 0.01) / (income - 1 + tax_step),
    tax_low_round_rate = round(tax_low_rate)
  ) %>%
  mutate(
    match_median = tax_rate == tax_median_round_rate,
    match10_median = tax_rate == round(tax_median_round_rate / 10) * 10,
    match_low = tax_rate == tax_low_round_rate,
    any_match = match_median | match10_median | match_low
  )

# some weird cases / errors ?
test[!test$any_match, ] %>%
  mutate(
    highdiff = abs(tax_high_round_rate - tax_rate),
    lowdiff = abs(tax_low_round_rate - tax_rate)
  ) %>%
  filter(highdiff > 1 & lowdiff > 1)

# about 0.6% of the cases don't match this condition
test %>%
  mutate(diff = abs(tax_median_round_rate - tax_rate)) %>%
  filter(diff > 1) %>%
  nrow()

# conclusion:
# calculation of tax_rate is inconsistent:
# - Glarus has tax in Rappen granularity, but seems to use the rounded version
# - most tax rates are calculated using the mean of the income interval, but some use the lower or upper bound
# - Aargau and Zug round e.g. 16 CHF to 20 CHF ...
# - very few other weird cases

calcData <- collectedData %>%
  mutate(
    # the median approach matches most cases,
    # so we'll use that to calculate missing tax rates
    tax_rate_calc = round(1e4 * round(tax + 0.01) / (income - 1 + tax_step / 2)),
    # to fill cases where official tax_rate is present
    tax_present = tax_rate != 0
  )

calcData[calcData$tax_present, "tax_rate_calc"] <- calcData[calcData$tax_present, "tax_rate"]

calcData <- calcData %>%
  select(canton, rate_group, n_kids, churchtax, income, tax_step, tax_rate_calc)

saveRDS(calcData, "data/df_tax_rates.rds")
# write.table(calcData, "data/canton_tax_rates.csv", sep = ",", row.names = FALSE, quote = FALSE)

# Subset only relevant tax rates 
calcData <- calcData %>%
  filter(rate_group %in% c("A", "B", "C") & n_kids < 6)
saveRDS(calcData, "data/df_tax_rates_used.rds")



  

