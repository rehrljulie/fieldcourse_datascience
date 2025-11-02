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



selenium_server <- rsDriver(
  browserName = "chrome",
  chromever = NULL,
  port = 8090L,
  verbose = FALSE,
)
client <- selenium_server$client  

