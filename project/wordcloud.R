install.packages("tm")
install.packages("SnowballC")
install.packages("wordcloud")
install.packages("RColorBrewer")

library(tm)
library(SnowballC)
library(wordcloud)
library(RColorBrewer)

preprocessed_data <- read.csv("preprocessed_data/preprocessed_data.csv")
anger_data <- subset(preprocessed_data, label == "anger")
fear_data <- subset(preprocessed_data, label == "fear")
joy_data <- subset(preprocessed_data, label == "joy")
sadness_data <- subset(preprocessed_data, label == "sadness")

plotWordcloud <- function(preprocessed_data){
  tweetCorpus <- VCorpus(VectorSource(preprocessed_data$tweets))
  
  toSpace <- content_transformer(function (x , pattern ) gsub(pattern, " ", x))
  tweetCorpus <- tm_map(tweetCorpus, toSpace, "#")
  
  tweetCorpus <- tm_map(tweetCorpus, PlainTextDocument)
  tweetCorpus <- tm_map(tweetCorpus, removeNumbers)
  tweetCorpus <- tm_map(tweetCorpus, removeWords, c(stopwords("english"), 
                                                    "just", "like", "get", 
                                                    "can", "dont"))
  tweetCorpus <- tm_map(tweetCorpus, removePunctuation)
  tweetCorpus <- tm_map(tweetCorpus, stripWhitespace)
  tweetCorpus <- tm_map(tweetCorpus, stemDocument)
  
  tdm <- TermDocumentMatrix(tweetCorpus)
  m <- as.matrix(tdm)
  v <- sort(rowSums(m), decreasing=TRUE)
  d <- data.frame(word = names(v), freq = v)
  
  wordcloud(words = d$word, freq = d$freq, min.freq = 1,
            max.words=100, random.order=FALSE, rot.per=0.35, 
            colors=brewer.pal(8, "Dark2"))
}

plotWordcloud(anger_data)        
plotWordcloud(fear_data)  
plotWordcloud(joy_data)  
plotWordcloud(sadness_data)  
