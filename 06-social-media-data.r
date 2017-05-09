### -----------------------------
### simon munzert
### gathering social media data
### -----------------------------

## peparations -------------------

source("00-course-setup.r")
wd <- getwd()

 
## mining Twitter with R ----------------

## about the Twitter APIs

# two APIs types of interest:
# REST APIs --> reading/writing/following/etc., "Twitter remote control"
# Streaming APIs --> low latency access to 1% of global stream - public, user and site streams
# authentication via OAuth
# documentation at https://dev.twitter.com/overview/documentation

# how to get started
# 1. register as a developer at https://dev.twitter.com/ - it's free
# 2. create a new app at https://apps.twitter.com/ - choose a random name, e.g., MyTwitterToRApp
# 3. go to "Keys and Access Tokens" and keep the displayed information ready
# 4. paste your consumer key and secret into the following code and execute it:

# store credentials in the R environment (uncomment the following lines if you want to store your credentials)
credentials <- c(
  "twitter_api_key=rN3T39JnSLKEBN9Pj7X2eBN",
  "twitter_api_secret=abcqBpUzE7sa94jglkejgnJEnfzjyaRCfwn3ndrUUcqDWfhCN7Fj")
fname <- paste0(normalizePath("~/"),".Renviron")
writeLines(credentials, fname)


## working with the twitteR package

# negotiate credentials
api_key <- Sys.getenv("twitter_api_key")
api_secret <- Sys.getenv("twitter_api_secret")
setup_twitter_oauth(api_key,api_secret) # selecting "1: Yes" usually works

# search tweets on twitter
tweets <- searchTwitter(searchString = "Trump", n=25)
tweets_df <- twListToDF(tweets)
head(tweets_df)
names(tweets_df)

# get information about users
user <- getUser("RDataCollection")
user$name
user$lastStatus
user$followersCount
user$statusesCount
user_followers <- user$getFollowers()
user_friends <- user$getFriends() 
user_timeline <- userTimeline(user, n=20)
timeline_df <- twListToDF(user_timeline)
head(timeline_df)

# check rate limits
getCurRateLimitInfo()


## working with the streamR package

load("../rscraping-intro-duke-2/twitter_auth.RData")

filterStream("tweets_stream.json", track = c("Trump"), timeout = 10, oauth = twitCred)
tweets <- parseTweets("tweets_stream.json", simplify = TRUE)
names(tweets)
cat(tweets$text[1])



