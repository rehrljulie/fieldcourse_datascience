---
  title: "Webscraping"
execute:
  echo: true
eval: false
output: false
---
  
  ```{r}
library(rvest)
library(readr)
library(RSelenium)
library(netstat)
library(tidyverse)
library(lubridate)
library(zoo)
library(data.table)
```

  
```{r}
URL_wiki <- "https://de.wikipedia.org/wiki/Liste_der_Bezirke_und_Statutarst%C3%A4dte_in_%C3%96sterreich"

page_wiki <- read_html(URL_wiki)

wiki_list <- html_table(page_wiki, header = TRUE)
wiki_staedte <- as.data.frame(wiki_staedte[[1]]) |>
  rename(BKZ = 1)
```
 