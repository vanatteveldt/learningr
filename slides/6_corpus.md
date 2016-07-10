<style>

.reveal .slides > sectionx {
    top: -70%;
}

.reveal pre code.r {background-color: #ccF}

.section .reveal li {color:white}
.section .reveal em {font-weight: bold; font-style: "none"}

</style>

 

Text Analysis in R
========================================================
author: Wouter van Atteveldt
date: Comparing and clustering corpora

Course Overview
===
type:section 

Thursday: Introduction to R

Friday: Corpus Analysis & Topic Modeling
+ Querying Text with AmCAT & R
+ The Document-Term matrix
+ *Comparing Corpora*
+ Topic Modeling

Comparing Corpora
====

+ Constrasts more informative than frequencies
+ Compare speakers, media, periods, ...
+ `corpustools::corpora.compare`

Obama's speeches
====


```r
library(corpustools)
data(sotu)
obama = sotu.meta$id[sotu.meta$headline == "Barack Obama"]
dtm_o = with(subset(sotu.tokens, aid %in% obama & pos1 %in% c("N", "A", "M")),
           dtm.create(aid, lemma))
dtm.wordcloud(dtm_o)
```

![plot of chunk unnamed-chunk-1](6_corpus-figure/unnamed-chunk-1-1.png)

Comparing Corpora
===

```r
dtm_b = with(subset(sotu.tokens, !(aid %in% obama) & pos1 %in% c("N", "A", "M")),
           dtm.create(aid, lemma))
cmp  = corpora.compare(dtm_o, dtm_b)
cmp = arrange(cmp, -chi)
kable(head(cmp))
```



|term      | termfreq.x| termfreq.y| termfreq| relfreq.x| relfreq.y|      over|      chi|
|:---------|----------:|----------:|--------:|---------:|---------:|---------:|--------:|
|job       |        200|         56|      256| 0.0195351| 0.0051090| 3.3614321| 92.34135|
|terrorist |         13|        103|      116| 0.0012698| 0.0093970| 0.2183120| 64.24944|
|freedom   |          8|         79|       87| 0.0007814| 0.0072074| 0.2170491| 53.48220|
|Iraq      |         15|         94|      109| 0.0014651| 0.0085759| 0.2574317| 52.32461|
|terror    |          0|         55|       55| 0.0000000| 0.0050178| 0.1661740| 51.50577|
|business  |        109|         31|      140| 0.0106466| 0.0028282| 3.0423131| 49.32315|

Contrast plots
===

```r
with(head(cmp, 100),
plotWords(x=log(over), words = term, wordfreq = chi, random.y = T))
```

![plot of chunk unnamed-chunk-3](6_corpus-figure/unnamed-chunk-3-1.png)

Comparing multiple corpora
====

+ Requires subcorpus variable
+ Align meta to dtm


```r
head(rownames(dtm_o))
```

```
[1] "111541965" "111541995" "111542001" "111542006" "111542013" "111542018"
```

```r
meta = sotu.meta[match(rownames(dtm_o), sotu.meta$id), ]
meta$year = format(meta$date, "%Y")
kable(head(meta))
```



|        id|medium   |headline     |date       |year |
|---------:|:--------|:------------|:----------|:----|
| 111541965|Speeches |Barack Obama |2013-02-12 |2013 |
| 111541995|Speeches |Barack Obama |2013-02-12 |2013 |
| 111542001|Speeches |Barack Obama |2013-02-12 |2013 |
| 111542006|Speeches |Barack Obama |2013-02-12 |2013 |
| 111542013|Speeches |Barack Obama |2013-02-12 |2013 |
| 111542018|Speeches |Barack Obama |2013-02-12 |2013 |

Comparing multiple corpora
===


```r
d = corpora.compare.list(dtm_o, as.character(meta$year), return.df=T, .progress="none")
d = arrange(d,-chi)
kable(head(d))
```



|corpus |term      | termfreq.x| termfreq.y| termfreq| relfreq.x| relfreq.y|     over|      chi|
|:------|:---------|----------:|----------:|--------:|---------:|---------:|--------:|--------:|
|2009   |plan      |         21|         18|       39| 0.0145429| 0.0020469| 5.101313| 51.03811|
|2014   |Cory      |          9|          0|        9| 0.0049724| 0.0000000| 5.972376| 41.94405|
|2013   |reduction |          7|          0|        7| 0.0039909| 0.0000000| 4.990878| 33.88177|
|2012   |unit      |          7|          0|        7| 0.0039326| 0.0000000| 4.932584| 33.28456|
|2009   |recovery  |         11|          7|       18| 0.0076177| 0.0007960| 4.798297| 32.88778|
|2009   |lending   |          6|          1|        7| 0.0041551| 0.0001137| 4.628769| 29.64959|

Topic Modeling
====
type: section


Topic Modeling
====

+ Cluster words and documents
+ Comparable to factor analysis of DTM
+ Latent Dirichlet Allocation
  + Generative model
  + Writer picks mix of topics
    + Each topic is mix of words
  + Writer picks words from topics
+ Many advanced versions exist
  + Structural topic models
  + Hierarchical topic models
  
Topic Modeling in R
====


```r
library(corpustools)
set.seed(123)
m = lda.fit(dtm_o, K = 5, alpha = .1)
kable(terms(m, 10))
```



|Topic 1    |Topic 2  |Topic 3   |Topic 4  |Topic 5   |
|:----------|:--------|:---------|:--------|:---------|
|people     |America  |job       |job      |year      |
|country    |world    |school    |new      |tax       |
|time       |people   |education |energy   |more      |
|future     |security |college   |year     |family    |
|government |new      |child     |business |deficit   |
|american   |american |student   |America  |health    |
|America    |country  |kid       |more     |care      |
|Americans  |war      |America   |company  |Americans |
|day        |year     |more      |american |cost      |
|nation     |troops   |high      |worker   |Congress  |

Visualizing LDA
====


```r
library(LDAvis)
json = ldavis_json(m, dtm_o)
serVis(json)
```

How many topics?
====

+ Inspect result
  + Mixed topics? increase K
  + Very similar topics? decrease K
+ Perplexity measure for different K  
  + Scree plot
+ Jacobi, Van Atteveldt & Welbers (2016)
+ (there will always be junk topics)

Perplexity
===


```r
p = readRDS("perplex.rds")
p = aggregate(p["p"], p["k"], mean)
library(ggplot2)
ggplot(p, aes(x=k, y=p, )) + geom_line()  +geom_point()
```

![plot of chunk unnamed-chunk-8](6_corpus-figure/unnamed-chunk-8-1.png)

Analyzing LDA results
===


```r
tpd = topics.per.document(m)
tpd = merge(sotu.meta, tpd)
kable(head(tpd))
```



|        id|medium   |headline     |date       |        X1|        X2|        X3|        X4|        X5|
|---------:|:--------|:------------|:----------|---------:|---------:|---------:|---------:|---------:|
| 111541965|Speeches |Barack Obama |2013-02-12 | 0.8133333| 0.0133333| 0.0133333| 0.1466667| 0.0133333|
| 111541995|Speeches |Barack Obama |2013-02-12 | 0.0933333| 0.0044444| 0.4488889| 0.4488889| 0.0044444|
| 111542001|Speeches |Barack Obama |2013-02-12 | 0.0400000| 0.0036364| 0.6581818| 0.0400000| 0.2581818|
| 111542006|Speeches |Barack Obama |2013-02-12 | 0.4628571| 0.0057143| 0.5200000| 0.0057143| 0.0057143|
| 111542013|Speeches |Barack Obama |2013-02-12 | 0.2897959| 0.3306122| 0.2897959| 0.0857143| 0.0040816|
| 111542018|Speeches |Barack Obama |2013-02-12 | 0.0046512| 0.0976744| 0.4232558| 0.4697674| 0.0046512|


Hands-on session
====
type: section

Handouts:
+ Comparing corpora
+ LDA Topic Modeling
