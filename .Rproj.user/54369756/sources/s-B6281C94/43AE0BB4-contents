Temperature changes in Warsaw 2004-2019
================

``` r
# Load packages
library(data.table)
library(dplyr)
library(naniar)
library(lubridate)
library(ggplot2)
```

Load data
=========

Data was downloaded manually from <https://dane.imgw.pl/> and I stored them in 'data-raw' folder.

``` r
# specify location
path <- './data-raw/'

# function for batch .csv upload
do.call_rbind_fread <- function(path, pattern = "*.csv") {
  files = list.files(path, pattern, full.names = TRUE)
  do.call(rbind, lapply(files, function(x) fread(x, stringsAsFactors = FALSE)))
}

x <- do.call_rbind_fread(path)
dim(x)
```

    ## [1] 140256    107

The dataset contained over 140000 rows and 107 columns. Unfortunately tables did not contain column names, so I needed to enter them manually ( I will skip that ugly part).

This is all about temperature so let's select the right columns and translate them to english.

``` r
temp <- x %>% select('Rok', 'Miesiac', 'Dzien', 'Godzina', 'Temperatura powietrza')
colnames(temp) <- c("year", "month", "day", "hour", "air_temp")
```

Explore data
============

Missing values
--------------

naniar package is nice for missing data visualisation.

And this is great as we have a complete dataset! Let's explore it further. \#\# Temperature values distribution ![](temp_waw_eda_files/figure-markdown_github/unnamed-chunk-6-1.png) That's quite interesting. We see a bimodal distribution across most of the years (summer and winter? what about spring and autumn? do we still have 4 seasons?). 2012 looks like it had the most moderate temperatures as it is flat at the top. Anyway, let's split it by seasons. Let's assume that winter is 21-Dec - 20 Mar, spring 21-Mar - 20 Jun, summer 21-Jun - 20-Sep, Autumn 21-Sep - 20-Dec

``` r
temp_season <- temp %>%
  mutate(
    month = as.integer(month),
    day = as.integer(day),
    season = case_when(
    month == 12 & day >= 21 ~ "winter",
    month %in% c(1,2) ~ "winter",
    month == 3 & day < 21~ "winter",
    month == 3 & day >= 21 ~ "spring",
    month %in% c(4,5) ~ "spring",
    month == 6 & day < 21~ "spring",
    month == 6 & day >= 21 ~ "summer",
    month %in% c(7,8) ~ "summer",
    month == 9 & day < 21~ "summer",
    month == 9 & day >= 21 ~ "autumn",
    month %in% c(10,11) ~ "autumn",
    month == 12 & day < 21~ "autumn",
    TRUE ~ NA_character_
  ))
temp_season_median <- temp_season %>% 
  group_by(season, year) %>% 
  summarise(median = median(air_temp))

temp_season %>% 
  ggplot(aes(x=air_temp, color = as.factor(year)))+
  geom_density(alpha = .3)+
  facet_wrap(~season)+
  labs(color = "year")
```

![](temp_waw_eda_files/figure-markdown_github/unnamed-chunk-7-1.png) It looks like summer is the most stable season. There is a lot of variation in other seasons across the years. How it will look like when we split it by year: ![](temp_waw_eda_files/figure-markdown_github/unnamed-chunk-8-1.png) Red vertical line inticates the median values per season of each year. It's difficult to see the trend on this. Lets try another way: ![](temp_waw_eda_files/figure-markdown_github/unnamed-chunk-9-1.png) Yep, the median temperature of all the seasons generally increases in time.

![](temp_waw_eda_files/figure-markdown_github/unnamed-chunk-10-1.png)
