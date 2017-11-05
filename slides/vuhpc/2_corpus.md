<style>

.reveal .slides > sectionx {
    top: -70%;
}

.reveal pre code.r {background-color: #ccF}
.reveal pre code {font-size: 1.3em}

.small-code pre code {
  font-size: 1.15em;
}

.section .reveal li {color:white}
.section .reveal em {font-weight: bold; font-style: "none"}

</style>



Corpus Analysis and Visualization
========================================================
author: Wouter van Atteveldt
date:   VU-HPC, 2017-11-05



Course Overview
========================================================

10:30 - 12:00
- Recap: Frequency Based Analysis and the DTM
- Dictionary Analysis with AmCAT and R

13:30 - 15:00
- *Simple Natural Language Processing*
- Corpus Analysis and Visualization
- Topic Modeling and Visualization

15:15 - 17:00
- Sentiment Analysis with dictionaries
- Sentiment Analysis with proximity


Simple NLP
====

+ Preprocess documents to get more information
+ Relatively fast and accurate
  + Lemmatizing
  + Part-of-Speech (POS) tagging
  + Named Entity Recognition
+ Unfortunately, not within R

NLPipe + nlpiper
===

+ nlpipe: simple NLP processing based on stanford corenlp, others


```sh
docker run --name corenlp -dp 9000:9000 chilland/corenlp-docker

docker run --name nlpipe --link corenlp:corenlp -e "CORENLP_HOST=http://corenlp:9000" -dp 5001:5001 vanatteveldt/nlpipe
```


```r
devtools::install_github("vanatteveldt/nlpiper")
```

```r
library(nlpiper)
process("test_upper", "test")
```

```
0x098f6bcd4621d373cade4e832627b4f6 
                            "TEST" 
```

Corenlp POS+lemma+NER
====


```r
library(nlpiper)
text = "Donald trump was elected president of the United States"
process("corenlp_lemmatize", text, format="csv")
```

NLPiper and US elections
===
class: small-code

+ You can lemmatize a set of articles or AmCAT set directly
+ But that can take a while..
+ Download tokens for US elections:


```r
# choose one:
download.file("http://i.amcat.nl/tokens.rds", "tokens.rds")
download.file("http://i.amcat.nl/tokens_full.rds", "tokens.rds")
download.file("http://i.amcat.nl/tokens_sample.rds", "tokens.rds")
```

```r
meta = readRDS("meta.rds")
tokens = readRDS("tokens.rds")
head(tokens)
```



|   |        id| sentence| offset|word        |lemma       |POS |POS1 |ner |
|:--|---------:|--------:|------:|:-----------|:-----------|:---|:----|:---|
|2  | 160816860|        1|      2|Tennis      |tennis      |NN  |N    |O   |
|3  | 160816860|        1|      9|Trailblazer |trailblazer |NN  |N    |O   |
|4  | 160816860|        1|     21|Leads       |lead        |VBZ |V    |O   |
|6  | 160816860|        1|     31|Charge      |Charge      |NNP |R    |O   |
|8  | 160816860|        1|     42|Women       |Women       |NNP |R    |O   |
|10 | 160816860|        1|     50|Soccer      |Soccer      |NNP |R    |O   |

Corpus Analysis
=====
type:section

Corpus Analysis
===

- Exploratory Analysis
- Term statistics
- Corpus comparison

The corpustools package
- Useful functions for corpus analysis
- Works on token list rather than dfm/dtm
  - preserves word order
  

```r
install.packages("corpustools")
```

Create TCorpus from tokens
===


```r
library(corpustools)
tc = tokens_to_tcorpus(tokens, "id", sent_i_col = "sentence", )
tc_nouns = tc$subset(POS1=="N", copy = T)

dfm = tc$dtm('lemma', form = 'quanteda_dfm')
```

Corpus Comparison
===


```r
pre = subset(meta, medium == "The New York Times" & date < "2016-08-01")
post = subset(meta, medium == "The New York Times" & date >= "2016-08-01")

tc1 = tokens_to_tcorpus(subset(tokens, id %in% pre$id & POS1 == "G"), "id", sent_i_col = "sentence")
tc2 = tokens_to_tcorpus(subset(tokens, id %in% post$id & POS1 == "G"), "id", sent_i_col = "sentence")

cmp = tc1$compare_corpus(tc2, feature = 'lemma')
cmp = plyr::arrange(cmp, -chi2)
head(cmp)
```



|feature     | freq.x| freq.y| freq|       p.x|       p.y|      ratio|     chi2|
|:-----------|------:|------:|----:|---------:|---------:|----------:|--------:|
|primary     |   2562|    627| 3189| 0.0063271| 0.0022859|  2.7679110| 568.5031|
|presumptive |    749|      5|  754| 0.0018499| 0.0000186| 99.5090224| 493.4279|
|musical     |   1272|    412| 1684| 0.0031415| 0.0015022|  2.0912766| 176.4415|
|sexual      |    364|    579|  943| 0.0008991| 0.0021109|  0.4259513| 174.3048|
|medical     |    210|    395|  605| 0.0005188| 0.0014402|  0.3602565| 156.8345|
|nominating  |    320|     35|  355| 0.0007905| 0.0001279|  6.1783342| 136.9933|

Visualization
===
type:section

Visualization
===


```r
library(quanteda)
dfm = tc2$dtm('lemma', form='quanteda_dfm')
textplot_wordcloud(dfm, max.words = 50, scale = c(4, 0.5))
```

![plot of chunk unnamed-chunk-11](2_corpus-figure/unnamed-chunk-11-1.png)

Beyond (stupid) word clouds
===

+ Word clouds waste most information
+ `corpustools::plotWords`
  + specify x, y, colour, size, etc.
+ Use any analytics you have to determine characteristics
+ See also http://vanatteveldt.com/lse-text-visualization/

Visualizing comparisons
===


```r
library(scales)
h = rescale(log(cmp$ratio), c(1, .6666))
s = rescale(sqrt(cmp$chi2), c(.25,1))
cmp$col = hsv(h, s, .33 + .67*s)
with(head(cmp, 75), plot_words(x=log(ratio), words=feature, wordfreq=chi2, random.y = T, col=col, scale=1))
```

![plot of chunk unnamed-chunk-12](2_corpus-figure/unnamed-chunk-12-1.png)

Visualizing over time
===


```r
wordfreqs = tidytext::tidy(dfm)
wordfreqs = merge(meta, wordfreqs, by.x="id", by.y="document")
dates = aggregate(wordfreqs["date"], by=wordfreqs["term"], FUN=mean)
freqs = as.data.frame(table(wordfreqs$term))
terms = merge(dates, freqs, by.x="term", by.y="Var1")
terms = plyr::arrange(terms, -Freq)
with(head(terms, 50), plot_words(words=term, x=date, wordfreq = Freq))
axis(1)
```

![plot of chunk unnamed-chunk-13](2_corpus-figure/unnamed-chunk-13-1.png)

Topic Modeling
===
type:section

Topic Models
===


Topic Models
===


```r
dtm = tc2$dtm(feature='lemma') # from tcorpus
# or: dtm = convert(dfm, to="topicmodels") # from quanteda

set.seed(1234)
library(topicmodels)
m = LDA(dtm, k = 10, method = "Gibbs", control = list(iter = 100, alpha=.1))
head(terms(m, 10))
```



|Topic 1          |Topic 2 |Topic 3  |Topic 4 |Topic 5 |Topic 6      |Topic 7      |Topic 8 |Topic 9  |Topic 10 |
|:----------------|:-------|:--------|:-------|:-------|:------------|:------------|:-------|:--------|:--------|
|black            |when    |economic |new     |more    |when         |republican   |new     |american |how      |
|white            |how     |more     |musical |federal |presidential |presidential |free    |military |when     |
|where            |first   |last     |when    |other   |former       |democratic   |more    |nuclear  |other    |
|when             |best    |new      |young   |when    |last         |political    |other   |foreign  |real     |
|racial           |own     |other    |novel   |many    |public       |when         |where   |russian  |many     |
|african-american |last    |many     |funny   |last    |political    |many         |how     |national |more     |

===
Visualizing Topic Models: LDAvis


```r
library(LDAvis)
dtm = dtm[slam::row_sums(dtm) > 0, ]
phi <- posterior(m)$terms %>% as.matrix
theta <- posterior(m)$topics %>% as.matrix
vocab <- colnames(phi)
doc.length = slam::row_sums(dtm)
term.freq = slam::col_sums(dtm)[match(vocab, colnames(dtm))]
json =  createJSON(phi = phi, theta = theta,
             vocab = vocab,
             doc.length = doc.length,
             term.frequency = term.freq)
LDAvis::serVis(json)
```



Visualizing Topic Models: heat map
=== 


```r
topics = c("books", "police", "culture", "city", "campaign", "movies", "email", "people", "songs", "economy" )
cm = cor(t(m@beta))
colnames(cm) = rownames(cm) = topics
diag(cm) = 0
heatmap(cm, symm = T)
```

![plot of chunk unnamed-chunk-16](2_corpus-figure/unnamed-chunk-16-1.png)

Visualizing Topic Models: word clouds
=== 


```r
compare.topics <- function(m, cmp_topics) {
  docs = factor(m@wordassignments$i, labels=m@documents)
  terms = factor(m@wordassignments$j, labels=m@terms)
  assignments = data.frame(doc=docs, term=terms, freq=m@wordassignments$v)
  terms = dcast(assignments, term ~ freq, value.var = "doc", fun.aggregate = length)
  terms = terms[, c(1, cmp_topics+1)]
  terms$freq = rowSums(terms[-1])
  terms = terms[terms$freq > 0,]
  terms$prop = terms[[2]] / terms$freq
  terms$col = hsv(rescale(terms$prop, c(1, .6666)), .5, .5)
  terms[order(-terms$freq), ]
}
```

Visualizing Topic Models: word clouds
=== 

```r
terms = compare.topics(m, match(c("campaign", "email"), topics))
with(head(terms, 100), plot_words(x=prop, wordfreq = freq, words = term, col=col, xaxt="none", random.y = T, scale=2))
```

![plot of chunk unnamed-chunk-18](2_corpus-figure/unnamed-chunk-18-1.png)


Analysing Topic Models
===

```r
tpd = posterior(m)$topics
colnames(tpd) = topics
tpd = merge(meta, tpd, by.x="id", by.y="row.names")
head(tpd)
```



|        id|date       |medium             |year       |month      |week       |     books|    police|   culture|      city|  campaign|    movies|     email|    people|     songs|   economy|
|---------:|:----------|:------------------|:----------|:----------|:----------|---------:|---------:|---------:|---------:|---------:|---------:|---------:|---------:|---------:|---------:|
| 171933084|2016-08-04 |The New York Times |2016-01-01 |2016-08-01 |2016-08-01 | 0.0200000| 0.0200000| 0.0200000| 0.0200000| 0.0200000| 0.0200000| 0.0200000| 0.2200000| 0.0200000| 0.6200000|
| 171933085|2016-08-04 |The New York Times |2016-01-01 |2016-08-01 |2016-08-01 | 0.0250000| 0.0250000| 0.0250000| 0.0250000| 0.0250000| 0.0250000| 0.0250000| 0.0250000| 0.7750000| 0.0250000|
| 171933086|2016-08-04 |The New York Times |2016-01-01 |2016-08-01 |2016-08-01 | 0.0021739| 0.0673913| 0.0021739| 0.0021739| 0.0021739| 0.0891304| 0.8282609| 0.0021739| 0.0021739| 0.0021739|
| 171933087|2016-08-04 |The New York Times |2016-01-01 |2016-08-01 |2016-08-01 | 0.8875000| 0.0125000| 0.0125000| 0.0125000| 0.0125000| 0.0125000| 0.0125000| 0.0125000| 0.0125000| 0.0125000|
| 171933089|2016-08-04 |The New York Times |2016-01-01 |2016-08-01 |2016-08-01 | 0.0008333| 0.4591667| 0.0008333| 0.1091667| 0.0008333| 0.0008333| 0.0008333| 0.0008333| 0.4175000| 0.0091667|
| 171933090|2016-08-04 |The New York Times |2016-01-01 |2016-08-01 |2016-08-01 | 0.0024390| 0.0024390| 0.1000000| 0.0024390| 0.0024390| 0.0024390| 0.0024390| 0.0268293| 0.8560976| 0.0024390|

Hands-on session II
===
type:section

- Corpus analysis of Election campaign 
  - (or your own data...)
- Which words, adjectives, verbs, etc are frequent?
- How do they differ over time, by medium, subcorpus
- What topics can we find?
- Can we visualize topics, contrasts, etc.
  
  
