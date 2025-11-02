library(rvest)
library(readr)
library(RSelenium)
library(netstat)
library(tidyverse)
library(lubridate)
library(zoo)
library(data.table)

URL_wh <- "https://www.willhaben.at/iad/immobilien/mietwohnungen/wien?rows=90&page=1"

page_wh <- read_html(URL_wh)

anzahl_anzeigen <- page_wh |>
  html_elements("#result-list-title") |>
  html_text2() |>
  parse_number(locale = locale(grouping_mark = ".", decimal_mark = ",")) |>
  as.integer()

anzahl_pages <- ceiling(anzahl_anzeigen/90)

anzeigen_Adresse <- page_wh |>
  html_elements('[data-testid^="search-result-entry-subheader"]') |>
  html_elements("span") |> # here we select by tag a
  html_text() |> # here we extract the tet inside the tag
  as.data.frame() |>
  rename("Adressen" = 1)

#search-result-entry-header-1945602182  
  
  