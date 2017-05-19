### -----------------------------
### simon munzert
### scraping dynamic webpages
### -----------------------------

## peparations -------------------

source("00-course-setup.r")
wd <- getwd()


# install dev version of RSelenium
devtools::install_github("ropensci/RSelenium")

# set up connection via RSelenium package
# documentation: http://cran.r-project.org/web/packages/RSelenium/RSelenium.pdf

# note: on a Windows or Linux machine, using Docker might be useful; see
# vignette("RSelenium-docker", package = "RSelenium") 

# check currently installed version of Java
system("java -version")
system("java -jar selenium-server-standalone-3.4.0.jar")


## example --------------------------


# initiate Selenium driver
rD <- rsDriver()
remDr <- rD[["client"]]

# start browser, navigate to page
url <- "http://www.iea.org/policiesandmeasures/renewableenergy/"
remDr$navigate(url)

# open regions menu
css <- 'div.form-container:nth-child(2) > ul:nth-child(2) > li:nth-child(1) > span:nth-child(1)'
regionsElem <- remDr$findElement(using = 'css', value = css)
openRegions <- regionsElem$clickElement() # click on button

# close connection
remDr$closeServer()
