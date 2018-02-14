library(quanteda) 
texts = corpus_reshape(data_corpus_inaugural, to = "paragraphs")
dfm = dfm(texts, remove_punct=T, remove=stopwords("english"))
dfm = dfm_trim(dfm, min_docfreq = 5)

dtm = convert(dfm, to = "topicmodels") 

library(topicmodels)

train = sample(rownames(dtm), nrow(dtm) * .75)
dtm_train = dtm[rownames(dtm) %in% train, ]
dtm_test = dtm[!rownames(dtm) %in% train, ]

perplexity = data.frame(k = 2:10, p=NA)

for (k in perplexity$k) {
  message("k=", k)
  m = LDA(dtm_train, method = "Gibbs", k = k,  control = list(alpha = 5/k))
  perplexity$p[perplexity$k==k] = perplexity(m, dtm_test)
}
perplexity
plot(x=perplexity$k, y=perplexity$p)
