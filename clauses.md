---
title: "Clause analysis""
output: html_document
---

In clause analysis, the grammatical structure of text is used to analyse 'who did what to whom (according to whom)', 
to adapt the classical quote from Harold Lasswell. 
From a users point of view, clause analysis is called in AmCAT similar to other analyses:


```r
library(amcatr)
conn = amcat.connect("http://preview.amcat.nl")
sentence = "Mary told me that John loves her more than anything"
t = amcat.gettokens(conn, sentence=as.character(sentence), module="clauses_en")
t
```

```
##        word sentence coref  pos    lemma offset source_id source_role id
## 1      Mary        1     2  NNP     Mary      0         0      source  1
## 2      told        1    NA  VBD     tell      5        NA              2
## 3        me        1    NA  PRP        I     10        NA              3
## 4      that        1    NA   IN     that     13         0       quote  4
## 5      John        1    NA  NNP     John     18         0       quote  5
## 6     loves        1    NA  VBZ     love     23         0       quote  6
## 7       her        1     2 PRP$      she     29         0       quote  7
## 8      more        1    NA  JJR     more     33         0       quote  8
## 9      than        1    NA   IN     than     38         0       quote  9
## 10 anything        1    NA   NN anything     43         0       quote 10
##    pos1 clause_role clause_id
## 1     M                    NA
## 2     V                    NA
## 3     O                    NA
## 4     P   predicate         0
## 5     M     subject         0
## 6     V   predicate         0
## 7     O   predicate         0
## 8     A   predicate         0
## 9     P   predicate         0
## 10    N   predicate         0
```

As you can see in the result, this is essentially the output from the lemmatization with three extra sets of columns:
* `source_id` and `source_role` identify (quoted or paraphrased) sources. In this case, there is one quotation (source_id 0) with Mary being the source, and 'that ... anything' the quote.
* `clause_id` and `clause_role` perform a similar function: John is the subject of clause '0', while 'loving her more than anything' is the predicate
* Finally, `coref` indicates coreference: words with the same coreference id refer to the same person or entity. In this case, Mary and 'her' are correctly identified as co-referring.

Thus, the clause analysis breaks down the sentence into a nested structure, with the clause nested in the quotation. 
For clauses, the subject is the semantic agent or actor doing something, while the predicate is everything else, including the verb and the direct object, if applicable. 

Since this data set is "just another" R data frame containing tokens, the techniques from the first part of the workshop are directly applicable. 
To show this, let's get the same data set containing American coverage of the Gaza war:


```r
t3 = amcat.gettokens(conn, project=688, articleset = 17667, module = "clauses_en", page_size = 100, drop=NULL)
t3 = amcat.tokens.unique_indices(t3)
save(t3, file="clauses_17667b.rda")
```



Lets have a look at the (beginning of) the second sentence of the first article:


```r
head(t3[t3$sentence==2,], n=25)
```

```
##          word sentence pos     lemma offset      aid  id pos1 coref
## 89         ``        2  ``        ``    406 26074649  89    .    NA
## 90        The        2  DT       the    407 26074649  90    D     3
## 91    Israeli        2  JJ   israeli    411 26074649  91    A     3
## 92     attack        2  NN    attack    419 26074649  92    N     3
## 93         on        2  IN        on    426 26074649  93    P     3
## 94       Gaza        2 NNP      Gaza    429 26074649  94    M     3
## 95         is        2 VBZ        be    434 26074649  95    V    NA
## 96        far        2  RB       far    437 26074649  96    B    NA
## 97       from        2  IN      from    441 26074649  97    P    NA
## 98          a        2  DT         a    446 26074649  98    D    NA
## 99     simple        2  JJ    simple    448 26074649  99    A    NA
## 100 operation        2  NN operation    455 26074649 100    N    NA
## 101        to        2  TO        to    465 26074649 101    ?    NA
## 102      stop        2  VB      stop    468 26074649 102    V    NA
## 103  homemade        2  NN  homemade    473 26074649 103    N     2
## 104   rockets        2 NNS    rocket    482 26074649 104    N     2
## 105     being        2 VBG        be    490 26074649 105    V     2
## 106     fired        2 VBN      fire    496 26074649 106    V     2
## 107      into        2  IN      into    502 26074649 107    P     2
## 108    Israel        2 NNP    Israel    507 26074649 108    M     2
## 109         ,        2   ,         ,    513 26074649 109    .    NA
## 110        ''        2  ''        ''    514 26074649 110    .    NA
## 111    writes        2 VBZ     write    516 26074649 111    V    NA
## 112    Philip        2 NNP    Philip    523 26074649 112    M     5
## 113   Giraldi        2 NNP   Giraldi    530 26074649 113    M     5
##     clause_role clause_id source_id source_role freq israel palest
## 89                     NA        NA                1  FALSE  FALSE
## 90      subject         9         1       quote    1  FALSE  FALSE
## 91      subject         9         1       quote    1   TRUE  FALSE
## 92      subject         9         1       quote    1  FALSE  FALSE
## 93                     NA        NA                1  FALSE  FALSE
## 94      subject         9         1       quote    1  FALSE  FALSE
## 95    predicate         9         1       quote    1  FALSE  FALSE
## 96    predicate         9         1       quote    1  FALSE  FALSE
## 97                     NA        NA                1  FALSE  FALSE
## 98    predicate         9         1       quote    1  FALSE  FALSE
## 99    predicate         9         1       quote    1  FALSE  FALSE
## 100   predicate         9         1       quote    1  FALSE  FALSE
## 101   predicate         9         1       quote    1  FALSE  FALSE
## 102   predicate         9         1       quote    1  FALSE  FALSE
## 103   predicate         9         1       quote    1  FALSE  FALSE
## 104   predicate         9         1       quote    1  FALSE  FALSE
## 105   predicate         9         1       quote    1  FALSE  FALSE
## 106   predicate         9         1       quote    1  FALSE  FALSE
## 107                    NA        NA                1  FALSE  FALSE
## 108   predicate         9         1       quote    1   TRUE  FALSE
## 109                    NA        NA                1  FALSE  FALSE
## 110                    NA        NA                1  FALSE  FALSE
## 111                    NA        NA                1  FALSE  FALSE
## 112                    NA         1      source    1  FALSE  FALSE
## 113                    NA         1      source    1  FALSE  FALSE
```

As you can see, Philip Giraldi is correctly identified as a source, and his quote contains a single clause, 
with "the Israeli attack" as subject and "is far from ... into Israel" is the predicate.
This illustrates some of the possibilities and limitations of the method:
It correctly identifies the main argument in the sentence: Israel is trying to stop rockets fired into Israel, among other things and according to Philip Giraldi.
It does not, however, see the Israeli attack on Gaza as a quote since the mechanism depends on verb structure, and that phrase does not have a verb. 
Moreover, the problem of understanding complex or even subtle messages like it being "far from" only about stopping rockets is not closer to a solution. 
That said, this analysis can solve the basic problem in conflict coverage that co-occurrence methods are difficult because most documents talk about both sides, requiring analysis of who does what to whom.

To showcase how this output can be analysed with the same techniques as discussed above, 
let's look at the predicates for which Israel and Palestine are subject, respectively. 
First, we define a variable indicating whether a token is indicative of either actor using a simplistic pattern, 
then select all clause ids that have Israel as its subject, and finally select all predicates that match that clause_id:
(This looks and sound more complex than it is)


```r
t3$israel = grepl("israel.*|idf", t3$lemma, ignore.case = T)
clauses.israel = unique(t3$clause_id[t3$israel & !is.na(t3$clause_role) & t3$clause_role == "subject"])
predicates.israel = t3[!is.na(t3$clause_role) & t3$clause_role == "predicate" & t3$clause_id %in% clauses.israel, ]
```

Now, we can create a dtm containing only verbs in those predicates, and create a word cloud of those verbs:


```r
library(corpustools)
tokens = predicates.israel[predicates.israel$pos1 == 'V' & !(predicates.israel$lemma %in% c("have", "be", "do", "will")),]
dtm.israel = dtm.create(tokens$aid, tokens$lemma)
dtm.wordcloud(dtm.israel)
```

![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6.png) 

Let's see what Hamas does:


```r
t3$hamas = grepl("hamas.*", t3$lemma, ignore.case = T)
clauses.hamas = unique(t3$clause_id[t3$hamas & !is.na(t3$clause_role) & t3$clause_role == "subject"])
predicates.hamas = t3[!is.na(t3$clause_role) & t3$clause_role == "predicate" & t3$clause_id %in% clauses.hamas, ]
tokens = predicates.hamas[predicates.hamas$pos1 == 'V' & !(predicates.hamas$lemma %in% c("have", "be", "do", "will")),]
dtm.hamas = dtm.create(tokens$aid, tokens$lemma)
dtm.wordcloud(dtm.hamas)
```

![plot of chunk unnamed-chunk-7](figure/unnamed-chunk-7.png) 

So, there is some difference in verb use, Israel " continue (to) kill (and) launch", while Hamas "stop (or) continue firing (and) launching". 
However, there is also considerable overlap, which is not very strange as both actors are engaged in active military conflict.
Of course, we can also check now of which verbs Israel is more often the subject of compared to Hamas:


```r
cmp = corpora.compare(dtm.israel, dtm.hamas)
with(cmp[cmp$over > 1,], dtm.wordcloud(terms=term, freqs=chi))
```

![plot of chunk unnamed-chunk-8](figure/unnamed-chunk-8.png) 

And which as Hamas' favourite verbs:


```r
with(cmp[cmp$over < 1,], dtm.wordcloud(terms=term, freqs=chi))
```

![plot of chunk unnamed-chunk-9](figure/unnamed-chunk-9.png) 

So, Hamas fires, hides, smuggles, and vows (to) rearm, while Israel defends and moes, but also bombs, pounds, and invades.

Finally, let us see whether we can do a topic modeling of quotes. 
For example, we can make a topic model of all quotes, and then see which topics are more prevalent in Israeli quotes. 
First, we add Palestinians (palest*) as a possible source, to distinguish between Hamas (militans) and Palestinian (civilians),
and take only sources that uniquely contain one of these actors:


```r
t3$palest = grepl("palest.*", t3$lemma, ignore.case = T)
sources.israel = t3$source_id[!is.na(t3$source_id) & t3$source_role == "source" & t3$israel]
sources.hamas = t3$source_id[!is.na(t3$source_id) & t3$source_role == "source" & t3$hamas]
sources.palest = t3$source_id[!is.na(t3$source_id) & t3$source_role == "source" & t3$palest]

# keep all sources with only one source
sources.israel.u = setdiff(sources.israel, c(sources.hamas,sources.palest))
sources.hamas.u = setdiff(sources.hamas, c(sources.israel,sources.palest))
sources.palest.u = setdiff(sources.palest, c(sources.hamas,sources.israel))
```

Now, we can select those quotes that belong to any of those sources, and do a frequency analysis on the quotes to select vocabulary for modeling:


```r
sources = unique(c(sources.israel.u, sources.hamas.u, sources.palest.u))
quotes = t3[!is.na(t3$source_role) & t3$source_role=="quote" & (t3$source_id %in% sources) & t3$pos1 %in% c("V", "N", "A", "M"),]
dtm.quotes = dtm.create(quotes$source_id, quotes$lemma)
```

```
## (Duplicate row-column matches occured. Values of duplicates are added up)
```

```r
freq = term.statistics(dtm.quotes)
freq = freq[!freq$number & !freq$nonalpha & freq$characters > 2 & freq$termfreq > 5 & freq$reldocfreq < .15,]
freq = freq[order(-freq$reldocfreq), ]
head(freq)
```

```
##              term characters number nonalpha termfreq docfreq reldocfreq
## Israel     Israel          6  FALSE    FALSE     1294    1198    0.13298
## rocket     rocket          6  FALSE    FALSE     1048    1023    0.11355
## kill         kill          4  FALSE    FALSE      957     934    0.10367
## israeli   israeli          7  FALSE    FALSE      912     881    0.09779
## fire         fire          4  FALSE    FALSE      802     757    0.08403
## militant militant          8  FALSE    FALSE      657     654    0.07259
##           tfidf
## Israel   0.3438
## rocket   0.3651
## kill     0.4999
## israeli  0.3650
## fire     0.4604
## militant 0.4338
```

Using this list to create a new dtm, we can run a topic model:


```r
dtm.quotes.subset = dtm.quotes[, colnames(dtm.quotes) %in% freq$term]
set.seed(123)
m = topmod.lda.fit(dtm.quotes.subset, K=10, alpha=.5)
terms(m, 10)
```

```
##       Topic 1        Topic 2     Topic 3      Topic 4     Topic 5       
##  [1,] "kill"         "rocket"    "military"   "use"       "militant"    
##  [2,] "more"         "Israel"    "israeli"    "weapon"    "area"        
##  [3,] "people"       "fire"      "operation"  "target"    "fighter"     
##  [4,] "civilian"     "stop"      "soldier"    "tunnel"    "israeli"     
##  [5,] "Palestinians" "attack"    "war"        "civilian"  "troops"      
##  [6,] "least"        "southern"  "will"       "smuggling" "City"        
##  [7,] "child"        "offensive" "government" "attack"    "ground"      
##  [8,] "dead"         "launch"    "Strip"      "destroy"   "neighborhood"
##  [9,] "wound"        "will"      "ground"     "border"    "force"       
## [10,] "airstrike"    "goal"      "army"       "other"     "move"        
##       Topic 6         Topic 7    Topic 8       Topic 9     Topic 10  
##  [1,] "allow"         "fire"     "would"       "death"     "Israel"  
##  [2,] "humanitarian"  "militant" "palestinian" "day"       "will"    
##  [3,] "time"          "israeli"  "israeli"     "Israel"    "end"     
##  [4,] "group"         "hit"      "leader"      "offensive" "would"   
##  [5,] "would"         "shell"    "talk"        "say"       "border"  
##  [6,] "international" "mortar"   "truce"       "can"       "truce"   
##  [7,] "supplies"      "school"   "Sunday"      "make"      "crossing"
##  [8,] "fight"         "target"   "state"       "know"      "deal"    
##  [9,] "continue"      "northern" "Egypt"       "toll"      "include" 
## [10,] "aid"           "house"    "support"     "incident"  "blockade"
```

So, topic 1 seems to be about civilian casualties.
Topic 2 is about the rocket attacks (presumably on Israel) and topic 4 is about the smuggling tunnels, the ending of both of which are stated Israeli goals. 
Another interesting topic is 10, which is about the border crossings and blockade, the end of which was a Hamas condition for peace.
Topic 6 is about humanitarian aid, while the other topics seem mainly about the fighting and international diplomacy.

To investigate which topics are used most by the identified actors, we first extract the list of topics per document (quote):


```r
quotes = topmod.topics.per.document(m)
head(quotes)
```

```
##          id      X1      X2      X3      X4      X5      X6      X7
## 980     980 0.04545 0.59091 0.04545 0.04545 0.04545 0.04545 0.04545
## 1508   1508 0.28125 0.03125 0.09375 0.03125 0.03125 0.09375 0.03125
## 5054   5054 0.04545 0.59091 0.04545 0.04545 0.04545 0.04545 0.04545
## 6479   6479 0.04545 0.59091 0.04545 0.04545 0.04545 0.04545 0.04545
## 9939   9939 0.04545 0.59091 0.04545 0.04545 0.04545 0.04545 0.04545
## 12974 12974 0.04545 0.50000 0.04545 0.04545 0.04545 0.04545 0.04545
##            X8      X9     X10
## 980   0.04545 0.04545 0.04545
## 1508  0.09375 0.21875 0.09375
## 5054  0.04545 0.04545 0.04545
## 6479  0.04545 0.04545 0.04545
## 9939  0.04545 0.04545 0.04545
## 12974 0.13636 0.04545 0.04545
```

This data frame lists the quote id and the loading of each topic on that quote.
This is the general data that you would normally need to analyse topic use over time, per medium etc., and that we now use to analyse use per source.
First, we convert this from a wide to a tall format using the `melt` function in package `reshape2`:


```r
quotes = melt(quotes, id.vars="id", variable.name="topic")
head(quotes)
```

```
##      id topic   value
## 1   980    X1 0.04545
## 2  1508    X1 0.28125
## 3  5054    X1 0.04545
## 4  6479    X1 0.04545
## 5  9939    X1 0.04545
## 6 12974    X1 0.04545
```

And add a new variable for whether the subject was Israel, Hamas, or Palestinians:



```r
quotes$subject = ifelse(quotes$id %in% sources.israel.u, "israel",
                         ifelse(quotes$id %in% sources.palest.u, "palest", "hamas"))
table(quotes$subject)
```

```
## 
##  hamas israel palest 
##  15330  57960  15060
```

So, Israel has by far the most quotes. Note that this number is inflated because it counts each topic loading for each  quote.
Now, if we assert that a quote is 'about' a topic if the loading is at least .5, we can calculate topic use per source using `acast`, again from `reshape2`:


```r
quotes = quotes[quotes$value > .5,]
round(acast(quotes, topic ~ subject, length), digits=2)
```

```
##     hamas israel palest
## X1     26     13    121
## X2      0    193      4
## X3     44     35      8
## X4      1     88      0
## X5     27     81     27
## X6     10     69      5
## X7      0    131     50
## X8     19     76      3
## X9      1     22      6
## X10    70     40      6
```

So, we can see some clear patterns. Israel prefers to talk about its goals (2: stopping the rockets) but is also forced to talk about its combat actions, especially topic 7 which includes shelling schools and houses. 
Hamas talks mostly about the blockade (10), whlie other Palestinian sources talk about the killing of civilians (1) but also about topic 7.

Of course, this is only one of many possible analyses. For example,
we could also look at predicates rather than quotes:
what kind of actions are performed by Israel and Hamas?
Also, it would be interesting to compare American news with news from Muslim countries, to see if the framing differs between sources.
The good news is that all these analyses can be performed using the tools discussed in this and the previous session: 
after running `amcat.gettokens`, you have normal R data frame which list the tokens, and this data frame can be analysed and manipulated like a normal R data frame.
Selections of the frame can be converted to a term-document matrix, after which corpus-analytic tools like frequency analysis, topic modeling, or machine learning using e.g. RTextTools.

Turning clauses into Networks
====

As a final interesting topic, let's do a simple semantic network analysis based on the clauses.
To do this, first add actors for American and European politics:


```r
t3$eu = grepl("euro.*", t3$lemma, ignore.case=T)
t3$us = grepl("america.*|congress.*|obama", t3$lemma, ignore.case=T)
```

Now, let's select only those tokens that occur in a clause and contain an actor,
and convert (melt) that to long format, asking for the actor per clause and role:


```r
clauses = t3[!is.na(t3$clause_id) & (t3$israel | t3$palest | t3$hamas | t3$eu | t3$us), ]
b = melt(clauses, id.vars=c("clause_id", "clause_role"), 
         measure.vars=c("israel", "palest", "hamas", "eu", "us"), 
         variable.name="actor")
head(b)
```

```
##   clause_id clause_role  actor value
## 1         2   predicate israel  TRUE
## 2         2   predicate israel  TRUE
## 3         9     subject israel  TRUE
## 4         9   predicate israel  TRUE
## 5        11   predicate israel FALSE
## 6        12   predicate israel  TRUE
```

This lists all clause-role-actor combinations, including those that did not occur (`value=FALSE`).
So, we filter on `b$value` (which is equivalent to `b$value == TRUE`). 
Also, we apply unique to make sure a clause is not counted twice if two words matched the same actor
(e.g. clause 2, which contained two Israel words in the predicate):


```r
b = unique(b[b$value == TRUE, ])
head(b)
```

```
##   clause_id clause_role  actor value
## 1         2   predicate israel  TRUE
## 3         9     subject israel  TRUE
## 4         9   predicate israel  TRUE
## 6        12   predicate israel  TRUE
## 7        16   predicate israel  TRUE
## 9        18   predicate israel  TRUE
```

Now, we can make an 'edge list' by matching the predicates and subjects on clause_id:


```r
predicates = b[b$clause_role == "predicate", c("clause_id", "actor")]
subjects = b[b$clause_role == "subject", c("clause_id", "actor")]
edges = merge(subjects, predicates, by="clause_id")
head(edges)
```

```
##   clause_id actor.x actor.y
## 1         9  israel  israel
## 2        29  israel  palest
## 3        33   hamas  israel
## 4        47  israel  israel
## 5        48  palest      us
## 6        91  israel  israel
```

This list gives each subject (x) and predicate (y) combination in each clause. 
To keep it simple, lets say we only care about how often an actor 'does something' to another actor,
so we aggregate by subject and predicate, and simply count the amount of clauses (using `length`):


```r
edgecounts = aggregate(list(n=edges$clause_id), by=edges[c("actor.x", "actor.y")], FUN=length)
head(edgecounts)
```

```
##   actor.x actor.y    n
## 1  israel  israel 1728
## 2  palest  israel 1191
## 3   hamas  israel 3440
## 4      eu  israel  120
## 5      us  israel  595
## 6  israel  palest 1892
```

Now, we can use the `igraph` package to plot the graph, e.g. ploting all edges occurring more than 500 times:


```r
library("igraph")
g  = graph.data.frame(edgecounts[edgecounts$n > 500,], directed=T)
plot(g)
```

![plot of chunk unnamed-chunk-22](figure/unnamed-chunk-22.png) 

So, (unsurprisingly) Israel and Hamas act on each other and both act on Palestinians, while the US acts only on Israel. Europe does not occur (probably because of the naive search string).

Let's now have a look at the verbs in the US 'actions' towards Israel. 


```r
us.il.clauses = edges$clause_id[edges$actor.x == "us" & edges$actor.y == "israel"]
us.il.verbs = t3[!is.na(t3$clause_id) & t3$clause_id %in% us.il.clauses & t3$pos1 == "V" & !(t3$lemma %in% c("have", "be", "do", "will")), ]
us.il.verbs.dtm = dtm.create(us.il.verbs$aid, us.il.verbs$lemma)
```

```
## (Duplicate row-column matches occured. Values of duplicates are added up)
```

```r
dtm.wordcloud(us.il.verbs.dtm)
```

![plot of chunk unnamed-chunk-23](figure/unnamed-chunk-23.png) 

So, even though the EU did not act on Israel a lot, lets look at what they did do:


```r
eu.il.clauses = edges$clause_id[edges$actor.x == "eu" & edges$actor.y == "israel"]
eu.il.verbs = t3[!is.na(t3$clause_id) & t3$clause_id %in% eu.il.clauses & t3$pos1 == "V" & !(t3$lemma %in% c("have", "be", "do", "will")), ]
eu.il.verbs.dtm = dtm.create(eu.il.verbs$aid, eu.il.verbs$lemma)
```

```
## (Duplicate row-column matches occured. Values of duplicates are added up)
```

```r
dtm.wordcloud(eu.il.verbs.dtm, nterms=50, freq.fun=sqrt)
```

![plot of chunk unnamed-chunk-24](figure/unnamed-chunk-24.png) 

So, the US defends, supports, and stands (by) Israel, while the EU calls, meets, pleads, urges and condemns them.

Obviously, even though this is quite interesting already, this is the start of a proper semantic network analysis rather than the end.
an obvious extension would be to systematically analyse different possible actions, e.g. using topic models or some sort of event dictionary. 
Of course, it would also be interesting to compare the semantic network from different countries or according to different sources, etc.
The good news is, all these analyses are really just combinations of the various techniques described in this and the previous session. 
