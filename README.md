# Emotion Detection in Tweets

As amount of text data on social media platforms increases rapidly, we can use such data such as tweets to detect public's emotional reaction towards certain topics. In this project, we present an end-to-end model for emotion detection in tweets using R. From text data representation and classification to novel visualizations, we aim to build powerful model to detect emotion in social media text data and present statistical textual information behind each emotion category through visualization. 

# Dataset

We use [__Emotion Intensity Dataset__](https://saifmohammad.com/WebDocs/EmoInt-2017.pdf) by Mohammad and Bravo-Marquez. It contains 7102 tweets each annotated with single emotion from __anger__, __fear__, __joy__ or __sadness__ and an emotion intensity score scaled to 0-1. We use 80% data for training and 20% for testing with 5-fold cross validation. 

# Computation

Our computation is composed of following parts: 

- Preprocessing: removing stop words, lemmatizing with R package [textstem](https://cran.r-project.org/web/packages/textstem/index.html)

- Sentence vector representation using R package [fastrtext](https://cran.r-project.org/web/packages/fastrtext/index.html)

- Multi-class classification model for emotion detection using sentence vectors and labels

- Two-sample t-test for selecting most emotional words for each emotion category

# Visualization 

We will present following visualizations for our data:

- Histogram of emotion intensity for each emotion category

- Boxplot of emotion vs sentence length

- Barplot of t-statistics for top 10 emotional words for each emotion category

- Word cloud of emotional words in each emotion category using R package [wordcloud](https://cran.r-project.org/web/packages/wordcloud/index.html)

# Peer Evaluation
twu38: Data Preprocessing

qwang55: Computation and Modeling

ssuh11: Visualizations
