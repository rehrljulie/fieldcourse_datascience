library(rvest)
library(readr)
library(RSelenium)
library(netstat)
library(tidyverse)
library(lubridate)
library(zoo)
library(data.table)

URL_si <- paste0("https://immobilien.derstandard.at/suche/wien/mieten-wohnung?page=1")

page_si <- read_html(URL_si)

anzahl_pages <- page_si |>
  html_elements(".pagination--list.pagination-list") |>
  html_elements("button") |>
  html_text2() |>
  as.data.frame() |>
  tail(1) |>
  as.integer()

data_anzeigen <- data.frame(
  Adresse = character(),
  PLZ = numeric(),
  Preis = numeric(),
  Fläche = numeric(),
  Zimmer = numeric()
) |>
  setNames(c("Adresse", "PLZ", "Preis in €", "Fläche in m²", "Anzahl Zimmer"))

for(i in 1:anzahl_pages){

URL_si_i <- paste0("https://immobilien.derstandard.at/suche/wien/mieten-wohnung?page=",i)

page_si_i <- read_html(URL_si_i)

anzeigen_Adresse <- page_si_i |>
  html_elements(".sc-listing-card-title.sc-listing-card-title-small.sc-listing-card-title-default") |>
  html_text() |> # here we extract the tet inside the tag
  as.data.frame() |>
  rename("Adresse" = 1)

anzeigen_PLZ <- as.data.frame(str_extract(anzeigen_Adresse$Adresse, "^\\s*\\d{4}") %>% readr::parse_integer()) |>
  rename ("PLZ" = 1)

anzeigen_details <- page_si_i |>
  html_elements(".sc-responsive-render-base.sc-responsive-render-display-block.sc-responsive-render-base-next-md") |>
  html_elements(".sc-listing-card-footer-item.sc-listing-card-footer-item-default") |>
  html_text2() |> # here we extract the tet inside the tag
  str_squish()

anzeigen_details_df <- matrix(anzeigen_details, ncol = 3, byrow = TRUE) |>
  as_tibble(.name_repair = "minimal") |>
  setNames(c("Preis", "Fläche", "Zimmer")) |>
  mutate(
    # "€ 2.240,00" -> 2240.00  (German separators)
    Preis = parse_number(Preis, locale = locale(grouping_mark = ".", decimal_mark = ",")),
    
    Flaeche_bereinigt = Fläche |>
      str_replace_all("\\u00A0", " ") |>
      str_remove_all("(?:\\s|\\u00A0)*(m\\s*(?:²|2|\\^2)|qm)\\b") |>
      str_squish(),
    
    # "108.43 m²" or "108,43 m²" -> 108.43
    Flaeche_m2 = coalesce(
      parse_number(Flaeche_bereinigt),                                                     # dot decimal
      parse_number(Flaeche_bereinigt, locale = locale(decimal_mark = ",", grouping_mark=".")) # comma decimal
    ),
    
    # "3 Zimmer" -> 3
    Zimmer = parse_number(Zimmer)
  ) |>
  select(Preis, Flaeche_m2, Zimmer)|>
  setNames(c("Preis in €", "Fläche in m²", "Anzahl Zimmer"))

anzeigen_gesamt <- cbind(anzeigen_Adresse, anzeigen_PLZ, anzeigen_details_df)

data_anzeigen <- data_anzeigen |> add_row(anzeigen_gesamt)

if (i %% 1 == 0) {
  print(paste0("Total: ", anzahl_pages, ", Current: ", i))
}
}

