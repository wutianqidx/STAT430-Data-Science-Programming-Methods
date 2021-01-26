list.of.packages <- c('data.table', 'fastrtext', 'xgboost', 'caret')
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

library(fastrtext)
library(xgboost)

data = data.table::fread('preprocessed_data/preprocessed_data.csv')
data = data[, .(tweets, label)]
texts <- data[['tweets']]
model_file <- build_vectors(texts, model_path = 'text_vector_model', 
                            dim = 32, epoch=50, lr = 0.05)
model <- load_model(model_file)
text_vectors = get_sentence_representation(model, texts)
labels = as.integer(as.factor(data[['label']])) - 1

n = dim(text_vectors)[1]
set.seed(10)
train_inds = sample.int(n, size=0.8*n)

x_train = text_vectors[train_inds,]
y_train = labels[train_inds]

x_test = text_vectors[-train_inds,]
y_test = labels[-train_inds]

dtrain = xgb.DMatrix(x_train, label=y_train)
xgb_params <- list("objective" = "multi:softmax",
                   "eval_metric" = "mlogloss",
                   "num_class" = 4)

xgb = xgb.train(xgb_params, dtrain, max_depth=17, nrounds=10)
test_prediction = predict(xgb, x_test)
caret::confusionMatrix(factor(y_test),
                       factor(test_prediction),
                       mode = "everything")

result = data.frame(y_test = y_test, prediction = test_prediction)
data.table::fwrite(result, "model_result.csv")


