list.of.packages <- c('data.table', 'qdap', 'fastrtext', 'text2vec', 'slam', 'stringr')
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

library(data.table)
library(qdap)
library(text2vec)
library(slam)
library(stringr)

# Remove usernames, punctuations and stopwords 
# Keep '#' for hashtags.
preprocess = function(data){
  stop_words = c("i", "me", "my", "myself", "we", "our", "ours", "ourselves", 
                 "you", "your", "yours", "their", "they", "his", "her", 
                 "she", "he", "a", "an", "and", "is", "was", "are", "were", 
                 "him", "himself", "has", "have", "it", "its", "of", "one", "for", 
                 "the", "us", "this")
  
  tweets = gsub('[^[:alnum:][:blank:]#]', '', tolower(gsub('@.*? |\\\\n|\\n|###*', ' ', data$tweets)))
  tweets = rm_stopwords(tweets, stopwords=stop_words, separate=FALSE)
  tweets = gsub('# ', '#', tweets)
  hashtags = sapply(str_extract_all(tweets, '#.*?(?=$| )'), paste, collapse=" ")
  data$tweets = tweets
  data$hashtags = hashtags
  data
}

# Get vectorized word data for 2-sample t-test
get_word_dtm = function(data){
  tweets = data$tweets
  it = itoken(tweets, tokenizer = word_tokenizer)
  v = create_vocabulary(it, ngram = c(1L, 1L))
  vocab = prune_vocabulary(v, term_count_min = 5, 
                           doc_proportion_max = 0.5, doc_proportion_min = 0.001)
  vectorizer = vocab_vectorizer(vocab)
  create_dtm(it, vectorizer)
}

# Get vectorized hashtag data for 2-sample t-test
get_hashtag_dtm = function(data){
  hashtags = data$hashtags
  it = itoken(hashtags, tokenizer = space_tokenizer)
  v = create_vocabulary(it, ngram = c(1L, 1L))
  vocab = prune_vocabulary(v, term_count_min = 5, 
                           doc_proportion_max = 0.5, doc_proportion_min = 0.001)
  vectorizer = vocab_vectorizer(vocab)
  create_dtm(it, vectorizer)
}


# Calculate word emotion scores for emotion category 'label'
# Return top 'num_words' of positive and negative words of that category
emotion_word_list = function(dtm, label, num_words = 50){

  vocab_size = dim(dtm)[2]
  emotion = data$label
  
  summ = matrix(0, nrow = vocab_size, ncol=4)
  summ[,1] = colapply_simple_triplet_matrix(as.simple_triplet_matrix(dtm[emotion==label, ]),mean)
  summ[,2] = colapply_simple_triplet_matrix(as.simple_triplet_matrix(dtm[emotion==label, ]),var)
  summ[,3] = colapply_simple_triplet_matrix(as.simple_triplet_matrix(dtm[emotion!=label, ]),mean)
  summ[,4] = colapply_simple_triplet_matrix(as.simple_triplet_matrix(dtm[emotion!=label, ]),var)
  n1 =sum(emotion==label); 
  n =length(emotion)
  n0 = n - n1
  
  scores = (summ[,1] - summ[,3])/sqrt(summ[,2]/n1 + summ[,4]/n0)
  words = colnames(dtm)
  id = order(abs(scores), decreasing=TRUE)
  result = data.frame(cbind(words[id[scores[id]>0]][1:num_words], 
                            scores[id[scores[id]>0]][1:num_words],
                            words[id[scores[id]<0]][1:num_words], 
                            scores[id[scores[id]<0]][1:num_words]))
  names(result) = c('pos_word', 'pos_score', 'neg_word', 'neg_score')
  result
}

# read data and preprocess
data = data.table::fread('data.csv')
data = preprocess(data)
word_dtm = get_word_dtm(data)
hashtag_dtm = get_hashtag_dtm(data)

# get emotional words and scores for all categories
fear_words = emotion_word_list(word_dtm, label='fear')
sadness_words = emotion_word_list(word_dtm, label='sadness')
anger_words = emotion_word_list(word_dtm, label='anger')
joy_words = emotion_word_list(word_dtm, label='joy')

# write results in corresponding files
dir.create('emotion_words')
fwrite(fear_words, 'emotion_words/fear_words.csv')
fwrite(sadness_words, 'emotion_words/sadness_words.csv')
fwrite(anger_words, 'emotion_words/anger_words.csv')
fwrite(joy_words, 'emotion_words/joy_words.csv')

# get emotional hashtags and scores for all categories
fear_hashtags = emotion_word_list(hashtag_dtm, label='fear')
sadness_hashtags = emotion_word_list(hashtag_dtm, label='sadness')
anger_hashtags = emotion_word_list(hashtag_dtm, label='anger')
joy_hashtags = emotion_word_list(hashtag_dtm, label='joy')

# write results in corresponding files
dir.create('emotion_hashtags')
fwrite(fear_hashtags, 'emotion_hashtags/fear_hashtags.csv')
fwrite(sadness_hashtags, 'emotion_hashtags/sadness_hashtags.csv')
fwrite(anger_hashtags, 'emotion_hashtags/anger_hashtags.csv')
fwrite(joy_hashtags, 'emotion_hashtags/joy_hashtags.csv')


dir.create('preprocessed_data')
fwrite(data[, c('tweets', 'hashtags', 'label', 'intensity')], 
       'preprocessed_data/preprocessed_data.csv')





