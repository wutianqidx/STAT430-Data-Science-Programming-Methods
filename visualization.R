#Install Packages
install.packages("ggplot2")
library(ggplot2)

preprocessed_data <- read.csv("preprocessed_data/preprocessed_data.csv")
anger_words <- read.csv("emotion_words/anger_words.csv")
fear_words <- read.csv("emotion_words/fear_words.csv")
joy_words <- read.csv("emotion_words/joy_words.csv")
sadness_words <- read.csv("emotion_words/sadness_words.csv")
anger_hashtags <- read.csv("emotion_hashtags/anger_hashtags.csv")
fear_hashtags <- read.csv("emotion_hashtags/fear_hashtags.csv")
joy_hashtags <- read.csv("emotion_hashtags/joy_hashtags.csv")
sadness_hashtags <- read.csv("emotion_hashtags/sadness_hashtags.csv")

#Histogram of Emotion Intensity
plotHistogram <- function(preprocessed){
  ggplot(preprocessed, aes(x=intensity, color=label, fill=label)) +
    facet_wrap(~ label) +
    geom_histogram(position="identity", alpha=0.5) +
    labs(
      title = "Emotion Intensity Histogram Plot", x = "Intensity", y = "Count")
}

#Boxplot of Sentence Length per Emotion
plotBoxplot <- function(preprocessed){
  ggplot(preprocessed, aes(x=label, y=nchar(as.character(tweets)), fill=label)) +
    geom_boxplot() +
    coord_cartesian(ylim=c(40,110)) +
    labs(title="Boxplot of Sentence Length by Emotion", 
         x="Emotion", y = "Number of Characters") +
    theme(legend.position = "none")
}

#Barplot of t-statistics of Top 10 Emotional Words
plotBarplot <- function(emotion, cat, label='word'){
  emotion_20 <- head(emotion, 10)
  if (label == 'word') {
    title = "Barplot of Top 10 Emotional Words"
    fill = "steelblue"
    }
  else {
    title = "Barplot of Top 10 Emotional Hashtags"
    fill = "tan1"
    }
  subtitle = paste(cat, "Tweets")
  y_scale = max(emotion_20$pos_score) - min(emotion_20$pos_score)
  lower_ylim = min(emotion_20$pos_score) - y_scale/5
  upper_ylim = max(emotion_20$pos_score) + y_scale/5
  ggplot(emotion_20, aes(x=reorder(pos_word, pos_score), y=pos_score)) +
    geom_bar(stat="identity", fill=fill, alpha=0.8) +
    geom_text(aes(label=round(pos_score,3), hjust = -0.1)) +
    labs(title=title, subtitle=subtitle, x="Word", y="T-Statistics", cex.lab = 0.8) +
    coord_flip(ylim=c(lower_ylim, upper_ylim))
}

plotHistogram(preprocessed_data)
ggsave('visualization/histogram.png', plot = last_plot())

plotBoxplot(preprocessed_data)
ggsave('visualization/boxplot.png', plot = last_plot())

plotBarplot(anger_words, 'Anger')
ggsave('visualization/bar_anger.png', plot = last_plot())

plotBarplot(fear_words, 'Fear')
ggsave('visualization/bar_fear.png', plot = last_plot())

plotBarplot(joy_words, 'Joy')
ggsave('visualization/bar_joy.png', plot = last_plot())

plotBarplot(sadness_words, 'Sadness')
ggsave('visualization/bar_sadness.png', plot = last_plot())

plotBarplot(anger_hashtags, 'Anger', 'hashtag')
ggsave('visualization/bar_anger_hashtag.png', plot = last_plot())

plotBarplot(fear_hashtags, 'Fear', 'hashtag')
ggsave('visualization/bar_fear_hashtag.png', plot = last_plot())

plotBarplot(joy_hashtags, 'Joy', 'hashtag')
ggsave('visualization/bar_joy_hashtag.png', plot = last_plot())

plotBarplot(sadness_hashtags, 'Sadness', 'hashtag')
ggsave('visualization/bar_sadness_hashtag.png', plot = last_plot())

