#libraries
library(utils)
library(tidyverse)
library(tidytext)
library(tm)
library(lubridate)



#read in all data
#Load all files and rbind
files = list.files(paste(getwd(), "/data", sep = ""), pattern=".csv", full.names=T)
files


#Loop over each file, read and rbind each of them
df <- do.call("rbind",lapply(files, read.csv))


#Get number of tweets, retweets, number of tweeting handles

#Number of tweets
a <- df %>% 
  nrow()

#Number of retweets
b <- sum(df$isRetweet)

#Number of handles
c <- length(unique(df$screenName))


#Dataframe
  data.frame(tweets = a, retweets = b, users = c) %>% 
  mutate(date = Sys.Date()) %>% 
  write.table("Analysis/info.csv", sep = ",", row.names = F, append = T, col.names = !file.exists("Analysis/info.csv"))



#Most mentioned handles
users <- function(x, ...){
  xx <- strsplit(x, " ")
  lapply(xx, function(xx)xx[grepl("@[[:alnum:]]", xx)])
}
#Most mention words
removeURL2 <- function(x) gsub("([[:alpha:]])(?=\\1)", "", x, perl = TRUE)
removeNumPunct <- function(x) gsub("[^[:alpha:][:space:]]*", "", x)

#Extract the most mentioned handles
users(df$text) %>% 
  unlist() %>%
  tolower() %>% 
  as_tibble() %>% 
  count(value, sort = T) %>% 
  top_n(20) %>% 
  mutate(date = Sys.Date()) %>% 
  write.table("Analysis/handles.csv", sep = ",", row.names = F, append = T, col.names = !file.exists("Analysis/handles.csv"))




#Get bigrams, top n words


#Top mentions words
#Most mention words
df %>%
  mutate(text = gsub("RT", "", text)) %>% 
  mutate(text = tolower(text)) %>% 
  #mutate(text = removeURL2(text)) %>% 
  mutate(text = removeNumPunct(text)) %>% 
  mutate(text = gsub("ря", "", text)) %>% 
  mutate(text = gsub("в", "", text)) %>% 
  unnest_tokens(word, text) %>% 
  anti_join(stop_words) %>% 
  count(word, sort = T) %>% 
  top_n(20) %>% 
  mutate(date = Sys.Date()) %>% 
  write.table("Analysis/Topwords.csv", sep = ",", row.names = F, append = T, col.names = !file.exists("Analysis/Topwords.csv"))





#read nrc 
nrc <- read.csv("Analysis/nrc.csv") %>% 
  select(3:4)

#Overall reaction
df %>% 
  mutate(text = tolower(text)) %>% 
  mutate(text = removeURL2(text)) %>% 
  mutate(text = gsub("rt", "", text)) %>% 
  unnest_tokens(word, text) %>% 
  anti_join(stop_words) %>% 
  inner_join(nrc) %>% 
  count(word, sentiment, sort = T) %>% 
  distinct(word, .keep_all = T) %>% 
  ungroup() %>% 
  group_by(sentiment) %>% 
  summarise(n = sum(n)) %>% 
  mutate(date = Sys.Date()) %>% 
  write.table("Analysis/Reactions.csv", sep = ",", row.names = F, append = T, col.names = !file.exists("Analysis/Reactions.csv"))



#Tweet trend
df %>% 
  separate(created, into = c("date", "time"), sep = " ") %>% 
  mutate(date = ymd(date)) %>% 
  mutate(hr = hour(hms(time))) %>% 
  mutate(tm = ifelse(hr < 12, "am", "pm")) %>%
  group_by(date) %>%
  count() %>% 
  write.table("Analysis/trend.csv", sep = ",", row.names = F, append = T, col.names = !file.exists("Analysis/trend.csv"))





