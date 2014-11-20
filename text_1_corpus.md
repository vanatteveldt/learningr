Corpus analysis: the document-term matrix
=========================================

_(C) 2014 Wouter van Atteveldt, license: [CC-BY-SA]_

The most important object in frequency-based text analysis is the *document term matrix*. 
This matrix contains the documents in the rows and terms (words) in the columns, 
and each cell is the frequency of that term in that document.

In R, these matrices are provided by the `tm` (text mining) package. 
Although this package provides many functions for loading and manipulating these matrices,
using them directly is relatively complicated. 

Fortunately, the `RTextTools` package provides an easy function to create a document-term matrix from a data frame. To create a term document matrix from a simple data frame with a 'text' column, use the `create_matrix` function


```r
library(RTextTools)
input = data.frame(text=c("Chickens are birds", "The bird eats"))
m = create_matrix(input$text, removeStopwords=F)
```

We can inspect the resulting matrix using the regular R functions:


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

So, `m` is a `DocumentTermMatrix`, which is derived from a `simple_triplet_matrix` as provided by the `slam` package. 
Internally, document-term matrices are stored as a _sparse matrix_: 
if we do use real data, we can easily have hundreds of thousands of rows and columns, while   the vast majority of cells will be zero (most words don't occur in most documents).
Storing this as a regular  matrix would waste a lot of memory.
In a sparse matrix, only the non-zero entries are stored, as 'simple triplets' of (document, term, frequency). 

As seen in the output of `dim`, Our matrix has only 2 rows (documents) and 6 columns (unqiue words).
Since this is a rather small matrix, we can visualize it using `as.matrix`, which converts the 'sparse' matrix into a regular matrix:


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
We can reduce the size of the matrix by dropping stop words and stemming:
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

For Dutch, the result is less promising:


```r
text = c("De kip eet", "De kippen hebben gegeten")
m = create_matrix(text, removeStopwords=T, stemWords=T, language="dutch")
colSums(as.matrix(m))
```

```
##   eet geget   kip  kipp 
##     1     1     1     1
```

As you can see, _de_ and _hebben_ are correctly recognized as stop words, but _gegeten_ and _kippen_ have a different stem than _eet_ and _kip_. 

Loading and analysing a larger dataset
-----

Let's have a look at a more serious example.
The file `achmea.csv` contains 22 thousand customer reviews, of which around 5 thousand have been manually coded with sentiment. 
This file can be downloaded from [github](https://raw.githubusercontent.com/vanatteveldt/learningr/master/achmea.csv)


```r
d = read.csv("achmea.csv")
colnames(d)
```

```
##  [1] "ARTICLE_ID"    "AUTHOR"        "AUTHOR_MAIL"   "CONTENT"      
##  [5] "SOURCE"        "ACHMEA_LABEL"  "TOPIC"         "SOURCE_RATING"
##  [9] "RATING"        "SENTIMENT"     "CONTENT_URL"   "DATUM"
```

For this example, we will only be using the `CONTENT` and `SENTIMENT` columns. 
We will load it, without stemming but with stopword removal, using `create_matrix`:


```r
m = create_matrix(d$CONTENT, removeStopwords=T, language="dutch")
dim(m)
```

```
## [1] 21358 29022
```

Corpus analysis: word frequency
-----

What are the most frequent words in the corpus? 
As shown above, we could use the built-in `colSums` function,
but this requires first casting the sparse matrix to a regular matrix, 
which we want to avoid (even our relatively small dataset would have 400 million entries!).
So, we use the `col_sums` function from the `slam` package, which provides the same functionality for sparse matrices:


```r
library(slam)
freq = col_sums(m)
# sort the list by reverse frequency using built-in order function:
freq = freq[order(-freq)]
head(freq, n=10)
```

```
##           httpt       apeldoorn            even          bellen 
##            6437            5578            5070            4771 
##        centraal          beheer            fbto  centraalbeheer 
##            4519            4471            4129            3330 
##          achmea zorgverzekering 
##            2325            1359
```

As can be seen, the most frequent terms are all related to Achmea (unsurprisingly).
It can be useful to compute different metrics per term, such as term frequency, document frequency (how many documents does it occur), and td.idf (term frequency * inverse document frequency, which removes both rare and overly frequent terms). 

To make this easy, let's define a function `term.statistics` to compute this information from a document-term matrix (also available from the [corpustools](http:/github.com/kasperwelbers/corpustools) package)



```r
library(tm)
term.statistics <- function(dtm) {
    dtm = dtm[row_sums(dtm) > 0,col_sums(dtm) > 0]    # get rid of empty rows/columns
    vocabulary = colnames(dtm)
    data.frame(term = vocabulary,
               characters = nchar(vocabulary),
               number = grepl("[0-9]", vocabulary),
               nonalpha = grepl("\\W", vocabulary),
               termfreq = col_sums(dtm),
               docfreq = col_sums(dtm > 0),
               reldocfreq = col_sums(dtm > 0) / nDocs(dtm),
               tfidf = tapply(dtm$v/row_sums(dtm)[dtm$i], dtm$j, mean) * log2(nDocs(dtm)/col_sums(dtm > 0)))
}
terms = term.statistics(m)
head(terms)
```

```
##      term characters number nonalpha termfreq docfreq reldocfreq  tfidf
## 000   000          3   TRUE    FALSE       21      20  9.421e-04 0.7282
## 0000 0000          4   TRUE    FALSE       80      80  3.768e-03 0.2818
## 0011 0011          4   TRUE    FALSE        1       1  4.711e-05 0.6845
## 002   002          3   TRUE    FALSE        1       1  4.711e-05 0.5749
## 0058 0058          4   TRUE    FALSE        1       1  4.711e-05 1.4374
## 010   010          3   TRUE    FALSE        6       6  2.826e-04 0.4065
```

So, we can remove all words containing numbers and non-alphanumeric characters, and sort by document frequency:


```r
terms = terms[!terms$number & !terms$nonalpha, ]
terms = terms[order(-terms$termfreq), ]
head(terms)
```

```
##                term characters number nonalpha termfreq docfreq reldocfreq
## httpt         httpt          5  FALSE    FALSE     6437    5826     0.2744
## apeldoorn apeldoorn          9  FALSE    FALSE     5578    4974     0.2343
## even           even          4  FALSE    FALSE     5070    4605     0.2169
## bellen       bellen          6  FALSE    FALSE     4771    4352     0.2050
## centraal   centraal          8  FALSE    FALSE     4519    4282     0.2017
## beheer       beheer          6  FALSE    FALSE     4471    4240     0.1997
##            tfidf
## httpt     0.2157
## apeldoorn 0.2591
## even      0.2665
## bellen    0.2781
## centraal  0.2126
## beheer    0.2139
```

This is still not a very useful list, as the top terms occur in too many documents to be informative. So, let's remove all words that occur in more than 10% of documents, and let's also remove all words that occur in less than 10 documents:


```r
terms = terms[terms$reldocfreq < .1 & terms$docfreq > 10, ]
nrow(terms)
```

```
## [1] 2316
```

```r
head(terms)
```

```
##                            term characters number nonalpha termfreq
## achmea                   achmea          6  FALSE    FALSE     2325
## zorgverzekering zorgverzekering         15  FALSE    FALSE     1359
## nieuwe                   nieuwe          6  FALSE    FALSE     1304
## auto                       auto          4  FALSE    FALSE     1262
## via                         via          3  FALSE    FALSE     1232
## commercial           commercial         10  FALSE    FALSE     1196
##                 docfreq reldocfreq  tfidf
## achmea             2122    0.09996 0.2938
## zorgverzekering     734    0.03458 0.7724
## nieuwe             1260    0.05935 0.4016
## auto               1169    0.05507 0.4210
## via                1188    0.05596 0.3792
## commercial         1065    0.05017 0.3981
```

This seems more useful. We now have 2316 terms left of the original 20 thousand. 
To create a new document-term matrix with only these terms, index on the right columns:


```r
m_filtered = m[, colnames(m) %in% terms$term]
dim(m_filtered)
```

```
## [1] 21358  2316
```


As a bonus, using the `wordcloud` package, we can visualize the top words as a word cloud:


```r
library(RColorBrewer)
library(wordcloud)
pal <- brewer.pal(6,"YlGnBu") # color model
wordcloud(terms$term[1:100], terms$termfreq[1:100], 
          scale=c(6,.5), min.freq=1, max.words=Inf, random.order=FALSE, 
          rot.per=.15, colors=pal)
```

![plot of chunk unnamed-chunk-14](figure/unnamed-chunk-14.png) 

Comparing corpora
----

If we have two different corpora, we can see which words are more frequent in each corpus. 
Let's create two d-t matrices, one containing all positive comments, and one containing all negative comments. 


```r
table(d$SENTIMENT)
```

```
## 
##   -1    1 
## 2249 3066
```

```r
pos = d$CONTENT[!is.na(d$SENTIMENT) & d$SENTIMENT == 1]
m_pos = create_matrix(pos, removeStopwords=T, language="dutch")
neg = d$CONTENT[!is.na(d$SENTIMENT) & d$SENTIMENT == -1]
m_neg = create_matrix(neg, removeStopwords=T, language="dutch")
```

So, which words are used in positive reviews? Lets make a function to speed it up


```r
wordfreqs = function(m) {freq = col_sums(m); freq[order(-freq)]}
head(wordfreqs(m_pos))
```

```
##      snelle afhandeling        snel       goede        goed        fbto 
##         496         425         421         393         386         317
```

And what words are used in negative reviews?


```r
head(wordfreqs(m_neg))
```

```
##        fbto         wel        jaar       klant verzekering      schade 
##         501         301         222         218         217         208
```

For the positive reviews, the words made sense (_goed_, _snel_). The negative contain more general terms, and the term _fbto_ actually occurs in both. 

Can we check which words are more frequent in the negative reviews than in the positive?
We can define a function `compara.corpora` that makes this comparison by normalizing the term frequencies by dividing by corpus size, and then computing the 'overrepresentation' and the chi-squared statistic (also available from the [corpustools](http:/github.com/kasperwelbers/corpustools) package).



```r
chi2 <- function(a,b,c,d) {
  ooe <- function(o, e) {(o-e)*(o-e) / e}
  tot = 0.0 + a+b+c+d
  a = as.numeric(a)
  b = as.numeric(b)
  c = as.numeric(c)
  d = as.numeric(d)
  (ooe(a, (a+c)*(a+b)/tot)
   +  ooe(b, (b+d)*(a+b)/tot)
   +  ooe(c, (a+c)*(c+d)/tot)
   +  ooe(d, (d+b)*(c+d)/tot))
}

compare.corpora <- function(dtm.x, dtm.y, smooth=.001) {
  freqs = term.statistics(dtm.x)[, c("term", "termfreq")]
  freqs.rel = term.statistics(dtm.y)[, c("term", "termfreq")]
  f = merge(freqs, freqs.rel, all=T, by="term")    
  f[is.na(f)] = 0
  f$relfreq.x = f$termfreq.x / sum(freqs$termfreq)
  f$relfreq.y = f$termfreq.y / sum(freqs.rel$termfreq)
  f$over = (f$relfreq.x + smooth) / (f$relfreq.y + smooth)
  f$chi = chi2(f$termfreq.x, f$termfreq.y, sum(f$termfreq.x) - f$termfreq.x, sum(f$termfreq.y) - f$termfreq.y)
  f
}

cmp = compare.corpora(m_pos, m_neg)
head(cmp)
```

```
##         term termfreq.x termfreq.y relfreq.x relfreq.y   over     chi
## 1        088          1          0 4.817e-05 0.0000000 1.0482  1.4670
## 2       0900          9          0 4.335e-04 0.0000000 1.4335 13.2047
## 3 0900nummer          1          0 4.817e-05 0.0000000 1.0482  1.4670
## 4        100          5         11 2.408e-04 0.0003612 0.9116  0.5726
## 5        101          1          0 4.817e-05 0.0000000 1.0482  1.4670
## 6   10echter          1          0 4.817e-05 0.0000000 1.0482  1.4670
```

As you can see, for each term the absolute and relative frequencies are given for both corpora. In this case, `x` is positive and `y` is negative. 
The 'over' column shows the amount of overrepresentation: a high number indicates that it is relatively more frequent in the x (positive) corpus. 'Chi' is a measure of how unexpected this overrepresentation is: a high number means that it is a very typical term for that corpus.

Let's sort by overrepresentation:


```r
cmp = cmp[order(cmp$over), ]
head(cmp)
```

```
##         term termfreq.x termfreq.y relfreq.x relfreq.y   over   chi
## 2979  risico         14        131 0.0006743  0.004301 0.3158 57.53
## 610    beter         10        106 0.0004817  0.003481 0.3307 49.13
## 2118 maanden          5         83 0.0002408  0.002725 0.3331 44.43
## 4029     wel         55        301 0.0026492  0.009883 0.3353 93.60
## 1841  jammer          4         76 0.0001927  0.002495 0.3412 41.98
## 1918 klanten         20        126 0.0009633  0.004137 0.3822 43.75
```

So, the most overrepresented words in the negative corpus are words like _risico_, _beter_, and _maanden_. Note that _beter_ is sort of surprising, a sentiment word list would probably think this is a positive words. 

We can also sort by chi-squared, taking only the underrepresented (negative) words:


```r
neg = cmp[cmp$over < 1, ]
neg = neg[order(-neg$chi), ]
head(neg)
```

```
##         term termfreq.x termfreq.y relfreq.x relfreq.y   over   chi
## 4029     wel         55        301 0.0026492  0.009883 0.3353 93.60
## 2979  risico         14        131 0.0006743  0.004301 0.3158 57.53
## 610    beter         10        106 0.0004817  0.003481 0.3307 49.13
## 2118 maanden          5         83 0.0002408  0.002725 0.3331 44.43
## 2773  premie         23        135 0.0011078  0.004433 0.3880 44.38
## 1918 klanten         20        126 0.0009633  0.004137 0.3822 43.75
```

As you can see, the list is very comparable, but more frequent terms are generally favoured in the chi-squared approach since the chance of 'accidental' overrepresentation is smaller. 

Let's make a word cloud of the most frequent negative terms:


```r
pal <- brewer.pal(6,"YlGnBu") # color model
wordcloud(neg$term[1:100], neg$chi[1:100], 
          scale=c(6,.5), min.freq=1, max.words=Inf, random.order=FALSE, 
          rot.per=.15, colors=pal)
```

![plot of chunk unnamed-chunk-21](figure/unnamed-chunk-21.png) 

And the positive terms:


```r
pos = cmp[cmp$over > 1, ]
pos = pos[order(-pos$chi), ]
wordcloud(pos$term[1:100], pos$chi[1:100]^.5, 
          scale=c(6,.5), min.freq=1, max.words=Inf, random.order=FALSE, 
          rot.per=.15, colors=pal)
```

![plot of chunk unnamed-chunk-22](figure/unnamed-chunk-22.png) 


