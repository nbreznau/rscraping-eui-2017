### -----------------------------
### workshop setup
### simon munzert
### -----------------------------


# install packages from CRAN
p_needed <- c("magrittr", "plyr", "dplyr", "stringr", "stringi", "pdftools", "lubridate", "jsonlite", "httr", "xml2", "rvest", "devtools", "ggmap",  "networkD3", "RSelenium", "pageviews", "aRxiv", "twitteR", "streamR", "ROAuth", "gtrendsR", "robotstxt")
packages <- rownames(installed.packages())
p_to_install <- p_needed[!(p_needed %in% packages)]
if (length(p_to_install) > 0) {
  install.packages(p_to_install)
}

lapply(p_needed, require, character.only = TRUE)

# in case Rselenium is not available for your R version (mine was 3.5.1), this is a workaround
library(devtools)
install_version("binman", version = "0.1.0", repos = "https://cran.uni-muenster.de/")
install_version("wdman", version = "0.2.2", repos = "https://cran.uni-muenster.de/")
install_version("RSelenium", version = "1.7.1", repos = "https://cran.uni-muenster.de/")
