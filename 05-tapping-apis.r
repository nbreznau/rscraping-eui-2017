### -----------------------------
### simon munzert
### tapping apis
### -----------------------------

## peparations -------------------

source("00-course-setup.r")
wd <- getwd()



## ready-made R bindings to web APIs ---------

## overview
browseURL("http://ropensci.org/")
browseURL("https://github.com/ropensci/opendata")
browseURL("https://cran.r-project.org/web/views/WebTechnologies.html")


## example: arxiv.org API

# overview and documentation: 
browseURL("http://arxiv.org/help/api/index")
browseURL("http://arxiv.org/help/api/user-manual")

# access api manually:
browseURL("http://export.arxiv.org/api/query?search_query=all:forecast")
forecast <- read_xml("http://export.arxiv.org/api/query?search_query=all:forecast")
xml_ns(forecast) # inspect namespaces
authors <- xml_find_all(forecast, "//d1:author", ns = xml_ns(forecast))
authors %>% xml_text()

# use ready-made binding, the aRxiv package
library(aRxiv)

# overview 
browseURL("http://ropensci.org/tutorials/arxiv_tutorial.html")
ls("package:aRxiv")

# access API with wrapper
?arxiv_search
arxiv_df <- arxiv_search(query = "forecast AND submittedDate:[2016 TO 2017]", limit = 500, output_format = "data.frame")
View(arxiv_df)

arxiv_count('au:"Gary King"')
query_terms

arxiv_count('abs:"political" AND submittedDate:[2016 TO 2017]')
polsci_articles <- arxiv_search('abs:"political" AND submittedDate:[2016 TO 2017]', limit = 500)


#######################
### IT'S YOUR SHOT! ###
#######################

# 1. familiarize yourself with the pageviews package! what functions does it provide and what do they do?
# 2. use the package to fetch page view statistics for the articles about Donald Trump and Hillary Clinton on the English Wikipedia, and plot them against each other in a time series graph!




## accessing APIs from scratch ---------

# most modern APIs use HTTP (HyperText Transfer Protocol) for communication and data transfer between server and client
# R package httr as a good-to-use HTTP client interface
# most web data APIs return data in JSON or XML format
# R packages jsonlite and xml2 good to process JSON or XML-style data

# simple HTTP communication
library(httr)
x <- GET("https://google.com")
x

# if you want to tap an existing API, you have to
  # figure out how it works (what requests/actions are possible, what endpoints exist, what )
  # (register to use the API)
  # formulate queries to the API from within R
  # process the incoming data

## example: connecting with the Open Movie Database API

# information about the API
browseURL("http://www.omdbapi.com/")

# let's try it out
title <- "Groundhog Day" %>% URLencode()
endpoint <- "http://www.omdbapi.com/?"
url <- paste0(endpoint, "t=", title, "&tomatoes=true")
omdb_res = GET(url)
res_list <- content(omdb_res, as =  "parsed")
res_list %>% unlist() %>% t() %>% data.frame(stringsAsFactors = FALSE)

# alternative search
url <- paste0(endpoint, "s=", title)
omdb_res = GET(url)
res_list <- content(omdb_res, as = "text") %>% jsonlite::fromJSON(flatten = TRUE)
res_list$Search

# do we really have to do this manually?
browseURL("https://github.com/hrbrmstr/omdbapi")



#######################
### IT'S YOUR SHOT! ###
#######################

# 1. familiarize yourself with the OpenWeatherMap API!
browseURL("http://openweathermap.org/current")
# 2. sign up for the API at the address below and obtain an API key!
browseURL("http://openweathermap.org/api")
# 3. make a call to the API to find out the current weather conditions in Chicago!





