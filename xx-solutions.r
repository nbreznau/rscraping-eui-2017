### -----------------------------
### simon munzert
### intro to web scraping with R
### solutions to exercises
### -----------------------------


## regular expressions ---------------------------------------

## 1. describe the types of strings that conform to the following regular expressions and construct an example that is matched by the regular expression.
str_extract_all("Phone 150$, PC 690$", "[0-9]+\\$") # example
str_extract_all("Just any sentence, I don't know. Today is a nice day.", "\\b[a-z]{1,4}\\b")
str_extract_all(c("log.txt", "example.html", "bla.txt2"), ".*?\\.txt$")
str_extract_all("log.txt, example.html, bla.txt2", ".*?\\.txt$")
str_extract_all(c("01/01/2000", "1/1/00", "01.01.2000"), "\\d{2}/\\d{2}/\\d{4}")
str_extract_all(c("<br>laufen</br>", "<title>Cameron wins election</title>"), "<(.+?)>.+?</\\1>")

## 2. consider the mail address  chunkylover53[at]aol[dot]com.
# a) transform the string to a standard mail format using regular expressions.
# b) imagine we are trying to extract the digits in the mail address using [:digit:]. explain why this fails and correct the expression.
email <- "chunkylover53[at]aol[dot]com"
email_new <- email %>% str_replace("\\[at\\]", "@") %>% str_replace("\\[dot\\]", ".")
str_extract(email_new, "[:digit:]+")




## scraping static pages ---------------------------------------

# 1. repeat playing CSS diner until plate 10!
# 2. go to the following website
browseURL("https://www.jstatsoft.org/about/editorialTeam")
# a) which CSS identifiers can be used to describe all names of the editorial team?
# b) write a corresponding CSS selector that targets them!

".member a"
"#group a"


# 3. revisit the jstatsoft.org website from above and use rvest to extract the names!
# 4. bonus: try and extract the full lines including the affiliation and count how many of the editors are at a statistics or mathematics department or institution!

url <- "https://www.jstatsoft.org/about/editorialTeam"
url_parsed <- read_html(url)
names <- html_nodes(url_parsed, css = ".member a") %>% html_text()
names <- html_nodes(url_parsed, css = ".member") %>% html_text()
names <- html_nodes(url_parsed, "#group a") %>% html_text()

xpath <- '//div[@id="content"]//li/a'
html_nodes(url_parsed, xpath = xpath) %>% html_text()

affiliations <- html_nodes(url_parsed, ".member li") %>% html_text()
str_detect(affiliations, "tatisti|athemati") %>% table


# 5. Scrape the table tall buildings (300m+) currently under construction from https://en.wikipedia.org/wiki/List_of_tallest_buildings_in_the_world"

url <- "https://en.wikipedia.org/wiki/List_of_tallest_buildings_in_the_world"
url_parsed <- read_html(url)
tables <- html_table(url_parsed, fill = TRUE)
buildings <- tables[[6]]


# 6. How many of those buildings are currently built in China? And in which city are most of the tallest buildings currently built?
table(buildings$`Country/region`) %>% sort
table(buildings$City) %>% sort


# 7. Use SelectorGadget to identify a CSS selector that helps extract all article author names from Buzzfeed's main page!
# 8. Use rvest to scrape these names!

url <- "https://www.buzzfeed.com/?country=us"
url_parsed <- read_html(url)
authors <- html_nodes(url_parsed, css = ".link-gray-lighter .xs-text-6") %>% html_text() %>% str_replace_all("\\n", "") %>% str_trim()
table(authors) %>% sort

# 9. Go to http://earthquaketrack.com/ and make a request for data on earthquakes in "Florence, Italy". Try to parse the results into one character vector! Hint: After filling out a form, you might have to look for a follow-up URL and parse it in a second step to arrive at the data you need.

url <- "http://earthquaketrack.com/"
url_parsed <- read_html(url)
html_form(url_parsed)
earthquake <- html_form(url_parsed)[[1]]

earthquake_form <- set_values(earthquake, q = "Florence, Italy")
uastring <- "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36"
session <- html_session(url, user_agent(uastring))
earthquake_search <- submit_form(session, earthquake_form)
url_parsed <- read_html(earthquake_search)
url_link <- url_parsed %>% html_nodes(".url a") %>% html_attr("href")
url_parsed <- read_html(url_link) %>% html_nodes(".col-sm-4 li") %>% html_text()


## scraping with RSelenium ---------------------------------------

# 1. go to the following webpage and find all Starbucks stores in Chicago that have free WiFi!
# 2. now do the same using Selenium!
# 3. download the data, import it into R and try to plot the stores on a map!

browseURL("http://www.starbucks.com/store-locator/search/location/chicago")

url <- "http://www.starbucks.com/store-locator/search/location/chicago"

# navigate to page
remDr <- remoteDriver(remoteServerAddr = "localhost", port = 4444, browserName = "firefox") 
remDr$open() 
remDr$navigate(url) 

# actions on page
css <- '.filterButton___TxeLm'
click_elem <- remDr$findElement(using = 'css', value = css)
open_elem <- click_elem$clickElement() # click on button

css <- 'li.item___3yAHj:nth-child(6) > button:nth-child(1)'
click_elem <- remDr$findElement(using = 'css', value = css)
open_elem <- click_elem$clickElement() # click on button

# download page
output <- remDr$getPageSource(header = TRUE)
write(output[[1]], file = "starbucks-chicago.html")

# close connection
remDr$closeServer()

# import data
content <- read_html("starbucks-chicago.html", encoding = "utf8") 
store_names <- html_nodes(content, ".truncate") %>% html_text()
store_addresses <- html_nodes(content, ".addressLine___2afjd:nth-child(1)") %>% html_text()

# geocode and map stores
locations <- paste0(store_addresses, ", Chicago, IL")
pos <- geocode(locations, source = "google")
head(pos)

starbucks_map <- get_map(location=c(lon=mean(pos$lon), lat=mean(pos$lat)), zoom=13, maptype="hybrid")
p <- ggmap(starbucks_map) + geom_point(data=pos, aes(x=lon, y=lat), col="red", size=3)
p



## tapping APIs ---------------------------------------

# 1. familiarize yourself with the pageviews package! what functions does it provide and what do they do?
# 2. use the package to fetch page view statistics for the articles about Donald Trump and Hillary Clinton on the English Wikipedia, and plot them against each other in a time series graph!

library(pageviews)
ls("package:pageviews")

trump_views <- article_pageviews(project = "en.wikipedia", article = "Donald Trump", user_type = "user", start = "2016010100", end = "2017051500")
head(trump_views)
clinton_views <- article_pageviews(project = "en.wikipedia", article = "Hillary Clinton", user_type = "user", start = "2016010100", end = "2017051500")

plot(trump_views$date, trump_views$views, col = "red", type = "l")
lines(clinton_views$date, clinton_views$views, col = "blue")


# 3. familiarize yourself with the OpenWeatherMap API!
browseURL("http://openweathermap.org/current")
# 4. sign up for the API at the address below and obtain an API key!
browseURL("http://openweathermap.org/api")
# 5. make a call to the API to find out the current weather conditions in Firenze!

apikey <- "&appid=42c7829f663f87eb05d2f12ab11f2b5d"
endpoint <- "http://api.openweathermap.org/data/2.5/find?"
city <- "Firenze, Italy"
metric <- "&units=metric"
url <- paste0(endpoint, "q=", city, metric, apikey)
weather_res <- GET(url)
res_list <- content(weather_res, as =  "parsed")
res_list <- content(weather_res, as =  "text")  %>% jsonlite::fromJSON(flatten = TRUE)
res_list$list



## workflow ---------------------------------------

# 1. go to the following webpage.
url <- "http://www.cses.org/datacenter/module4/module4.htm"
browseURL(url)

# 2. the following piece of code identifies all links to resources on the webpage and selects the subset of links that refers to the survey questionnaire PDFs.
library(rvest)
page_links <- read_html(url) %>% html_nodes("a") %>% html_attr("href")
survey_pdfs <- str_subset(page_links, "/survey")

# 3. set up folder data/cses-pdfs.
dir.create("data/cses-pdfs", recursive = TRUE)

# 4. download a sample of 10 of the survey questionnaire PDFs into that folder using a for loop and the download.file() function.
baseurl <- "http://www.cses.org"
for (i in 1:10) {
  filename <- basename(survey_pdfs[i])
  if(!file.exists(paste0("data/cses-pdfs/", filename))){
    download.file(paste0(baseurl, survey_pdfs[i]), destfile = paste0("data/cses-pdfs/", filename))
    Sys.sleep(runif(1, 0, 1))
  }
}

# 5. check if the number of files in the folder corresponds with the number of downloads and list the names of the files.
length(list.files("data/cses-pdfs"))
list.files("data/cses-pdfs")

# 6. inspect the files. which is the largest one?
file.info(dir("data/cses-pdfs", full.names = TRUE)) %>% View()

# 7. zip all files into one zip file.
zip("data/cses-pdfs/cses-mod4-questionnaires.zip", dir("data/cses-pdfs", full.names = TRUE))

