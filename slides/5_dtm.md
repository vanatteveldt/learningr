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
date: Corpus Analysis: The Document-term Matrix


Document-Term Matrix
===

+ Representation word frequencies
  + Rows: Documents
  + Columns: Terms (words)
  + Cells: Frequency
+ Stored as 'sparse' matrix
  + only non-zero values are stored
  + Usually, >99% of cells are zero
  
Docment-Term Matrix
===


```r
library(RTextTools)
m = create_matrix(c("I love data", "John loves data!"))
as.matrix(m)
```

```
    Terms
Docs data john love loves
   1    1    0    1     0
   2    1    1    0     1
```

Simple corpus analysis
===


```r
library(corpustools)
head(term.statistics(m))
```



|      |term  | characters|number |nonalpha | termfreq| docfreq| reldocfreq|     tfidf|
|:-----|:-----|----------:|:------|:--------|--------:|-------:|----------:|---------:|
|data  |data  |          4|FALSE  |FALSE    |        2|       2|        1.0| 0.0000000|
|john  |john  |          4|FALSE  |FALSE    |        1|       1|        0.5| 0.3333333|
|love  |love  |          4|FALSE  |FALSE    |        1|       1|        0.5| 0.5000000|
|loves |loves |          5|FALSE  |FALSE    |        1|       1|        0.5| 0.3333333|

Preprocessing 
===

+ Lot of noise in text:
  + Stop words (the, a, I, will)
  + Conjugations (love, loves)
  + Non-word terms (33$, !)
+ Simple preprocessing, e.g. in `RTextTools`
  + stemming
  + stop word removal

Linguistic Preprocessing
====

+ Lemmatizing
+ Part-of-Speech tagging
+ Coreference resolution
+ Disambiguation
+ Syntactic parsing  
  
Tokens
====

+ One word per line (CONLL)
+ Linguistic information 


```r
data(sotu)
head(sotu.tokens)
```



|word       | sentence|pos  |lemma      | offset|       aid| id|pos1 | freq|
|:----------|--------:|:----|:----------|------:|---------:|--:|:----|----:|
|It         |        1|PRP  |it         |      0| 111541965|  1|O    |    1|
|is         |        1|VBZ  |be         |      3| 111541965|  2|V    |    1|
|our        |        1|PRP$ |we         |      6| 111541965|  3|O    |    1|
|unfinished |        1|JJ   |unfinished |     10| 111541965|  4|A    |    1|
|task       |        1|NN   |task       |     21| 111541965|  5|N    |    1|
|to         |        1|TO   |to         |     26| 111541965|  6|?    |    1|

Getting tokens from AmCAT
===


```r
tokens = amcat.gettokens(conn, project=1, articleset=set)
tokens = amcat.gettokens(conn, project=1, articleset=set, module="corenlp_lemmatize")
```

DTM from Tokens
===


```r
dtm = with(subset(sotu.tokens, pos1=="M"),
           dtm.create(aid, lemma))
dtm.wordcloud(dtm)
```

![plot of chunk unnamed-chunk-6](5_dtm-figure/unnamed-chunk-6-1.png)

Corpus Statistics
===

```r
stats = term.statistics(dtm)
stats= arrange(stats, -termfreq)
head(stats)
```



|term      | characters|number |nonalpha | termfreq| docfreq| reldocfreq|     tfidf|
|:---------|----------:|:------|:--------|--------:|-------:|----------:|---------:|
|America   |          7|FALSE  |FALSE    |      409|     346|  0.3940774| 0.6883991|
|Americans |          9|FALSE  |FALSE    |      179|     158|  0.1799544| 1.4280099|
|Congress  |          8|FALSE  |FALSE    |      168|     149|  0.1697039| 1.1398894|
|Iraq      |          4|FALSE  |FALSE    |      109|      65|  0.0740319| 1.4157528|
|States    |          6|FALSE  |FALSE    |       99|      89|  0.1013667| 0.9573274|
|United    |          6|FALSE  |FALSE    |       88|      82|  0.0933941| 0.7817946|

Hands-on
====
type: section

Handouts: Corpus Analysis
