---
title: "Corpus analysis: the document-term matrix"
output: html_document
---

=========================================

_(C) 2015 Wouter van Atteveldt, license: [CC-BY-SA]_

The most important object in frequency-based text analysis is the *document term matrix*. 
This matrix contains the documents in the rows and terms (words) in the columns, 
and each cell is the frequency of that term in that document.

In R, these matrices are provided by the `tm` (text mining) package. 
Although this package provides many functions for loading and manipulating these matrices,
using them directly is relatively complicated. 

Fortunately, the `RTextTools` package provides an easy function to create a document-term matrix from a data frame. To create a term document matrix from a simple data frame with a 'text' column, use the `create_matrix` function (with removeStopwords=F to make sure all words are kept):


```r
library(RTextTools)
input = data.frame(text=c("Chickens are birds", "The bird eats"))
m = create_matrix(input$text, removeStopwords=F)
```

We can inspect the resulting matrix m using the regular R functions to get e.g. the type of object and the dimensionality:


```r
class(m)
```

```
## [1] "DocumentTermMatrix"    "simple_triplet_matrix"
```

```r
dim(m)
```

```
## [1] 2 6
```

```r
m
```

```
## <<DocumentTermMatrix (documents: 2, terms: 6)>>
## Non-/sparse entries: 6/6
## Sparsity           : 50%
## Maximal term length: 8
## Weighting          : term frequency (tf)
```

So, `m` is a `DocumentTermMatrix`, which is derived from a `simple_triplet_matrix` as provided by the `slam` package. 
Internally, document-term matrices are stored as a _sparse matrix_: 
if we do use real data, we can easily have hundreds of thousands of rows and columns, while   the vast majority of cells will be zero (most words don't occur in most documents).
Storing this as a regular  matrix would waste a lot of memory.
In a sparse matrix, only the non-zero entries are stored, as 'simple triplets' of (document, term, frequency). 

As seen in the output of `dim`, Our matrix has only 2 rows (documents) and 6 columns (unqiue words).
Since this is a fairly small matrix, we can visualize it using `as.matrix`, which converts the 'sparse' matrix into a regular matrix:


```r
as.matrix(m)
```

```
##     Terms
## Docs are bird birds chickens eats the
##    1   1    0     1        1    0   0
##    2   0    1     0        0    1   1
```

Stemming and stop word removal
-----

So, we can see that each word is kept as is. 
We can reduce the size of the matrix by dropping stop words and stemming (changing a word like 'chickens' to its base form or stem 'chicken'):
(see the create_matrix documentation for the full range of options)


```r
m = create_matrix(input$text, removeStopwords=T, stemWords=T, language='english')
dim(m)
```

```
## [1] 2 3
```

```r
as.matrix(m)
```

```
##     Terms
## Docs bird chicken eat
##    1    1       1   0
##    2    1       0   1
```

As you can see, the stop words (_the_ and _are_) are removed, while the two verb forms of _to eat_ are joined together. 

In RTextTools, the language for stemming and stop words can be given as a parameter, and the default is English.
Note that stemming works relatively well for English, but is less useful for more highly inflected languages such as Dutch or German. 
An easy way to see the effects of the preprocessing is by looking at the colSums of a matrix,
which gives the total frequency of each term:


```r
colSums(as.matrix(m))
```

```
##    bird chicken     eat 
##       2       1       1
```

For more richly inflected languages like Dutch, the result is less promising:


```r
text = c("De kip eet", "De kippen hebben gegeten")
m = create_matrix(text, removeStopwords=T, stemWords=T, language="dutch")
colSums(as.matrix(m))
```

```
##   eet geget   kip  kipp 
##     1     1     1     1
```

As you can see, _de_ and _hebben_ are correctly recognized as stop words, but _gegeten_ (eaten) and _kippen_ (chickens) have a different stem than _eet_ (eat) and _kip_ (chicken). German gets similarly bad results. 

Getting a Term-Document matrix from AmCAT
====

AmCAT can automatically lemmatize text. 
Before we can use it, we need to connect with a valid username and password:


```r
library(amcatr)
conn = amcat.connect("http://preview.amcat.nl")
```

Now, we can use the `amcat.gettokens` 


```r
sentence = "Chickens are birds. The bird eats"
t = amcat.gettokens(conn, sentence=as.character(sentence), module="corenlp_lemmatize")
```

```
## GET http://preview.amcat.nl/api/v4/tokens/?module=corenlp_lemmatize&page_size=1&format=csv&sentence=Chickens%20are%20birds.%20The%20bird%20eats
```

```r
t
```

```
##       word sentence pos   lemma offset aid id pos1
## 1 Chickens        1 NNS chicken      0  NA  1    N
## 2      are        1 VBP      be      9  NA  2    V
## 3    birds        1 NNS    bird     13  NA  3    N
## 4        .        1   .       .     18  NA  4    .
## 5      The        2  DT     the     20  NA  5    D
## 6     bird        2  NN    bird     24  NA  6    N
## 7     eats        2 VBZ     eat     29  NA  7    V
```

As you can see, this provides real-time lemmatization and Part-of-Speech tagging using the Stanford CoreNLP toolkit:
'are' is recognized as V(erb) and has lemma 'be'. 
To create a term-document matrix from a list of tokens, we can use the `dtm.create` function. 
Since the token list is a regular R data frame, we can use normal selection to e.g. select only the verbs and nouns:


```r
library(corpustools)
dtm = dtm.create(documents=t$sentence, terms=t$lemma, filter=t$pos1 %in% c('V', 'N'), minfreq=0)
as.matrix(dtm)
```

```
##     Terms
## Docs chicken bird eat
##    1       1    1   0
##    2       0    1   1
```


Loading and analysing a larger dataset from AmCAT
-----

Normally, rather than ask for a single ad hoc text to be parsed, we would upload a selection of articles to AmCAT,
after which we can call the analysis for all text at once.
This can be done from R using the `amcat.upload.articles` function, which we now demonstrate with a single article but which can also be used to upload many articles at once:


```r
articles = data.frame(text = "John is a great fan of chickens, and so is Mary", date="2001-01-01", headline="test")

aset = amcat.upload.articles(conn, project = 1, articleset="Test Florence", medium="test", 
                             text=articles$text, date=articles$date, headline=articles$headline)
```

```
## Created articleset 18317: Test Florence in project 1
## Uploading 1 articles to set 18317
```

And we can then lemmatize this article and download the results directly to R
using `amcat.gettokens`:


```r
amcat.gettokens(conn, project=1, articleset = aset, module = "corenlp_lemmatize")
```

```
## GET http://preview.amcat.nl/api/v4/projects/1/articlesets/18317/tokens/?page=1&module=corenlp_lemmatize&page_size=1&format=csv
## GET http://preview.amcat.nl/api/v4/projects/1/articlesets/18317/tokens/?page=2&module=corenlp_lemmatize&page_size=1&format=csv
```

```
##        word sentence pos   lemma offset       aid id pos1
## 1      John        1 NNP    John      0 114440106  1    M
## 2        is        1 VBZ      be      5 114440106  2    V
## 3         a        1  DT       a      8 114440106  3    D
## 4     great        1  JJ   great     10 114440106  4    A
## 5       fan        1  NN     fan     16 114440106  5    N
## 6        of        1  IN      of     20 114440106  6    P
## 7  chickens        1 NNS chicken     23 114440106  7    N
## 8         ,        1   ,       ,     31 114440106  8    .
## 9       and        1  CC     and     33 114440106  9    C
## 10       so        1  RB      so     37 114440106 10    B
## 11       is        1 VBZ      be     40 114440106 11    V
## 12     Mary        1 NNP    Mary     43 114440106 12    M
```

And we can see that e.g. for "is" the lemma "be" is given. 
Note that the words are not in order, and the two occurrences of "is" are automatically summed. 
This can be switched off by giving `drop=NULL` as extra argument.



For a more serious application, we will use an existing article set: [set 16017](https://amcat.nl/navigator/projects/559/articlesets/16017/) in project 559, which contains the state of the Union speeches by Bush and Obama (each document is a single paragraph)
The analysed tokens for this set can be downloaded with the following command:


```r
sotu.tokens = amcat.gettokens(conn, project=559, articleset = 16017, module = "corenlp_lemmatize", page_size = 100)
```

This data is also available directly from the semnet package:


```r
data(sotu)
nrow(sotu.tokens)
```

```
## [1] 91473
```

```r
head(sotu.tokens, n=20)
```

```
##          word sentence  pos      lemma offset       aid id pos1 freq
## 1          It        1  PRP         it      0 111541965  1    O    1
## 2          is        1  VBZ         be      3 111541965  2    V    1
## 3         our        1 PRP$         we      6 111541965  3    O    1
## 4  unfinished        1   JJ unfinished     10 111541965  4    A    1
## 5        task        1   NN       task     21 111541965  5    N    1
## 6          to        1   TO         to     26 111541965  6    ?    1
## 7     restore        1   VB    restore     29 111541965  7    V    1
## 8         the        1   DT        the     37 111541965  8    D    1
## 9       basic        1   JJ      basic     41 111541965  9    A    1
## 10    bargain        1   NN    bargain     47 111541965 10    N    1
## 11       that        1  WDT       that     55 111541965 11    D    1
## 12      built        1  VBD      build     60 111541965 12    V    1
## 13       this        1   DT       this     66 111541965 13    D    1
## 14    country        1   NN    country     71 111541965 14    N    1
## 15          :        1    :          :     78 111541965 15    .    1
## 16        the        1   DT        the     80 111541965 16    D    1
## 17       idea        1   NN       idea     84 111541965 17    N    1
## 18       that        1   IN       that     89 111541965 18    P    1
## 19         if        1   IN         if     94 111541965 19    P    1
## 20        you        1  PRP        you     97 111541965 20    O    1
```

As you can see, the result is similar to the ad-hoc lemmatized tokens, but now we have around 100 thousand tokens rather than 6.
We can create a document-term matrix using the same commands as above, restricting ourselves to nouns, names, verbs, and adjectives:



```r
t = sotu.tokens[sotu.tokens$pos1 %in% c("N", 'M', 'A'), ]
dtm = dtm.create(documents=t$aid, terms=t$lemma)
dtm
```

```
## <<DocumentTermMatrix (documents: 1090, terms: 1038)>>
## Non-/sparse entries: 20113/1111307
## Sparsity           : 98%
## Maximal term length: 14
## Weighting          : term frequency (tf)
```

So, we now have a "sparse" matrix of almost 7,000 documents by more than 70,000 terms. 
Sparse here means that only the non-zero entries are kept in memory, 
because otherwise it would have to keep all 70 million cells in memory (and this is a relatively small data set).
Thus, it might not be a good idea to use functions like `as.matrix` or `colSums` on such a matrix,
since these functions convert the sparse matrix into a regular matrix. 
The next section investigates a number of useful functions to deal with (sparse) document-term matrices.

Corpus analysis: word frequency
-----

What are the most frequent words in the corpus? 
As shown above, we could use the built-in `colSums` function,
but this requires first casting the sparse matrix to a regular matrix, 
which we want to avoid (even our relatively small dataset would have 400 million entries!).
However, we can use the `col_sums` function from the `slam` package, which provides the same functionality for sparse matrices:


```r
library(slam)
freq = col_sums(dtm)
# sort the list by reverse frequency using built-in order function:
freq = freq[order(-freq)]
head(freq, n=10)
```

```
##  America     year   people      new      job     more american  country 
##      409      385      327      259      256      255      239      228 
##    world      tax 
##      198      181
```

As can be seen, the most frequent terms are America and recurring issues like jobs and taxes.
It can be useful to compute different metrics per term, such as term frequency, document frequency (how many documents does it occur), and td.idf (term frequency * inverse document frequency, which removes both rare and overly frequent terms). 
The function `term.statistics` from the `corpus-tools` package provides this functionality:



```r
terms = term.statistics(dtm)
terms = terms[order(-terms$termfreq), ]
head(terms, 10)
```

```
##              term characters number nonalpha termfreq docfreq reldocfreq
## America   America          7  FALSE    FALSE      409     346    0.31743
## year         year          4  FALSE    FALSE      385     286    0.26239
## people     people          6  FALSE    FALSE      327     277    0.25413
## new           new          3  FALSE    FALSE      259     206    0.18899
## job           job          3  FALSE    FALSE      256     190    0.17431
## more         more          4  FALSE    FALSE      255     198    0.18165
## american american          8  FALSE    FALSE      239     210    0.19266
## country   country          7  FALSE    FALSE      228     202    0.18532
## world       world          5  FALSE    FALSE      198     156    0.14312
## tax           tax          3  FALSE    FALSE      181     102    0.09358
##           tfidf
## America  0.1042
## year     0.1181
## people   0.1233
## new      0.1314
## job      0.1692
## more     0.1331
## american 0.1444
## country  0.1329
## world    0.1712
## tax      0.2604
```

As you can see, for each word the total frequency and the relative document frequency is listed, 
as well as some basic information on the number of characters and the occurrence of numerals or non-alphanumeric characters.
This allows us to create a 'common sense' filter to reduce the amount of terms, for example removing all words containing a letter or punctuation mark, and all short (`characters<=2`) infrequent (`termfreq<25`) and overly frequent (`reldocfreq>.5`) words:


```r
subset = terms[!terms$number & !terms$nonalpha & terms$characters>2 & terms$termfreq>=25 & terms$reldocfreq<.25, ]
nrow(subset)
```

```
## [1] 239
```

```r
head(subset, n=10)
```

```
##                term characters number nonalpha termfreq docfreq reldocfreq
## new             new          3  FALSE    FALSE      259     206    0.18899
## job             job          3  FALSE    FALSE      256     190    0.17431
## more           more          4  FALSE    FALSE      255     198    0.18165
## american   american          8  FALSE    FALSE      239     210    0.19266
## country     country          7  FALSE    FALSE      228     202    0.18532
## world         world          5  FALSE    FALSE      198     156    0.14312
## tax             tax          3  FALSE    FALSE      181     102    0.09358
## Americans Americans          9  FALSE    FALSE      179     158    0.14495
## nation       nation          6  FALSE    FALSE      171     150    0.13761
## Congress   Congress          8  FALSE    FALSE      168     149    0.13670
##            tfidf
## new       0.1314
## job       0.1692
## more      0.1331
## american  0.1444
## country   0.1329
## world     0.1712
## tax       0.2604
## Americans 0.1609
## nation    0.1578
## Congress  0.1523
```

This seems more to be a relatively useful set of words. 
We now have about 8 thousand terms left of the original 72 thousand. 
To create a new document-term matrix with only these terms, 
we can use normal matrix indexing on the columns (which contain the words):


```r
dtm_filtered = dtm.filter(dtm, terms=subset$term)
dim(dtm_filtered)
```

```
## [1] 1086  239
```

Which yields a much more managable dtm. 
As a bonus, we can use the `dtm.wordcloud` function in corpustools (which is a thin wrapper around the `wordcloud` package)
to visualize the top words as a word cloud:


```r
dtm.wordcloud(dtm_filtered)
```

![plot of chunk unnamed-chunk-18](figure/unnamed-chunk-18.png) 

Comparing corpora
----

Another useful thing we can do is comparing two corpora: 
Which words or names are mentioned more in e.g. Bush' speeches than Obama's.

To do this, we split the dtm in separate dtm's for Bush and Obama.
For this, we select docment ids using the `headline` column in the metadata from `sotu.meta`, and then use the `dtm.filter` function:



```r
head(sotu.meta)
```

```
##          id   medium     headline       date
## 1 111541965 Speeches Barack Obama 2013-02-12
## 2 111541995 Speeches Barack Obama 2013-02-12
## 3 111542001 Speeches Barack Obama 2013-02-12
## 4 111542006 Speeches Barack Obama 2013-02-12
## 5 111542013 Speeches Barack Obama 2013-02-12
## 6 111542018 Speeches Barack Obama 2013-02-12
```

```r
obama.docs = sotu.meta$id[sotu.meta$headline == "Barack Obama"]
dtm.obama = dtm.filter(dtm, documents=obama.docs)
bush.docs = sotu.meta$id[sotu.meta$headline == "George W. Bush"]
dtm.bush = dtm.filter(dtm, documents=bush.docs)
```

So how can we check which words are more frequent in Bush' speeches than in Obama's speeches?
The function `corpora.compare` provides this functionality, given two document-term matrices:


```r
cmp = corpora.compare(dtm.obama, dtm.bush)
cmp = cmp[order(cmp$over), ]
head(cmp)
```

```
##          term termfreq.x termfreq.y relfreq.x relfreq.y   over   chi
## 939    terror          1         55 8.932e-05  0.004611 0.1942 48.87
## 941 terrorist         13        103 1.161e-03  0.008634 0.2243 64.63
## 389   freedom          8         79 7.145e-04  0.006623 0.2249 53.79
## 507     iraqi          3         49 2.680e-04  0.004108 0.2482 37.95
## 311     enemy          4         52 3.573e-04  0.004359 0.2533 38.29
## 506      Iraq         15         94 1.340e-03  0.007880 0.2635 52.66
```

For each term, this data frame contains the frequency in the 'x' and 'y' corpora (here, Obama and Bush).
Also, it gives the relative frequency in these corpora (normalizing for total corpus size)
and the overrepresentation in the 'x' corpus and the chi-squared value for that overrepresentation.
So, Bush used the word terrorist 105 times, while Obama used it only 13 times, and in relative terms Bush used it about four times as often, which is highly significant. 

Which words did Obama use most compared to Bush?


```r
cmp = cmp[order(cmp$over, decreasing=T), ]
head(cmp)
```

```
##          term termfreq.x termfreq.y relfreq.x relfreq.y  over   chi
## 175   company         54          6  0.004823 5.030e-04 3.874 41.65
## 522       kid         31          0  0.002769 0.000e+00 3.769 33.07
## 72       bank         29          0  0.002590 0.000e+00 3.590 30.94
## 484  industry         32          1  0.002858 8.383e-05 3.560 31.20
## 368 financial         33          2  0.002947 1.677e-04 3.381 29.53
## 166   college         55          9  0.004912 7.545e-04 3.370 36.18
```

So, while Bush talks about freedom, war, and terror, Obama talks more about industry, banks and education. 

Let's make a word cloud of Obama' words, with size indicating chi-square overrepresentation:


```r
obama = cmp[cmp$over > 1,]
dtm.wordcloud(terms = obama$term, freqs = obama$chi)
```

![plot of chunk unnamed-chunk-22](figure/unnamed-chunk-22.png) 

And Bush:


```r
bush = cmp[cmp$over < 1,]
dtm.wordcloud(terms = bush$term, freqs = bush$chi)
```

![plot of chunk unnamed-chunk-23](figure/unnamed-chunk-23.png) 

Note that the warnings given by these commands are relatively harmless: it means that some words are skipped because it couldn't find a good place for them in the word cloud. 
