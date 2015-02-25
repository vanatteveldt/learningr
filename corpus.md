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
t = t[t$pos1 %in% c("V", "N"), ]
dtm = dtm.create(documents=t$sentence, terms=t$lemma)
as.matrix(dtm)
```

```
##     Terms
## Docs chicken be bird eat
##    1       1  1    1   0
##    2       0  0    1   1
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
## Created articleset 17700: Test Florence in project 1
## Uploading 1 articles to set 17700
```

And we can then lemmatize this article and download the results directly to R
using `amcat.gettokens`:


```r
amcat.gettokens(conn, project=688, articleset = aset, module = "corenlp_lemmatize")
```

```
## GET http://preview.amcat.nl/api/v4/projects/688/articlesets/17700/tokens/?page=1&module=corenlp_lemmatize&page_size=1&format=csv
## GET http://preview.amcat.nl/api/v4/projects/688/articlesets/17700/tokens/?page=2&module=corenlp_lemmatize&page_size=1&format=csv
```

```
##        word pos   lemma       aid pos1 freq
## 1         ,   ,       , 114440106    .    1
## 2         a  DT       a 114440106    D    1
## 3       and  CC     and 114440106    C    1
## 4  chickens NNS chicken 114440106    N    1
## 5       fan  NN     fan 114440106    N    1
## 6     great  JJ   great 114440106    A    1
## 7        is VBZ      be 114440106    V    2
## 8      John NNP    John 114440106    M    1
## 9      Mary NNP    Mary 114440106    M    1
## 10       of  IN      of 114440106    P    1
## 11       so  RB      so 114440106    B    1
```

And we can see that e.g. for "is" the lemma "be" is given. 
Note that the words are not in order, and the two occurrences of "is" are automatically summed. 
This can be switched off by giving `drop=NULL` as extra argument.



For a more serious application, we will use an existing article set: [set 17667](https://amcat.nl/navigator/projects/688/articlesets/) in project 688, which contains American newspaper coverage about the 2009 Gaza war.
The analysed tokens for this set can be downloaded with the following command:


```r
t = amcat.gettokens(conn, project=688, articleset = 17667, module = "corenlp_lemmatize", page_size = 100, drop=NULL)
save(t, file="tokens_17667.rda")
```

Note that the first time you run this command on an article set, the articles will be preprocessed on the fly, so it could take quite a long time. 
After this, however, the results are stored in the AmCAT database so getting te tokens should go relatively quickly, although still only around 10 articles per second - so it is wise to save the tokens after getting them using R's `save` command, so they can be loaded quickly 

```r
save(t, file="tokens_17667.rda")
```


```r
load("tokens_17667.rda")
nrow(t)
```

```
## [1] 7669594
```

```r
head(t, n=20)
```

```
##         word sentence   pos     lemma offset      aid id pos1 freq
## 1       Dec.        1   NNP      Dec.      0 26074649  1    M    1
## 2         29        1    CD        29      5 26074649  2    Q    1
## 3          ,        1     ,         ,      7 26074649  3    .    1
## 4       2008        1    CD      2008      9 26074649  4    Q    1
## 5      -LRB-        1 -LRB-     -lrb-     14 26074649  5    .    1
## 6        The        1    DT       the     15 26074649  6    D    1
## 7    Western        1    JJ   western     19 26074649  7    A    1
## 8  Confucian        1    JJ confucian     27 26074649  8    A    1
## 9  delivered        1   VBN   deliver     37 26074649  9    V    1
## 10        by        1    IN        by     47 26074649 10    P    1
## 11   Newstex        1   NNP   Newstex     50 26074649 11    M    1
## 12     -RRB-        1 -RRB-     -rrb-     57 26074649 12    .    1
## 13        --        1     :        --     59 26074649 13    .    1
## 14        ``        1    ``        ``     62 26074649 14    .    1
## 15         I        1   PRP         I     63 26074649 15    O    1
## 16      dont        1   VBP      dont     65 26074649 16    V    1
## 17     think        1    VB     think     70 26074649 17    V    1
## 18     there        1    EX     there     76 26074649 18    ?    1
## 19        is        1   VBZ        be     82 26074649 19    V    1
## 20      such        1    JJ      such     85 26074649 20    A    1
```

As you can see, the result is similar to the ad-hoc lemmatized tokens, but now we have around 8 million tokens rather than 6.
We can create a document-term matrix using the same commands as above, restricting ourselves to nouns, names, verbs, and adjectives:



```r
t = t[t$pos1 %in% c("V", "N", 'M', 'A'), ]
dtm = dtm.create(documents=t$aid, terms=t$lemma)
```

```
## (Duplicate row-column matches occured. Values of duplicates are added up)
```

```r
dtm
```

```
## <<DocumentTermMatrix (documents: 6893, terms: 72364)>>
## Non-/sparse entries: 1840938/496964114
## Sparsity           : 100%
## Maximal term length: 80
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
##      be    have     say    Gaza  Israel      do   Hamas      go    will 
##  274308   84449   48738   39912   39665   38138   28976   25433   24795 
## israeli 
##   21720
```

As can be seen, the most frequent terms are all the main actors/countries involved and the 'stop' words be, have, etc.
It can be useful to compute different metrics per term, such as term frequency, document frequency (how many documents does it occur), and td.idf (term frequency * inverse document frequency, which removes both rare and overly frequent terms). 
The function `term.statistics` from the `corpus-tools` package provides this functionality:



```r
terms = term.statistics(dtm)
terms = terms[order(-terms$termfreq), ]
head(terms)
```

```
##          term characters number nonalpha termfreq docfreq reldocfreq
## be         be          2  FALSE    FALSE   274308    6821     0.9896
## have     have          4  FALSE    FALSE    84449    6447     0.9353
## say       say          3  FALSE    FALSE    48738    5487     0.7960
## Gaza     Gaza          4  FALSE    FALSE    39912    6681     0.9692
## Israel Israel          6  FALSE    FALSE    39665    5763     0.8361
## do         do          2  FALSE    FALSE    38138    4697     0.6814
##            tfidf
## be     0.0008801
## have   0.0020563
## say    0.0058860
## Gaza   0.0007637
## Israel 0.0050127
## do     0.0051696
```

As you can see, for each word the total frequency and the relative document frequency is listed, 
as well as some basic information on the number of characters and the occurrence of numerals or non-alphanumeric characters.
This allows us to create a 'common sense' filter to reduce the amount of terms, for example removing all words containing a letter or punctuation mark, and all short (`characters<=2`) infrequent (`termfreq<25`) and overly frequent (`reldocfreq>.5`) words:


```r
subset = terms[!terms$number & !terms$nonalpha & terms$characters>2 & terms$termfreq>=25 & terms$reldocfreq<.5, ]
nrow(subset)
```

```
## [1] 8423
```

```r
head(subset, n=10)
```

```
##        term characters number nonalpha termfreq docfreq reldocfreq
## get     get          3  FALSE    FALSE    17387    2744     0.3981
## know   know          4  FALSE    FALSE    14913    2300     0.3337
## Obama Obama          5  FALSE    FALSE    13759    2010     0.2916
## think think          5  FALSE    FALSE    13074    2006     0.2910
## see     see          3  FALSE    FALSE    12640    3212     0.4660
## make   make          4  FALSE    FALSE    11491    3441     0.4992
## year   year          4  FALSE    FALSE    11292    3123     0.4531
## time   time          4  FALSE    FALSE    10485    3349     0.4859
## come   come          4  FALSE    FALSE    10376    2988     0.4335
## end     end          3  FALSE    FALSE     9549    3266     0.4738
##          tfidf
## get   0.007402
## know  0.008089
## Obama 0.017005
## think 0.009221
## see   0.005433
## make  0.004985
## year  0.005910
## time  0.004964
## come  0.005349
## end   0.005763
```

This seems more to be a relatively useful set of words. 
We now have about 8 thousand terms left of the original 72 thousand. 
To create a new document-term matrix with only these terms, 
we can use normal matrix indexing on the columns (which contain the words):


```r
dtm_filtered = dtm[, colnames(dtm) %in% subset$term]
dim(dtm_filtered)
```

```
## [1] 6893 8423
```

Which yields a much more managable dtm. 
As a bonus, we can use the `dtm.wordcloud` function in corpustools (which is a thin wrapper around the `wordcloud` package)
to visualize the top words as a word cloud:


```r
dtm.wordcloud(dtm_filtered)
```

![plot of chunk unnamed-chunk-20](figure/unnamed-chunk-20.png) 

Note that such corpus analytics might not seem very informative, but it is quite easy to use this to e.g. see which names occur in a set of documents, as we do with the following commands (filtering t on `pos1==M` for naMe):


```r
names = t[t$pos1 == 'M', ]
dtm_names = dtm.create(names$aid, names$lemma)
```

```
## (Duplicate row-column matches occured. Values of duplicates are added up)
```

```r
name.terms = term.statistics(dtm_names)
name.terms  = name.terms [order(-name.terms$termfreq), ]
head(name.terms )
```

```
##                      term characters number nonalpha termfreq docfreq
## Gaza                 Gaza          4  FALSE    FALSE    39912    6681
## Israel             Israel          6  FALSE    FALSE    39665    5763
## Hamas               Hamas          5  FALSE    FALSE    28976    4845
## Obama               Obama          5  FALSE    FALSE    13759    2010
## Palestinians Palestinians         12  FALSE    FALSE     7277    3327
## United             United          6  FALSE    FALSE     6923    2813
##              reldocfreq    tfidf
## Gaza             0.9698 0.003518
## Israel           0.8366 0.023505
## Hamas            0.7033 0.038803
## Obama            0.2918 0.080890
## Palestinians     0.4829 0.029633
## United           0.4083 0.032329
```

And of course we can visualize this (using a square root transformation of the frequency to prevent the top names from dominating the word cloud):


```r
dtm.wordcloud(dtm_names, freq.fun = sqrt)
```

![plot of chunk unnamed-chunk-22](figure/unnamed-chunk-22.png) 

Comparing corpora
----

Another useful thing we can do is comparing two corpora: 
Which words or names are mentioned more in e.g. one country or speech compared to another.
To do this, we get the tokens from set 17668, which contains the coverage of the Gaza war in newspapers from Islamic countries. 



```r
t2 = amcat.gettokens(conn, project=688, articleset = 17668, module = "corenlp_lemmatize", page_size = 100, drop=NULL)
save(t2, file="tokens_17668.rda")
```

And we create a term-document matrix from the second article set as well:


```r
load("tokens_17668.rda")
t2 = t2[t2$pos1 %in% c("V", "N", 'M', 'A'), ]
dtm2 = dtm.create(documents=t2$aid, terms=t2$lemma)
```

```
## (Duplicate row-column matches occured. Values of duplicates are added up)
```

```r
dtm2
```

```
## <<DocumentTermMatrix (documents: 846, terms: 15782)>>
## Non-/sparse entries: 141939/13209633
## Sparsity           : 99%
## Maximal term length: 79
## Weighting          : term frequency (tf)
```

Let's also remove the non-informative words from this matrix:


```r
terms2 = term.statistics(dtm2)
subset2 = terms2[!terms2$number & !terms2$nonalpha & terms2$characters>2 & terms2$termfreq>=25 & terms2$reldocfreq<.5, ]
dtm2_filtered = dtm2[, colnames(dtm2) %in% subset2$term]
```

So how can we check which words are more frequent in the American discourse than in the 'Islamic' discource?
The function `corpora.compare` provides this functionality, given two document-term matrices:


```r
cmp = corpora.compare(dtm_filtered, dtm2_filtered)
cmp = cmp[order(cmp$over), ]
head(cmp)
```

```
##        term termfreq.x termfreq.y relfreq.x relfreq.y    over   chi
## 8439  Hamas          0       1457         0  0.011079 0.08279 29793
## 8431    can          0        789         0  0.005999 0.14287 16130
## 8430   call          0        782         0  0.005946 0.14396 15986
## 8426 attack          0        687         0  0.005224 0.16067 14044
## 8480   take          0        661         0  0.005026 0.16594 13512
## 8466  other          0        643         0  0.004889 0.16980 13144
```

As you can see, for each term the absolute and relative frequencies are given for both corpora. 
In this case, `x` is American newspapers and `y` is Muslim-country newspapers. 
The 'over' column shows the amount of overrepresentation: a high number indicates that it is relatively more frequent in the x (positive) corpus. 'Chi' is a measure of how unexpected this overrepresentation is: a high number means that it is a very typical term for that corpus.
Since the output above is sorted by ascending overrepresentation, these terms are the overrepresented terms in the Muslim-country newspapers. Let's have a look at the American papers:


```r
cmp = cmp[order(-cmp$over), ]
head(cmp, n=10)
```

```
##              term termfreq.x termfreq.y relfreq.x relfreq.y  over   chi
## 5431 Palestinians       7277          0  0.002707  0.000000 3.707 357.0
## 7614        think      13074        140  0.004864  0.001065 2.840 388.0
## 1391          CNN       4858          0  0.001807  0.000000 2.807 238.1
## 4221         know      14913        184  0.005548  0.001399 2.730 405.3
## 8064        video       3908          0  0.001454  0.000000 2.454 191.5
## 6749       Senate       3808          0  0.001417  0.000000 2.417 186.6
## 3130          get      17387        294  0.006469  0.002236 2.308 360.6
## 1373         clip       3139          0  0.001168  0.000000 2.168 153.8
## 4504          lot       5234         48  0.001947  0.000365 2.159 167.9
## 7597        thank       2914          0  0.001084  0.000000 2.084 142.7
```

So, to draw very precocious conclusions, Americans seem to talk about Palestinians and politics, 
while the Muslim-countries talk about Hamas and fighting.

Let's make a word cloud of the words in the American papers, with size indicating chi-square overrepresentation:


```r
us = cmp[cmp$over > 1,]
dtm.wordcloud(terms = us$term, freqs = us$chi)
```

![plot of chunk unnamed-chunk-28](figure/unnamed-chunk-28.png) 

And for the Muslim-country papers:


```r
mus = cmp[cmp$over < 1,]
dtm.wordcloud(terms = mus$term, freqs = mus$chi, freq.fun = sqrt)
```

![plot of chunk unnamed-chunk-29](figure/unnamed-chunk-29.png) 

As you can see, these differences are for a large part due to place names: American papers talk about American states and cities, while Muslim-country papers talk about their localities. 

So, it can be more informative to exclude names, and focus instead on e.g. the used nouns or verbs:


```r
nouns = t[t$pos1 == "N" & t$lemma %in% subset$term, ]
nouns2 = t2[t2$pos1 == "N" & t2$lemma %in% subset2$term, ]
cmp = corpora.compare(dtm.create(nouns$aid, nouns$lemma), dtm.create(nouns2$aid, nouns2$lemma))
```

```
## (Duplicate row-column matches occured. Values of duplicates are added up)
## (Duplicate row-column matches occured. Values of duplicates are added up)
```

```r
with(cmp[cmp$over > 1,], dtm.wordcloud(terms=term, freqs=chi))
```

![plot of chunk unnamed-chunk-30](figure/unnamed-chunk-301.png) 

```r
with(cmp[cmp$over < 1,], dtm.wordcloud(terms=term, freqs=chi, freq.fun=sqrt))
```

![plot of chunk unnamed-chunk-30](figure/unnamed-chunk-302.png) 

```r
verbs = t[t$pos1 == "V" & t$lemma %in% subset$term, ]
verbs2 = t2[t2$pos1 == "V" & t2$lemma %in% subset2$term, ]
cmp = corpora.compare(dtm.create(verbs$aid, verbs$lemma), dtm.create(verbs2$aid, verbs2$lemma))
```

```
## (Duplicate row-column matches occured. Values of duplicates are added up)
## (Duplicate row-column matches occured. Values of duplicates are added up)
```

```r
with(cmp[cmp$over > 1,], dtm.wordcloud(terms=term, freqs=chi, freq.fun=sqrt))
```

![plot of chunk unnamed-chunk-30](figure/unnamed-chunk-303.png) 

```r
with(cmp[cmp$over < 1,], dtm.wordcloud(terms=term, freqs=chi, freq.fun=log))
```

![plot of chunk unnamed-chunk-30](figure/unnamed-chunk-304.png) 

Topic Modeling
-------

Topics can be seen as groups of words that cluster together.
Similar to factor analysis, topic modeling reduces the dimensionality of the feature space (the term-document matrix)
assuming that the latent factors (the topics) will correspond to meaningful latent classes (e.g. issues, frames)
With a given dtm, a topic model can be trained using the `topmod.lda.fit` function:


```r
set.seed(12345)
m = topmod.lda.fit(dtm_filtered, K = 10, alpha = .5)
terms(m, 10)
```

```
##       Topic 1  Topic 2   Topic 3        Topic 4     Topic 5  
##  [1,] "think"  "percent" "war"          "Egypt"     "protest"
##  [2,] "get"    "price"   "peace"        "official"  "police" 
##  [3,] "know"   "year"    "Palestinians" "end"       "group"  
##  [4,] "want"   "market"  "world"        "Minister"  "child"  
##  [5,] "make"   "oil"     "Israelis"     "border"    "year"   
##  [6,] "thing"  "gas"     "state"        "leader"    "New"    
##  [7,] "Senate" "company" "year"         "President" "student"
##  [8,] "talk"   "fall"    "terrorist"    "Arab"      "city"   
##  [9,] "see"    "money"   "should"       "stop"      "hold"   
## [10,] "look"   "GLICK"   "civilian"     "offensive" "rally"  
##       Topic 6         Topic 7          Topic 8        Topic 9    Topic 10
##  [1,] "Council"       "Obama"          "civilian"     "kill"     "get"   
##  [2,] "support"       "Bush"           "humanitarian" "fire"     "know"  
##  [3,] "resolution"    "president"      "food"         "military" "see"   
##  [4,] "situation"     "President"      "child"        "militant" "CNN"   
##  [5,] "United"        "administration" "aid"          "ground"   "come"  
##  [6,] "follow"        "Barack"         "medical"      "civilian" "look"  
##  [7,] "send"          "Clinton"        "supplies"     "official" "think" 
##  [8,] "international" "new"            "Nations"      "force"    "want"  
##  [9,] "ceasefire"     "House"          "school"       "soldier"  "video" 
## [10,] "Group"         "Washington"     "United"       "strike"   "lot"
```

The `terms` command gives the top N terms per topic, with each column forming a topic.
Although interpreting topics on the top words alone is always iffy, it seems that most of the topics have a distinct meaning.
For example, topic 3 seems to be about the conflict itself (echoing Tolstoy), while topic 9 describes the episodic action on the ground.
Topic 4 and 6 seem mainly about international (Arabic and UN) politics, while topic 7 covers American politics.
Topics 1 and 10 are seemingly 'mix-in' topics with various verbs, although it would be better to see usage in context for interpreting such less obvious topics.
(note the use of `set.seed` to make sure that running this again will yield the same topics. 
Since LDA topics are unordered, running it again will create (slightly) different topics, but certainly with different numbers)

Of course, we can also create word clouds of each topic to visualize the top-words:


```r
topmod.plot.wordcloud(m, topic_nr = 9)
```

![plot of chunk unnamed-chunk-32](figure/unnamed-chunk-32.png) 

If we retrieve the meta-date (e.g. article dates, medium), we can make a more informative plot:


```r
meta = amcat.getarticlemeta(conn, set=17667)
meta = meta[match(m@documents, meta$id), ]
head(meta)
```

```
##            id       date                    medium length
## 13   26074690 2009-01-01               Treppenwitz    513
## 1485 26079516 2008-12-30 Palm Beach Post (Florida)    529
## 1800 26080505 2009-01-06 Palm Beach Post (Florida)    387
## 3275 26084977 2009-01-12 Palm Beach Post (Florida)    414
## 3423 26085541 2009-01-20                     MSNBC   7745
## 4710 26089587 2009-01-16          Fox News Network   7924
```

```r
head(rownames(dtm_filtered))
```

```
## [1] "26074690" "26079516" "26080505" "26084977" "26085541" "26089587"
```
As you can see, the `meta` variable contains the date and medium per article, with the `meta$id` matching the rownames of the document-term matrix. 
Note that we put the meta data in the same ordering as the documents in m to make sure that they line up.

Since this data set contains too many separate sources to plot, we create an "other" category for all but the largest sources


```r
top_media = head(sort(table(meta$medium), decreasing = T), n=10)
meta$medium2 = ifelse(meta$medium %in% names(top_media), as.character(meta$medium), "(other)")
table(meta$medium2)
```

```
## 
##                Associated Press Online 
##                                    607 
##                                    CNN 
##                                    330 
##                                CNN.com 
##                                    133 
##                        Digital Journal 
##                                    123 
##            National Public Radio (NPR) 
##                                    159 
##                   NBC News Transcripts 
##                                    133 
##                                (other) 
##                                   4300 
## Pittsburgh Post-Gazette (Pennsylvania) 
##                                    109 
##                    States News Service 
##                                    668 
##                     The New York Times 
##                                    197 
##                    The Washington Post 
##                                    133
```
Now, we can use the `topmod.plot.topic` function to create a combined graph with the word cloud and distribution over time and media:


```r
topmod.plot.topic(m, 9, time_var = meta$date, category_var = meta$medium2, date_interval = "day")
```

![plot of chunk unnamed-chunk-35](figure/unnamed-chunk-351.png) 

```r
topmod.plot.topic(m, 7, time_var = meta$date, category_var = meta$medium2, date_interval = "day")
```

![plot of chunk unnamed-chunk-35](figure/unnamed-chunk-352.png) 

This shows that the press agency strongly focuses on episodic coverage, while CNN has more political stories.
Also, you can see that the initial coverage is dominated by the war itself, while later news is more politicised. 

Since topic modeling is based on the document-term matrix, it is very important to preprocess this matrix before fitting a model.
In this case, we used the dtm_filtered matrix created above, which is lemmatized text selected on minimum and maximum frequency.
It can also be interesting to use e.g. only nouns:


```r
set.seed(123456)
nouns = t[t$pos1 == "N" & t$lemma %in% subset$term, ]
dtm.nouns = dtm.create(nouns$aid, nouns$lemma)
```

```
## (Duplicate row-column matches occured. Values of duplicates are added up)
```

```r
m.nouns = topmod.lda.fit(dtm.nouns, K = 10, alpha = .5)
terms(m.nouns, 10)
```

```
##       Topic 1      Topic 2      Topic 3  Topic 4   Topic 5         
##  [1,] "money"      "official"   "year"   "lot"     "president"     
##  [2,] "job"        "border"     "time"   "video"   "administration"
##  [3,] "tax"        "leader"     "child"  "thing"   "country"       
##  [4,] "state"      "truce"      "family" "today"   "policy"        
##  [5,] "economy"    "effort"     "school" "clip"    "issue"         
##  [6,] "governor"   "offensive"  "man"    "time"    "question"      
##  [7,] "year"       "talk"       "home"   "end"     "year"          
##  [8,] "plan"       "force"      "life"   "way"     "time"          
##  [9,] "today"      "resolution" "woman"  "morning" "world"         
## [10,] "government" "minister"   "event"  "right"   "way"           
##       Topic 6      Topic 7     Topic 8       Topic 9   Topic 10    
##  [1,] "police"     "ground"    "aid"         "percent" "peace"     
##  [2,] "group"      "fire"      "situation"   "price"   "war"       
##  [3,] "protest"    "civilian"  "food"        "year"    "world"     
##  [4,] "newspaper"  "official"  "ceasefire"   "market"  "state"     
##  [5,] "email"      "soldier"   "resolution"  "oil"     "conflict"  
##  [6,] "fax"        "area"      "supplies"    "gas"     "year"      
##  [7,] "copyright"  "force"     "child"       "company" "side"      
##  [8,] "protester"  "militant"  "conflict"    "stock"   "civilian"  
##  [9,] "government" "operation" "information" "week"    "government"
## [10,] "leader"     "border"    "civilian"    "barrel"  "violence"
```

As you can see, this gives similar topics as above, but without the proper names they are more difficult to interpret. 
Doing the same for verbs gives a different take on things, yielding semantic classes rather than substantive topics:


```r
set.seed(123456)
verbs = t[t$pos1 == "V" & t$lemma %in% subset$term, ]
dtm.verbs = dtm.create(verbs$aid, verbs$lemma)
```

```
## (Duplicate row-column matches occured. Values of duplicates are added up)
```

```r
m.verbs = topmod.lda.fit(dtm.verbs, K = 5, alpha = .5)
terms(m.verbs, 10)
```

```
##       Topic 1   Topic 2    Topic 3 Topic 4   Topic 5   
##  [1,] "kill"    "must"     "get"   "should"  "could"   
##  [2,] "fire"    "continue" "know"  "see"     "make"    
##  [3,] "use"     "follow"   "think" "write"   "may"     
##  [4,] "wound"   "include"  "see"   "send"    "fall"    
##  [5,] "hit"     "stop"     "want"  "make"    "expect"  
##  [6,] "include" "end"      "come"  "live"    "rise"    
##  [7,] "begin"   "work"     "make"  "stop"    "include" 
##  [8,] "launch"  "make"     "look"  "give"    "might"   
##  [9,] "accord"  "need"     "talk"  "use"     "pay"     
## [10,] "stop"    "provide"  "let"   "support" "continue"
```
