
#load library
library(twitteR)
library(utils)

#sa
#Save app credentials for access to tweets
consumerKey <- "TLwcYDEblVFgtDIqeqGXY05zH"

consumerSecret <- "Wpy8VEH6eGliqisMCNonqC7q9Z3YrxpmjxkiIyMdSj8qsocdSw"

accessToken <- "1097552545411678208-zIYNJm6l1aOwxUwCtLbgbpmjGciJtp"

accessTokenSecret <-  "d3V7AQ2BSkcj5qCZIjuSeuOPpsfUfM3eRb1YyMmlLdoPG"

#set up 
setup_twitter_oauth(consumerKey,consumerSecret,accessToken,accessTokenSecret)


#
#data collector
data <- searchTwitter("uber", n = 2000, 
                      resultType = "recent", lang = "en")


#write csv
write.csv(twListToDF(data), gsub(":", "-",paste("data/","uber", as.character(Sys.time()), ".csv", sep = "")))


