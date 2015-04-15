Topic Modeling
-------

Topics can be seen as groups of words that cluster together.
Similar to factor analysis, topic modeling reduces the dimensionality of the feature space (the term-document matrix)
assuming that the latent factors (the topics) will correspond to meaningful latent classes (e.g. issues, frames).
We can use the document-term matrix from the `sotu` dataset in `topicbrowser`, which contains the the nouns, names and adjectives from Bush' and Obama's State of the Union addresses. 
With this dtm, a topic model can be trained using the `LDA` function  from the `topicmodels` package.
We specify that we want to use the Gibbs sampler with 200 iterations.


```r
library(topicbrowser)
```

```
## Loading required package: RColorBrewer
## Loading required package: wordcloud
## Loading required package: Rcpp
## Loading required package: Matrix
## Loading required package: reshape2
## Loading required package: markdown
## Loading required package: base64
## 
## Attaching package: 'topicbrowser'
## 
## The following object is masked from 'package:knitr':
## 
##     render_html
```

```r
library(topicmodels)
library(tm)
data(sotu)
sotu.dtm = weightTf(sotu.dtm)
set.seed(12345)
m = LDA(sotu.dtm, k = 10, method = "Gibbs", control = list(iter = 200))
```


Note that set.seed makes sure that if the function is run again, you get the same results
(which would normally not be the case since LDA is non-deterministic).

The resulting LDA model `m` can be inspected and plotted in a variety of ways,
the simplist of which is listing the most important words per topic using `terms`:


```r
terms(m, 10)
```

```
##       Topic 1      Topic 2    Topic 3   Topic 4    Topic 5      Topic 6  
##  [1,] "way"        "new"      "America" "year"     "America"    "country"
##  [2,] "today"      "job"      "world"   "tax"      "energy"     "life"   
##  [3,] "money"      "more"     "nation"  "family"   "home"       "day"    
##  [4,] "Security"   "business" "people"  "last"     "goal"       "man"    
##  [5,] "worker"     "american" "freedom" "next"     "economy"    "law"    
##  [6,] "Social"     "tonight"  "great"   "budget"   "power"      "woman"  
##  [7,] "Federal"    "company"  "free"    "deficit"  "technology" "citizen"
##  [8,] "government" "market"   "terror"  "more"     "clean"      "work"   
##  [9,] "other"      "first"    "peace"   "bill"     "oil"        "part"   
## [10,] "system"     "place"    "own"     "spending" "commitment" "Tonight"
##       Topic 7     Topic 8     Topic 9          Topic 10   
##  [1,] "Americans" "child"     "people"         "terrorist"
##  [2,] "Congress"  "school"    "american"       "Iraq"     
##  [3,] "health"    "good"      "time"           "States"   
##  [4,] "care"      "education" "America"        "United"   
##  [5,] "reform"    "program"   "future"         "weapon"   
##  [6,] "plan"      "many"      "responsibility" "war"      
##  [7,] "cost"      "college"   "economy"        "security" 
##  [8,] "insurance" "student"   "same"           "force"    
##  [9,] "best"      "better"    "generation"     "enemy"    
## [10,] "Medicare"  "community" "action"         "nuclear"
```


Although interpreting topics on the top words alone is always iffy, it seems that most of the topics have a distinct meaning.
Dot example, topic 10 seems to be about health care, while topic 8 deals with war and security.

The package `topicbrowser` contains a number of useful functions for plotting topics and listing the top documents per topic.
Let's plot the word ckoud for topic 8:


```r
plot_wordcloud(m, topic_nr = 8)
```

![plot of chunk unnamed-chunk-3](figure/unnamed-chunk-3.png) 


To make richer visualizations, we combine the LDA model with the original tokens and the metadata into a 'clusterinfo' object:


```r
info = clusterinfo(m, sotu.tokens$lemma, sotu.tokens$aid, words = sotu.tokens$word, 
    meta = sotu.meta)
```


We can use this to e.g. add topic use over time to the graph:


```r
plot_wordcloud_time(clusterinfo = info, topic_nr = 8, time_interval = "year")
```

![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5.png) 


And to create a network visualization rather than a normal word cloud:


```r
plot_semnet(clusterinfo = info, topic_nr = 10)
```

```
## Loading required package: semnet
## Loading required package: plyr
## Loading required package: zoo
## 
## Attaching package: 'zoo'
## 
## The following objects are masked from 'package:base':
## 
##     as.Date, as.Date.numeric
## 
## Loading required package: scales
## Loading required package: slam
## Loading required package: igraph
## Note: method with signature 'CsparseMatrix#Matrix#missing#replValue' chosen for function '[<-',
##  target signature 'dgCMatrix#nsCMatrix#missing#numeric'.
##  "Matrix#nsparseMatrix#missing#replValue" would also be valid
```

![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6.png) 


Finally, we can create a 'topic browser' HTML page which contains an overview of all topics. See e.g. the example at [rpubs](http://rpubs.com/Anoniem/72883)


```r
createTopicBrowser(info)
```


We can also include the 'semantic network' topic representations by including that in the per-topic plot functions:


```r
createTopicBrowser(info, plotfunction.pertopic = c(plot_wordcloud_time, plot_semnet))
```

