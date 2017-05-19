### -----------------------------
### simon munzert
### workflow and good practice
### -----------------------------

## peparations -------------------

source("00-course-setup.r")
wd <- getwd()



## stay friendly on the web ------

# work with informative header fields
# don't bombard server
# respect robots.txt


# add header fields with httr::GET
browseURL("http://httpbin.org")
GET("http://httpbin.org/headers")
GET("http://httpbin.org/headers", add_headers(From = "my@email.com"))
GET("http://httpbin.org/headers", add_headers(From = "my@email.com",
                                              `User-Agent` = R.Version()$version.string))

# example
url_response <- GET("http://spiegel.de/schlagzeilen", 
                    add_headers(From = "my@email.com"))
url_parsed <- url_response  %>% read_html()
url_parsed %>% html_nodes(".schlagzeilen-headline") %>%  html_text()


# add header fields with rvest + httr
url <- "http://spiegel.de/schlagzeilen"
session <- html_session(url, add_headers(From = "my@email.com"))
headlines <- session %>% html_nodes(".schlagzeilen-headline") %>%  html_text()


# don't bombard server

for (i in 1:length(urls_list)) {
  if (!file.exists(paste0(folder, names[i]))) {
    download.file(urls_list[i], destfile = paste0(folder, names[i]))
    Sys.sleep(runif(1, 0, 1))
  }
}

# respect robots.txt
browseURL("https://www.google.com/robots.txt")
browseURL("http://www.nytimes.com/robots.txt")

library(robotstxt)
# more info see here: https://cran.r-project.org/web/packages/robotstxt/vignettes/using_robotstxt.html
paths_allowed("/", "http://google.com/", bot = "*")
paths_allowed("/imgres", "http://google.com/", bot = "*")
paths_allowed("/imgres", "http://google.com/", bot = "Twitterbot")



## interacting with the file system ------

# fully implement a workflow based on relative, not absolute paths
# create a rigid folder structure
# download files in a specific folder
# check whether file exists
# remove temporarily stored files


## functions for folder management ---------

(current_folder <- getwd())
dir.create("data")
dir.create("data/r-data")

# get all pre-compiled data sets
dat <- as.data.frame(data(package = "datasets")$results)
dat$Item %<>% str_replace(" \\(.+\\)", "")

# store data sets in local folder
for (i in 1:50) {
  try(df_out <- dat$Item[i] %>% as.character %>% get)
  save(df_out, file = paste0("data/r-data/", dat$Item[i], ".RData"))
}

# inspect folder
dir("data/r-data")
filenames <- dir("data/r-data", full.names = TRUE)
dir("data/r-data", pattern = "US")
dir("data/r-data", pattern = "US", ignore.case = TRUE)

# check if folder exists
dir.exists("data")


## functions for file management --------
?files

# get basename (= returns the lowest level in a path)
filenames
basename(filenames)
url <- "http://www.mzes.uni-mannheim.de/d7/en/news/media-coverage/ist-die-wahlforschung-in-der-krise-der-undurchschaubare-buerger"
browseURL(url)
basename(url)

# get dirname (returns all but the lower level in a path)
dirname(url)

# get file information
file_inf <- file.info(dir(recursive = F))
?file.info
file_inf[difftime(Sys.time(), file_inf[,"mtime"], units = "days") < 7 , 1:4]


# identify file extension
tools::file_ext(filenames)

# check if file exists
file.exists(filenames)
file.exists("voterfile.RData")

# rename file
filenames_lower <- tolower(filenames)
file.rename(filenames, filenames_lower)

# remove file
file.remove(filenames_lower[1])

# copy file
file.copy(filenames_lower[2], to = "copy.rdata")
file.remove("copy.rdata")

# choose file
(foo <- file.choose())

# compress and unzip files
?zip
?unzip
?tar
?untar

# create temporary files or directories
tempfile()
tempdir()




######################
### IT'S YOUR SHOT ###
######################

# 1. go to the following webpage.
url <- "http://www.cses.org/datacenter/module4/module4.htm"

# 2. the following piece of code identifies all links to resources on the webpage and selects the subset of links that refers to the survey questionnaire PDFs.
library(rvest)
page_links <- read_html(url) %>% html_nodes("a") %>% html_attr("href")
survey_pdfs <- str_subset(page_links, "/survey")

# 3. set up folder data/cses-pdfs.

# 4. download a sample of 10 of the survey questionnaire PDFs into that folder using a for loop and the download.file() function.

# 5. check if the number of files in the folder corresponds with the number of downloads and list the names of the files.

# 6. inspect the files. which is the largest one?

# 7. zip all files into one zip file.



## Scheduling scraping tasks on Windows -------

browseURL("https://cran.r-project.org/web/packages/taskscheduleR/vignettes/taskscheduleR.html")


## Scheduling scraping tasks on a Mac ---------

browseURL("https://developer.apple.com/library/content/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/ScheduledJobs.html")

# 1. create script (e.g., "spiegel_scraper.R")
# 2. add "#!/usr/local/bin/Rscript" to the top of the script
# 3. create plist file
# 4. load plist file into launchd scheduler and start it (via Terminal):
system("launchctl load ~/Library/LaunchAgents/spiegelheadlines.plist")
system("launchctl start spiegelheadlines")
system("launchctl list")

# 5. stop and unload it when desired
system("launchctl stop spiegelheadlines")
system("launchctl unload ~/Library/LaunchAgents/spiegelheadlines.plist")
